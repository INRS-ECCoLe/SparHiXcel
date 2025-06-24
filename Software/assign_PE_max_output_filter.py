import numpy as np
import math
import filter_assign
import allocate_mux_tran
import scale
import quantize
import function_f_sel_and_weight
import function_col_num


def assign_PE_max_output_filter (N_ROWS_ARRAY, N_COLS_ARRAY, max_output_filter, f_weights):

  # Quantizing weights

  bitwidth = 8
  sign = True
  s, z = scale.scale(f_weights, bitwidth, sign)
  Q_f_weights = quantize.quantize(f_weights, s, z, bitwidth, sign)
  #Q_f_weights = f_weights
  #print(np.sum(abs(Q_f_weights) < pow(2,-8)))
#-----------------------------------------------------------------------------------------------
  # Sorting filters based on numbers of zeros they have.(ascending order of zero density)

  near_zero_count = 0
  near_zero_threshold = pow(2,-8)
  near_zero_count = np.sum(np.abs(Q_f_weights) < near_zero_threshold, axis = (0, 1, 2))
  #print(near_zero_count)
  sorted_filter_index = np.argsort(near_zero_count)
  #print(sorted_filter_index)
  #f_weights_sorted = Q_f_weights[:,:,:,sorted_filter_index]
  f_weights_sorted = Q_f_weights
  #print(f_weights_sorted)

#-----------------------------------------------------------------------------------------------
  # Saving indices of each elements of sorted weights.

  indices_of_elements_in_f_weights_sorted = np.stack(np.indices(f_weights_sorted.shape), axis=-1)
  #print(indices_of_elements_in_f_weights_sorted)

