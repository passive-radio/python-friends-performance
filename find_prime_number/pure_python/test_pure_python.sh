#!/bin/bash

for n in 1000 10000 20000 30000 100000; do
    echo "n: $n"
    python src/pure_python/pure_python.py --start 2 --end $n --repeat 10
done
