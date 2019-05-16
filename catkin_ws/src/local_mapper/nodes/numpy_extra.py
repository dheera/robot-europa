#!/usr/bin/env python3

"""
Extra functions that should probably have been features of numpy.
"""

import numpy as np
import numba as nb

@nb.jit(nopython=True)
def denoise_fill_nan(arr):
    out = arr.copy()
    for row_idx in range(out.shape[0]):
        for col_idx in range(1, out.shape[1]):
            if np.isnan(out[row_idx, col_idx]):
                out[row_idx, col_idx] = arr[row_idx, col_idx - 1]
            if np.isnan(out[row_idx, col_idx]):
                out[row_idx, col_idx] = arr[row_idx - 1, col_idx]

            if out[row_idx - 1, col_idx] == out[row_idx + 1, col_idx] and \
                out[row_idx - 1, col_idx] == out[row_idx, col_idx + 1] and \
                out[row_idx - 1, col_idx] == out[row_idx, col_idx - 1] and \
                out[row_idx - 1, col_idx] != out[row_idx, col_idx]:
                out[row_idx, col_idx] = out[row_idx - 1, col_idx]

    return out

def weighted_median(data, weights):
    """
    Args:
      data (list or numpy.array): data
      weights (list or numpy.array): weights
    """
    data, weights = np.array(data).squeeze(), np.array(weights).squeeze()
    s_data, s_weights = map(np.array, zip(*sorted(zip(data, weights))))
    w_idx = -1
    midpoint = 0.5 * sum(s_weights)
    if any(weights > midpoint):
        w_median = (data[weights == np.max(weights)])[0]
    else:
        cs_weights = np.cumsum(s_weights)
        idx = np.where(cs_weights <= midpoint)[0][-1]
        if cs_weights[idx] == midpoint:
            w_median = np.mean(s_data[idx:idx+2])
            w_idx = idx + 0.5
        else:
            w_median = s_data[idx+1]
            w_idx = idx + 1
    return w_idx, w_median

@nb.jit(nopython=True)
def erode(arr, value = 0, radius = 1):
    out = arr.copy()
    for row_idx in range(radius, out.shape[0] - radius):
        for col_idx in range(radius, out.shape[1] - radius):
            if arr[row_idx, col_idx] == value:
                for i in range(-radius, radius + 1):
                    for j in range(-radius, radius + 1):
                        out[row_idx + i, col_idx + j] = value
    return out

@nb.jit(nopython=True)
def denoise_fill_value(arr, value = 0, passes = 1, radius = 1):
    out = arr.copy()
    for c in range(passes):
      for row_idx in range(radius, out.shape[0] - radius):
        for col_idx in range(radius, out.shape[1] - radius):
            if arr[row_idx, col_idx] != value:
                for i in range(-radius, radius + 1):
                    for j in range(-radius, radius + 1):
                        if arr[row_idx + i, col_idx + j] == value:
                            out[row_idx + i, col_idx + j] = arr[row_idx, col_idx]

    return out

def shift_2d_replace(data, dx, dy, constant=False):
    """
    Shifts the array in two dimensions while setting rolled values to constant
    :param data: The 2d numpy array to be shifted
    :param dx: The shift in x
    :param dy: The shift in y
    :param constant: The constant to replace rolled values with
    :return: The shifted array with "constant" where roll occurs
    """
    shifted_data = np.roll(data, dx, axis=1)
    if dx < 0:
        shifted_data[:, dx:] = constant
    elif dx > 0:
        shifted_data[:, 0:np.abs(dx)] = constant

    shifted_data = np.roll(shifted_data, dy, axis=0)
    if dy < 0:
        shifted_data[dy:, :] = constant
    elif dy > 0:
        shifted_data[0:np.abs(dy), :] = constant
    return shifted_data