#-----------------------------------------------------------------------------------------------
  # Compressing filters.
  #N_ROWS_ARRAY = f_weights.shape[2]*f_weights.shape[0]
  if f_weights.shape[2]*f_weights.shape[0] <= N_ROWS_ARRAY:

    n = 1

  else:

    n = math.ceil(f_weights.shape[2]/math.floor(N_ROWS_ARRAY/f_weights.shape[0]))
  print(f_weights_sorted.shape[3])
  print(f_weights_sorted.shape[2])
  print(f_weights_sorted.shape[1])
  print(f_weights_sorted.shape[0])
  #print(n)
  remaining_array = N_COLS_ARRAY * np.ones((N_ROWS_ARRAY, 1))
  full_array = N_COLS_ARRAY * np.ones((N_ROWS_ARRAY, 1))
  filled_array = np.zeros((N_ROWS_ARRAY, 1))
  num_of_col= np.zeros((N_ROWS_ARRAY,1))
  n_columns = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
  sel_mux_tr = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
  f_s = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
  weights_array = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
  en_adder_node =  np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
  result_col = np.zeros((1,N_COLS_ARRAY))
  PE_array_weights = []
  PE_array_weights.append([])
  PE_array_index= []
  PE_array_index.append([])
  PE_array_f_sel = []
  PE_array_f_sel.append([])
  PE_array_filter_num= []
  PE_array_filter_num.append([])
  num_of_columns =[]
  num_of_columns.append([])
  sel_mux_transfer= []
  sel_mux_transfer.append([])
  en_adder_node_all = []
  en_adder_node_all.append([])
  result_columns= []
  result_columns.append([])
  count = 0
  indexes=[]
  f_sels = []
  weights = []
  number_col_removed = 0
  m = math.ceil(f_weights.shape[3]/max_output_filter)
  for filter_slices in range(m):

    for ch_slices_num in range(n):

      for filter_num in range(filter_slices*max_output_filter , min((filter_slices + 1) * max_output_filter, f_weights.shape[3])):

        for ch_num in range((ch_slices_num)*math.floor(N_ROWS_ARRAY/f_weights.shape[0]),min((ch_slices_num+1)*math.floor(N_ROWS_ARRAY/f_weights.shape[0]), f_weights.shape[2])):



          num_of_col[f_weights.shape[0]*(ch_num % math.floor(N_ROWS_ARRAY/f_weights.shape[0]) ) : f_weights.shape[0]*(1 + ch_num % math.floor(N_ROWS_ARRAY/f_weights.shape[0])) , :], index, f_select, weight, num_removed = filter_assign.filter_assign(f_weights_sorted[:,:,ch_num, filter_num], near_zero_threshold, f_weights.shape[0] )
          indexes.append(index)
          f_sels.append(f_select)
          weights.append(weight)
          number_col_removed += num_removed



        fill_array = full_array - remaining_array + num_of_col
        max_column = int(np.max(fill_array)) # eshtebahe
        last_non_zero_index = int(np.argmax(result_col))
        if np.all(result_col == 0):
          select_col =  max_column - 1
        elif (last_non_zero_index < max_column - 1):
          select_col =  max_column - 1
        else:
          select_col =  last_non_zero_index + 1


        if ((remaining_array - num_of_col>= 0).all() and select_col < N_COLS_ARRAY):
          PE_array_index[count].append(indexes)
          PE_array_filter_num[count].append(filter_num + 1)
          n_columns = function_col_num.function_col_num(n_columns, num_of_col, remaining_array, full_array)
          f_s , weights_array = function_f_sel_and_weight.function_f_sel_and_weight(f_s, f_sels, weights_array, weights, remaining_array, full_array, f_weights.shape[0])
          remaining_array = remaining_array - num_of_col
          sel_mux_tr, result_col, en_adder_node, filled_array = allocate_mux_tran.allocate_mux_tran (num_of_col, remaining_array, full_array, sel_mux_tr, result_col, en_adder_node, filter_num, f_weights.shape[0], filled_array)

          num_of_col = np.zeros((N_ROWS_ARRAY,1))
          indexes = []
          f_sels = []
          weights = []

        else:
          PE_array_weights[count].append(weights_array)
          weights_array = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
          PE_array_weights.append([])
          num_of_columns[count].append(n_columns)
          n_columns = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
          num_of_columns.append([])
          PE_array_f_sel[count].append(f_s)
          f_s = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
          PE_array_f_sel.append([])
          sel_mux_transfer[count].append(sel_mux_tr)
          sel_mux_tr = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
          sel_mux_transfer.append([])
          result_columns[count].append(result_col)
          result_col = np.zeros((1,N_COLS_ARRAY))
          result_columns.append([])
          en_adder_node_all[count].append(en_adder_node)
          en_adder_node = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
          en_adder_node_all.append([])
          remaining_array = N_COLS_ARRAY * np.ones((N_ROWS_ARRAY, 1))
          filled_array = np.zeros((N_ROWS_ARRAY, 1))
          f_s , weights_array = function_f_sel_and_weight.function_f_sel_and_weight(f_s, f_sels, weights_array, weights, remaining_array, full_array, f_weights.shape[0])
          n_columns = function_col_num.function_col_num(n_columns, num_of_col, remaining_array, full_array)
          PE_array_index.append([])
          PE_array_filter_num.append([])
          count +=1
          PE_array_index[count].append(indexes)
          PE_array_filter_num[count].append(filter_num + 1)
          indexes =[]
          f_sels = []
          weights = []
          remaining_array = remaining_array - num_of_col
          sel_mux_tr, result_col, en_adder_node, filled_array = allocate_mux_tran.allocate_mux_tran (num_of_col, remaining_array, full_array, sel_mux_tr, result_col, en_adder_node, filter_num, f_weights.shape[0], filled_array)

      PE_array_weights[count].append(weights_array)
      weights_array = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
      PE_array_weights.append([])
      num_of_columns[count].append(n_columns)
      n_columns = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
      num_of_columns.append([])
      PE_array_f_sel[count].append(f_s)
      f_s = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
      PE_array_f_sel.append([])
      sel_mux_transfer[count].append(sel_mux_tr)
      sel_mux_tr = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
      sel_mux_transfer.append([])
      result_columns[count].append(result_col)
      result_col = np.zeros((1,N_COLS_ARRAY))
      result_columns.append([])
      en_adder_node_all[count].append(en_adder_node)
      en_adder_node = np.zeros((N_ROWS_ARRAY,N_COLS_ARRAY))
      en_adder_node_all.append([])
      remaining_array = N_COLS_ARRAY * np.ones((N_ROWS_ARRAY, 1))
      filled_array = np.zeros((N_ROWS_ARRAY, 1))
      PE_array_index.append([])
      PE_array_filter_num.append([])
      count +=1
      weights = []
      indexes =[]
      f_sels = []
      num_of_col= np.zeros((N_ROWS_ARRAY,1))


  #print("PE_array_f_sel")
  #print(PE_array_f_sel)
  print('num of zeros')
  print(100*(np.sum(abs(Q_f_weights) < pow(2,-8))/(f_weights.shape[0]*f_weights.shape[1]*f_weights.shape[2]*f_weights.shape[3])))
  print('pe utilization saving')
  print(100*(1- count/(math.ceil(f_weights.shape[3]/int(N_COLS_ARRAY / f_weights.shape[1]))* math.ceil(f_weights.shape[2]/int(N_ROWS_ARRAY / f_weights.shape[0])))))
  #print(100*(1- ((count)*N_ROWS_ARRAY*N_COLS_ARRAY/(f_weights.shape[0]*f_weights.shape[1]*f_weights.shape[2]*f_weights.shape[3]))))
  #print(100*( 1 - count /math.ceil((f_weights.shape[2] * f_weights.shape[3])/(int(N_ROWS_ARRAY / f_weights.shape[0])*int(N_COLS_ARRAY / f_weights.shape[1])))))
  #print(100*(1- count / (math.ceil(f_weights.shape[0]*f_weights.shape[1]*f_weights.shape[2]*f_weights.shape[3]/(N_COLS_ARRAY * N_ROWS_ARRAY)))))
  #print("num_of_columns")
  #print(num_of_columns)
  #print(PE_array_index)
  #print(PE_array_filter_num)
  #print("sel_mux_transfer")
  #print(sel_mux_transfer)
  #print(result_columns)
  #print("en_adder_node_all")
  #print(en_adder_node_all)
  #print("PE_array_weights")
  #print(PE_array_weights)
 # print(np.array(en_adder_node_all[0][0][::-1]))
  print('compression saving')
  print(100*(number_col_removed/(f_weights.shape[1] * f_weights.shape[2]*f_weights.shape[3])))
  print("count")
  print(count)
  # Example data: lists of NumPy arrays
  #print(N_ROWS_ARRAY)
  #print('compression saving')
 # lists = [
  #  [np.array(en_adder_node_all[0][0][::-1])],  # First list
   # [np.array(sel_mux_transfer[0][0][::-1])],  # Second list
   # [np.array(num_of_columns[0][0][::-1])], # Third list
    #[np.array(PE_array_f_sel[0][0][::-1])]
   # ]

  # Define the bit lengths for each list (e.g., 2 bits for the first list, 4 bits for the second list)
 # bit_lengths = [1, 2, 2, 2]

  # Run the function
  #process_and_save(lists, bit_lengths, 'signal.txt')

  # Code to download the file in Google Colab
  #files.download('signal.txt')

  #lists = [
   # [np.array(PE_array_weights[0][0][::-1])]
  #  ]

  # Define the bit lengths for each list (e.g., 2 bits for the first list, 4 bits for the second list)
 # bit_lengths = [8]

  # Run the function
  #process_and_save_weight(lists, bit_lengths, 'weight.txt')

  # Code to download the file in Google Colab
  #files.download('weight.txt')

###
  return