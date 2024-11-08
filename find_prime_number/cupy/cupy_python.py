import cupy as cp
import numpy as np
import time
import argparse
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

def is_prime(n: int) -> bool:
    # todo
    pass

def count_primes(start: int, end: int) -> int:
    # todo
    pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", type=int)
    parser.add_argument("--end", type=int)
    parser.add_argument("--repeat", type=int, default=10)
    parser.add_argument("--log", type=str)
    args = parser.parse_args()
    
    logger.addHandler(logging.FileHandler(args.log))
    logger.info(f"N={args.end} - Cupy array test")
