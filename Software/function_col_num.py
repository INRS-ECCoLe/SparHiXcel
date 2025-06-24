def function_col_num(n_columns, num_of_col, remaining_array, full_array):

  for i in range(int(num_of_col.shape[0])):

    filled_array = full_array - remaining_array

    for j in range(int(num_of_col[i, 0])):

      n_columns[i, int(filled_array[i, 0]) + j] = num_of_col[i, 0]

  return n_columns