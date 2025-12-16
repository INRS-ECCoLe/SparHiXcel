
import numpy as np
import math


def allocate_mux_tran (num_of_col, remaining_array, full_array, sel_mux_tr, result_col, en_adder_node, filter_num, filter_s, filled_array_prev):
  filled_array = full_array - remaining_array
  max_col = int(np.max(filled_array)) # eshtebahe
  last_non_zero_index = int(np.argmax(result_col))
  if np.any(filled_array != filled_array_prev):
    if np.all(result_col ==0):
      selected_col =  max_col - 1
      result_col[0, selected_col] = filter_num + 1
    elif (last_non_zero_index < max_col - 1):
      selected_col =  max_col - 1
      result_col[0, selected_col] = filter_num + 1
    else:
      selected_col =  last_non_zero_index + 1
      result_col[0, selected_col] = filter_num + 1
      for i in range(math.floor(full_array.shape[0]/filter_s)):

        if(num_of_col[(filter_s*(i+1)) - 1, 0] != 0):
          sel_mux_tr[(filter_s*(i+1)) - 1 , selected_col] =  max_col - filled_array [(filter_s*(i+1)) - 1, 0]
          en_adder_node [(filter_s*(i+1)) - 1 , selected_col] = 1
  return sel_mux_tr,  result_col, en_adder_node, filled_array