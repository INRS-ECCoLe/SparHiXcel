import numpy as np

def filter_assign (f_weights_sorted_2D, near_zero_threshold , filter_s):

  num_non_zero_per_row = np.sum( np.abs(f_weights_sorted_2D) > near_zero_threshold, axis=1)
  max_num_non_zero_per_row = np.max(num_non_zero_per_row)
  num_of_col = max_num_non_zero_per_row * np.ones((f_weights_sorted_2D.shape[0],1))
  num_col_removed = filter_s - max_num_non_zero_per_row
  if max_num_non_zero_per_row != 0:

    index = np.full((f_weights_sorted_2D.shape[0],max_num_non_zero_per_row), np.nan)
    f_sel = (filter_s - 1)*np.ones((f_weights_sorted_2D.shape[0],max_num_non_zero_per_row))
    weight = np.zeros((f_weights_sorted_2D.shape[0],max_num_non_zero_per_row))
    count_r=0
    count_c=0

    for Row in range(f_weights_sorted_2D.shape[0]):

      for Col in range(f_weights_sorted_2D.shape[1]):

        if np.abs(f_weights_sorted_2D[Row, Col]) > near_zero_threshold :

          index[count_r, count_c] = Row*f_weights_sorted_2D.shape[0] + Col
          f_sel[count_r, count_c] = filter_s - 1 - (index[count_r, count_c] - count_r * f_weights_sorted_2D.shape[0] - count_c)
          weight[count_r, count_c] = f_weights_sorted_2D[Row, Col]
          count_c+=1

      count_r+=1
      count_c = 0

  else:

    index = []
    f_sel = []
    weight = []
  return num_of_col, index, f_sel, weight, num_col_removed