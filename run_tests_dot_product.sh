#!/bin/bash

# You need to set the path to the Python shared object file for Codon to use.
# export CODON_PYTHON=~/.pyenv/versions/3.11.9/lib/libpython3.11.soD


## run tests for velocity dot product

mkdir -p out/velocity_dot_product

### Python(Numpy) tests
echo "Python(Numpy) tests"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     # OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_1.log"
#     # OPENBLAS_NUM_THREADS=2 OMP_NUM_THREADS=2 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_par2.log"
#     # OPENBLAS_NUM_THREADS=4 OMP_NUM_THREADS=4 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_par4.log"
#     OPENBLAS_NUM_THREADS=8 OMP_NUM_THREADS=8 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_par8.log"
#     OPENBLAS_NUM_THREADS=12 OMP_NUM_THREADS=12 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_par12.log"
#     # OPENBLAS_NUM_THREADS=16 OMP_NUM_THREADS=16 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_16.log"
# done

### Pure Python tests
echo "Pure Python tests"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     python velocity_dot_product/pure_python/pure_python.py --size $n --repeat 10 --log "out/velocity_dot_product/pure_python_${n}.log"
# done

### Cupy tests
echo "Cupy tests"
for n in 100 1000 10000 14000; do
    echo "n: $n"
    # python velocity_dot_product/cupy/cupy_python.py --size $n --repeat 10 --log "out/velocity_dot_product/cupy_${n}.log"
done

### Codon tests
echo "Codon tests (No release optimization option)"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     codon run velocity_dot_product/codon/codon_python.py --size $n --repeat 30 --log "out/velocity_dot_product/codon_${n}_par12.log"
# done

echo "Codon tests (release optimization option)"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     codon run --release velocity_dot_product/codon/codon_python.py --size $n --repeat 30 --log "out/velocity_dot_product/codon_${n}_release_par12.log"
# done

### Codon tests (pre compiled executable)
echo "Codon tests (pre compiled executable)"
for n in 100 1000 10000 14000; do
    echo "n: $n"
    # todo: build and run an executable
done

### Native C++ tests
echo "Native C++ tests"
for n in 100 1000 10000 14000; do
    echo "n: $n"
    # todo: build and run an executable
done

### Cython tests
echo "Cython tests"
for n in 100 1000 10000 14000; do
    echo "n: $n"
    python velocity_dot_product/cython/cython_version.py --size $n --repeat 30 --log "out/velocity_dot_product/cython_${n}_par12.log"
done
