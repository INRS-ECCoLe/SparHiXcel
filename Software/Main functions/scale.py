import numpy as np
import math

def scale(x, bitwidth, sign):

  z = 0

  if(sign):
    s = 2 * max(np.abs(np.max(x)),np.abs(np.min(x))) /(2**bitwidth-1)

  else:
    s = np.max(np.abs(x))/(2**bitwidth-1)

  return s,z