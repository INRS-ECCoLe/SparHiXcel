import numpy as np


def quantize(x,s,z,b, sign):
  if (sign):
    min= -(2**(b-1))
    max= (2**(b-1))-1
  else:
    min=0
    max= (2**b)-1

  x_int= np.clip(np.round(x/s)+z, min, max).astype(np.int32)
  return x_int