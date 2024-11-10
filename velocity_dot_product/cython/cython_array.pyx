# distutils: extra_compile_args = -fopenmp
# distutils: extra_link_args = -fopenmp
# distutils: language=c++
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True

from libcpp.vector cimport vector
from cython.parallel import prange
# import numpy as np
cimport numpy as np
# from cython.parallel cimport parallel

# Python向けのラッパー関数
def compute_dot_products_py(list velocities_i, list velocities_j):
    # 入力リストをvectorに変換
    cdef vector[vector[float]] vel_i = convert_to_vector(velocities_i)
    cdef vector[vector[float]] vel_j = convert_to_vector(velocities_j)
    cdef vector[float] results = compute_dot_products(vel_i, vel_j)
    return list(results)

# リストをvectorに変換するヘルパー関数
cdef vector[vector[float]] convert_to_vector(list velocities):
    cdef vector[vector[float]] result
    cdef vector[float] temp
    cdef int i, j
    cdef list vel
    
    result.resize(len(velocities))
    for i in range(len(velocities)):
        vel = velocities[i]
        temp.resize(len(vel))
        for j in range(len(vel)):
            temp[j] = vel[j]
        result[i] = temp
    return result

# コア計算関数
cdef vector[float] compute_dot_products(vector[vector[float]]& vel_i, 
                                      vector[vector[float]]& vel_j):
    cdef size_t n = vel_i.size()
    cdef size_t m = vel_j.size()
    cdef vector[float] results
    results.resize(n * m)
    
    cdef size_t i, j
    cdef float vix, viy, viz, vjx, vjy, vjz

    with nogil:        
        for i in prange(n, schedule='static', num_threads=16, chunksize=10):
            vix = vel_i[i][0]
            viy = vel_i[i][1]
            viz = vel_i[i][2]
            
            for j in range(m):
                vjx = vel_j[j][0]
                vjy = vel_j[j][1]
                vjz = vel_j[j][2]
                
                results[i * m + j] = vix * vjx + viy * vjy + viz * vjz
        
    return results