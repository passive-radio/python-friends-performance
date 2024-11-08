import time
import random
from python import argparse
from python import sys as pysys
import sys
# from python import sys
# import sys
# from random import random, seed
# from typing import List, Tuple

@python
def write_log(log_file: str, message: str) -> None:
    with open(log_file, "a") as f:
        f.write(message + "\n")

def compute_dot_products(velocities_i: list[tuple[float, float, float]], 
    velocities_j: list[tuple[float, float, float]]) -> list[float]:
    n = len(velocities_i)
    m = len(velocities_j)
    results = [0.0] * (n * m)
    
    idx = 0
    @par(num_threads=12)
    for i in range(n):
        vix, viy, viz = velocities_i[i]
        for j in range(m):
            vjx, vjy, vjz = velocities_j[j]
            results[idx] = vix * vjx + viy * vjy + viz * vjz
            idx += 1
    
    return results

def generate_sample_data(n: int):
    # generate random velocities
    
    velocities_i = [(random.random() * 2 - 1, random.random() * 2 - 1, random.random() * 2 - 1) 
                    for _ in range(n)]
    velocities_j = [(random.random() * 2 - 1, random.random() * 2 - 1, random.random() * 2 - 1) 
                    for _ in range(n)]
    return velocities_i, velocities_j

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", help="Size of velocity arrays")
    parser.add_argument("--repeat", help="Number of iterations")
    parser.add_argument("--log", help="Log file")
    args = parser.parse_args(sys.argv[1:])
    
    print(args)

    n = int(args.size)
    repeat = int(args.repeat)
    log_file = str(args.log)
    velocities_i, velocities_j = generate_sample_data(n)
    total_elapsed_time = 0.0
    
    for i in range(repeat):
        start_time = time.time()
        results = compute_dot_products(velocities_i, velocities_j)
        elapsed_time = time.time() - start_time
        total_elapsed_time += elapsed_time
        write_log(log_file, f"elapsed_time: {elapsed_time}s at {i}th iteration")
        print(f"elapsed_time: {elapsed_time}s at {i}th iteration")
        del results
    
    avg_elapsed_time = total_elapsed_time / repeat
    write_log(log_file, f"avg_elapsed_time: {avg_elapsed_time}s")
    print(f"avg_elapsed_time: {avg_elapsed_time}s")