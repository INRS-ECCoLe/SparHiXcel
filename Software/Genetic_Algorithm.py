import random
import numpy as np
import matplotlib.pyplot as plt
import assign_PE_max_output_filter
import pretrained_models_torchvision
from pretrained_models_torchvision import get_pruned_weights_dict

# --- Load pruned weights ---
weights_dict = get_pruned_weights_dict(pruning_amount=0.7)

# --- GA Hyperparameters ---
POP_SIZE = 1000
NUM_GENERATIONS = 100
MUTATION_RATE = 0.4
TOURNAMENT_SIZE = 3
ELITISM_COUNT = 5

# --- Target Layer ---
layer_name = 'features.12.weight'
arg1, arg2, arg3 = 15, 15, 256  # constants for fitness function

# --- Extract weights and transpose to [kH, kW, C_in, C_out] ---
layer_weights = weights_dict[layer_name]
weights_np = np.transpose(layer_weights, (2, 3, 1, 0))
C_in = weights_np.shape[2]
C_out = weights_np.shape[3]

# --- GA Functions ---
def initialize_population(pop_size, C_in, C_out):
    return [(list(np.random.permutation(C_in)), list(np.random.permutation(C_out)))
            for _ in range(pop_size)]

def evaluate_fitness(population, weights):
    scores = []
    for input_order, output_order in population:
        reordered = weights[:, :, input_order, :][:, :, :, output_order]
        fitness = assign_PE_max_output_filter.assign_PE_max_output_filter(arg1, arg2, arg3, reordered)
        scores.append(fitness)
    return scores

def tournament_selection(pop, scores, k=TOURNAMENT_SIZE):
    return max(random.sample(list(zip(pop, scores)), k), key=lambda x: x[1])[0]

def crossover_order(o1, o2):
    size = len(o1)
    a, b = sorted(random.sample(range(size), 2))
    child = [None] * size
    child[a:b] = o1[a:b]
    fill = [x for x in o2 if x not in child]
    j = 0
    for i in range(size):
        if child[i] is None:
            child[i] = fill[j]
            j += 1
    return child

def mutate_order(order, rate=MUTATION_RATE):
    order = order[:]
    if random.random() < rate:
        a, b = random.sample(range(len(order)), 2)
        order[a], order[b] = order[b], order[a]
    return order

def crossover(p1, p2):
    return (crossover_order(p1[0], p2[0]), crossover_order(p1[1], p2[1]))

def mutate(ind):
    return (mutate_order(ind[0]), mutate_order(ind[1]))

# --- Real-time plot setup ---
plt.ion()
fig, ax = plt.subplots(figsize=(10, 6))
line_best, = ax.plot([], [], label='Best Fitness', color='green')
line_avg, = ax.plot([], [], label='Average Fitness', color='blue')
ax.set_xlim(0, NUM_GENERATIONS)
ax.set_ylim(0, 1)
ax.set_xlabel("Generation")
ax.set_ylabel("Fitness")
ax.set_title("GA Progress (Live)")
ax.grid(True)
ax.legend()

# --- GA Execution ---
population = initialize_population(POP_SIZE, C_in, C_out)
global_best_fitness = -float('inf')
global_best_individual = None
best_history = []
avg_history = []

for gen in range(NUM_GENERATIONS):
    fitness_scores = evaluate_fitness(population, weights_np)
    best_idx = np.argmax(fitness_scores)
    best_fit = fitness_scores[best_idx]
    best_ind = population[best_idx]

    if best_fit > global_best_fitness:
        global_best_fitness = best_fit
        global_best_individual = best_ind

    best_history.append(best_fit)
    avg_history.append(np.mean(fitness_scores))
    print(f"Generation {gen+1:>3} | Best: {best_fit:.4f} | Global Best: {global_best_fitness:.4f}")

    # Update plot
    line_best.set_data(range(1, gen + 2), best_history)
    line_avg.set_data(range(1, gen + 2), avg_history)
    current_max = max(best_history + avg_history)
    if current_max > ax.get_ylim()[1]:
        ax.set_ylim(0, current_max * 1.1)
    plt.pause(0.01)

    # Elitism + breeding
    elite = [population[i] for i in np.argsort(fitness_scores)[-ELITISM_COUNT:]]
    new_pop = elite[:]
    while len(new_pop) < POP_SIZE:
        p1 = tournament_selection(population, fitness_scores)
        p2 = tournament_selection(population, fitness_scores)
        child = mutate(crossover(p1, p2))
        new_pop.append(child)
    population = new_pop

# --- Final output ---
plt.ioff()
plt.show()

print("\n✅ Global Best Input Order:", global_best_individual[0])
print("✅ Global Best Output Order:", global_best_individual[1])

# Optional: reordered weights
best_weights_reordered = weights_np[:, :, global_best_individual[0], :][:, :, :, global_best_individual[1]]
