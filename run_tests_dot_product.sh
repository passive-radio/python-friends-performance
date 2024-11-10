#!/bin/bash

# You need to set the path to the Python shared object file for Codon to use.
# export CODON_PYTHON=~/.pyenv/versions/3.11.9/lib/libpython3.11.soD

out_dir="$BASE_DIR/out/velocity_dot_product"

## run tests for velocity dot product

mkdir -p out/velocity_dot_product

### Python(Numpy) tests
echo "Python(Numpy) tests"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}.log"
#     # OPENBLAS_NUM_THREADS=2 OMP_NUM_THREADS=2 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_par2.log"
#     # OPENBLAS_NUM_THREADS=4 OMP_NUM_THREADS=4 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_par4.log"
#     OPENBLAS_NUM_THREADS=8 OMP_NUM_THREADS=8 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_par8.log"
#     OPENBLAS_NUM_THREADS=12 OMP_NUM_THREADS=12 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_par12.log"
#     OPENBLAS_NUM_THREADS=16 OMP_NUM_THREADS=16 python velocity_dot_product/numpy/numpy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/numpy_${n}_16.log"
# done

### Pure Python tests
echo "Pure Python tests"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     python velocity_dot_product/pure_python/pure_python.py --size $n --repeat 10 --log "out/velocity_dot_product/pure_python_${n}.log"
# done

### Cupy tests
echo "Cupy tests"
for n in 100 1000 10000 14000 40000; do
    echo "n: $n"
    python velocity_dot_product/cupy/cupy_python.py --size $n --repeat 30 --log "out/velocity_dot_product/cupy"
done

### Codon tests
echo "Codon tests (No release optimization option)"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     codon run velocity_dot_product/codon/codon_python.py --size $n --repeat 30 --log "out/velocity_dot_product/codon_${n}_par8.log"
# done

echo "Codon tests (release optimization option)"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     codon run --release velocity_dot_product/codon/codon_python.py --size $n --repeat 30 --log "out/velocity_dot_product/codon_${n}_release_par8.log"
# done

### Codon tests (gpu)
echo "Codon tests (gpu)"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     codon run -libdevice /usr/lib/nvidia-cuda-toolkit/libdevice/libdevice.10.bc --release velocity_dot_product/codon/codon_gpu.py --size $n --repeat 30 --log "out/velocity_dot_product/codon_${n}_release_gpu.log"
# done

### Native C++ tests
echo "Native C++ tests"
for n in 100 1000 10000 14000; do
    echo "n: $n"
    # todo: build and run an executable
done

### Cython tests
echo "Cython (first: Numpy, second: std::array) tests"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     python velocity_dot_product/cython/cython_numpy.py --size $n --repeat 30 --log "out/velocity_dot_product/cython_numpy_${n}_par16_static_chunk10.log"
#     python velocity_dot_product/cython/cython_array.py --size $n --repeat 30 --log "out/velocity_dot_product/cython_array_${n}_par16_static_chunk10.log"
# done

### Mojo tests
echo "Mojo (non simd non parallel) tests"
# for n in 100 1000 10000 14000; do
#     echo "n: $n"
#     cd $BASE_DIR/velocity_dot_product/mojo
#     magic run mojo mojo_non_simd.mojo $n 30 "${out_dir}/mojo_simple_${n}.log"
# done

### Mojo tests
echo "Mojo (simd, parallel) tests"
for n in 100 1000 10000 14000; do
    echo "n: $n"
    cd $BASE_DIR/velocity_dot_product/mojo
    # magic run mojo mojo_simd_parallel.mojo $n 30 "${out_dir}/mojo_${n}_simd_par1.log" 1
    # magic run mojo mojo_simd_parallel.mojo $n 100 "${out_dir}/mojo_${n}_simd_par2.log" 2
    # magic run mojo mojo_simd_parallel.mojo $n 100 "${out_dir}/mojo_${n}_simd_par4.log" 4
    # magic run mojo mojo_simd_parallel.mojo $n 100 "${out_dir}/mojo_${n}_simd_par8.log" 8
    # magic run mojo mojo_simd_parallel.mojo $n 100 "${out_dir}/mojo_${n}_simd_par12.log" 12
    # magic run mojo mojo_simd_parallel.mojo $n 100 "${out_dir}/mojo_${n}_simd_par16.log" 16

done
