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
    return sum(is_prime(n) for n in range(start, end))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", type=int)
    parser.add_argument("--end", type=int)
    parser.add_argument("--repeat", type=int, default=10)
    parser.add_argument("--log", type=str)
    args = parser.parse_args()


    logger.addHandler(logging.FileHandler(args.log))
    logger.info(f"N={args.end} - Pure Python loop test")

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
