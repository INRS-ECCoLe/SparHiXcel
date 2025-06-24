import torch
import numpy as np
from torchvision import models
import torch.nn as nn
import torch.optim as optim
from torchvision import models, transforms
from torchvision.datasets import CIFAR10
from torch.utils.data import DataLoader
import assign_PE_max_output_filter

# Load EfficientNetV2-S with pretrained weights
model = models.efficientnet_v2_s(weights='IMAGENET1K_V1')  # This is the identifier for the pretrained weights





# Function to prune all convolution layers
def prune_weights(model, pruning_amount=0.8):
    for name, module in model.named_modules():
        # Prune all types of convolution layers (Conv2d, DepthwiseConv2d)
        if isinstance(module, nn.Conv2d):
            # Number of weights in the Conv2d layer
            num_weights = module.weight.numel()

            # Calculate number of weights to prune
            num_prune = int(num_weights * pruning_amount)

            # Create a mask with the required number of weights set to zero
            weight = module.weight.data
            # Flatten weights to easily sample the desired amount of pruning
            weight_flat = weight.view(-1)
            # Get indices of weights to prune
            prune_indices = torch.topk(torch.abs(weight_flat), num_prune, largest=False).indices
            mask = torch.ones_like(weight_flat, dtype=torch.bool)
            mask[prune_indices] = False
            # Reshape the mask to match the original weight shape
            mask = mask.view(weight.size())

            # Apply the mask to weights
            module.weight.data *= mask

            # Optionally store the mask for future use
            module.weight_mask = mask

    return model

# Apply pruning
model = prune_weights(model, pruning_amount=0.7)

# Function to convert model weights to a dictionary of NumPy arrays
def model_weights_to_numpy(model):
    """
    Convert model weights to a dictionary of NumPy arrays.
    """
    weights_dict = {}
    for name, param in model.named_parameters():
        # Convert to NumPy array and store in the dictionary
        weights_dict[name] = param.detach().cpu().numpy()
    return weights_dict

# Convert the pruned model weights to NumPy arrays
weights_dict = model_weights_to_numpy(model)

# Example: Access the weights for a specific layer
# For example, let's access the weights of the first convolution layer (it might be different for EfficientNetV2)
# The name of the convolution layer can vary based on the model structure, but let's try to print the first layer's weights
#conv1_weights = weights_dict['features.2.1.block.1.0.weight']  # This might be different for your model; adjust the key name accordingly
#print(conv1_weights.shape)

# Example of accessing another layer's weights (e.g., for a different convolution layer)
#conv2_weights = weights_dict['features.3.0.weight']  # Again, the key name will depend on the model's architecture
#print(conv2_weights.shape)
assign_PE_max_output_filter.assign_PE_max_output_filter(3,33, 256, np.transpose(weights_dict['features.4.4.block.3.0.weight'],(2,3,1,0)))
print(weights_dict['features.2.0.block.0.0.weight'].shape)
print(np.transpose(weights_dict['features.2.0.block.0.0.weight'],(2,3,1,0)).shape)