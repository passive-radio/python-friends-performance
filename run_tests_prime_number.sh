#!/bin/bash

## run tests for find prime number

### Python tests
for n in 100000 1000000; do
    echo "n: $n"
    python find_prime_number/pure_python/pure_python.py --start 2 --end $n --repeat 10 --log "out/find_prime_number/pure_python_${n}.log"
    python find_prime_number/numpy/numpy_python.py --start 2 --end $n --repeat 10 --log "out/find_prime_number/numpy_${n}.log"
    python find_prime_number/numpy/numpy_python2.py --start 2 --end $n --repeat 10 --log "out/find_prime_number/numpy2_${n}.log"
    # python src/cupy/cupy.py --start 2 --end $n --repeat 10 --log "out/cupy_${n}.log"
done

### Codon tests
for n in 100000 1000000; do
    echo "n: $n"
    # codon run src/codon/codon.py --start 2 --end $n --repeat 10 --log "out/codon_${n}.log"
done

### Codon tests (pre compiled executable)
for n in 100000 1000000; do
    echo "n: $n"
    # todo: build and run an executable
done

### Native C++ tests
for n in 100000 1000000; do
    echo "n: $n"
    # todo: build and run an executable
done

### Cython tests
for n in 100000 1000000; do
    echo "n: $n"
    # todo: build and run an executable
done
