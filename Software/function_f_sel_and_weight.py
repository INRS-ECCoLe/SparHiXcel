def function_f_sel_and_weight(f_s, f_sels, weights_array, weights, remaining_array, full_array, filter_s):

  for ch in range(len(f_sels)):

    if len(f_sels[ch]) != 0:

      target_row = filter_s*ch

      for i in range(f_sels[ch].shape[0]) :

        for j in range(f_sels[ch].shape[1]):

          f_s[target_row + i, int(full_array[target_row + i, 0] - remaining_array[target_row + i, 0]) + j] = f_sels[ch][i, j]
          weights_array[target_row + i, int(full_array[target_row + i, 0] - remaining_array[target_row + i, 0]) + j] = weights[ch][i, j]

  return f_s, weights_array