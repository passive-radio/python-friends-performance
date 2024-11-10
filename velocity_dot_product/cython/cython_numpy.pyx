# distutils: extra_compile_args = -fopenmp
# distutils: extra_link_args = -fopenmp
# cython: language_level=3
# cython: boundscheck=False
# distutils: language = c++
# cython: wraparound=False
# cython: cdivision=True

import numpy as np
cimport numpy as np
from cython.parallel import prange
from libc.stdlib cimport malloc, free
from cython.parallel cimport parallel

ctypedef float DTYPE_t

# Define a public wrapper function that Python code can call
def compute_dot_products_py(list velocities_i, list velocities_j):
    # Convert input lists to numpy arrays
    cdef np.ndarray[DTYPE_t, ndim=2] vel_i = np.array(velocities_i, dtype=np.float32)
    cdef np.ndarray[DTYPE_t, ndim=2] vel_j = np.array(velocities_j, dtype=np.float32)
    return compute_dot_products(vel_i, vel_j).tolist()

# Define the core computation as a cdef function
# @cython.boundscheck(False)
# @cython.wraparound(False)
cdef np.ndarray[DTYPE_t, ndim=1] compute_dot_products(np.ndarray[DTYPE_t, ndim=2] vel_i, 
                                                    np.ndarray[DTYPE_t, ndim=2] vel_j):
    cdef int n = vel_i.shape[0]
    cdef int m = vel_j.shape[0]
    cdef Py_ssize_t i, j
    cdef float vix, viy, viz, vjx, vjy, vjz
    
    # Create memory views for nogil operation
    cdef float[:, :] vel_i_view = vel_i
    cdef float[:, :] vel_j_view = vel_j
    cdef float[:] results_view = np.zeros(n * m, dtype=np.float32)
    
    with nogil:
        for i in prange(n, schedule='static', num_threads=16, chunksize=10):
            vix = vel_i_view[i, 0]
            viy = vel_i_view[i, 1]
            viz = vel_i_view[i, 2]
            
            for j in range(m):  # Remove prange from inner loop
                vjx = vel_j_view[j, 0]
                vjy = vel_j_view[j, 1]
                vjz = vel_j_view[j, 2]
                
                results_view[i * m + j] = vix * vjx + viy * vjy + viz * vjz
    
    return np.asarray(results_view)