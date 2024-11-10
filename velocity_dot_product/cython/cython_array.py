import time
import argparse
import random
from cython_array import compute_dot_products_py as compute_dot_products

def write_log(log_file: str, message: str) -> None:
    with open(log_file, "a") as f:
        f.write(message + "\n")

def generate_sample_data(n: int):
    velocities_i = [[random.random() * 2 - 1, random.random() * 2 - 1, random.random() * 2 - 1]
                    for _ in range(n)]
    velocities_j = [[random.random() * 2 - 1, random.random() * 2 - 1, random.random() * 2 - 1]
                    for _ in range(n)]
    return velocities_i, velocities_j

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", type=int, help="Size of velocity arrays")
    parser.add_argument("--repeat", type=int, default=30)
    parser.add_argument("--log", type=str)
    args = parser.parse_args()

    log_file = str(args.log)
    velocities_i, velocities_j = generate_sample_data(args.size)
    total_elapsed_time = 0.0
    
    for i in range(args.repeat):
        start_time = time.time()
        results = compute_dot_products(velocities_i, velocities_j)
        elapsed_time = time.time() - start_time
        total_elapsed_time += elapsed_time
        write_log(log_file, f"elapsed_time: {elapsed_time}s at {i}th iteration")
        print(f"elapsed_time: {elapsed_time}s at {i}th iteration")
        del results
    
    avg_elapsed_time = total_elapsed_time / 30
    write_log(log_file, f"avg_elapsed_time: {avg_elapsed_time}s")
    print(f"avg_elapsed_time: {avg_elapsed_time}s")

if __name__ == "__main__":
    main()
