"""Numpy version of prime number counting program."""

import numpy as np
import time
import argparse
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

def is_prime(n: int) -> bool:
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def count_primes(start: int, end: int) -> int:
    # efficient prime counting using numpy
    if start < 2:
        start = 2
    
    # Create a boolean array initialized as all True
    prime_array = np.ones(end - start, dtype=bool)
    
    # Handle edge cases
    if start <= 2:
        # Mark 2 as prime if in range
        prime_array[0] = True
    
    # Create array of numbers we're checking
    numbers = np.arange(start, end)
    
    # Handle small numbers and even numbers
    mask = (numbers <= 1) | ((numbers > 2) & (numbers % 2 == 0))
    prime_array[mask] = False
    
    # Check only up to square root of end
    for i in range(3, int(np.sqrt(end)) + 1, 2):
        if i >= start:
            # If the number itself is in our range, mark it according to is_prime()
            idx = i - start
            prime_array[idx] = is_prime(i)
        
        # Find first multiple of i that's >= start
        first_multiple = max(i * i, ((start + i - 1) // i) * i)
        
        # Mark all odd multiples of i as non-prime
        if first_multiple < end:
            # Calculate indices for multiples
            multiples_idx = np.arange(first_multiple, end, i) - start
            prime_array[multiples_idx[multiples_idx >= 0]] = False
    
    return np.sum(prime_array)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", type=int)
    parser.add_argument("--end", type=int)
    parser.add_argument("--repeat", type=int, default=10)
    parser.add_argument("--log", type=str)
    args = parser.parse_args()


    logger.addHandler(logging.FileHandler(args.log))
    logger.info(f"N={args.end} - Numpy array test")

    total_elapsed_time = 0
    for i in range(args.repeat):
        started_at = time.time()
        cnt_primes = count_primes(args.start, args.end)
        elapsed_time = time.time() - started_at
        total_elapsed_time += elapsed_time
        logger.info(f"elapsed_time: {elapsed_time:.4f}s at {i}th iteration")
    avg_elapsed_time = total_elapsed_time / args.repeat
    logger.info(f"cnt_primes: {cnt_primes}")
    logger.info(f"avg_elapsed_time: {avg_elapsed_time:.4f}s")
