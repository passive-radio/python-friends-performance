import time
import argparse
import logging
from typing import List, Tuple

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

def compute_dot_products(velocities_i: List[Tuple[float, float, float]], 
                        velocities_j: List[Tuple[float, float, float]]) -> List[float]:
    """
    Compute dot products between two lists of 3D velocities.
    
    Args:
        velocities_i: List of (vx, vy, vz) tuples for first set of velocities
        velocities_j: List of (vx, vy, vz) tuples for second set of velocities
    
    Returns:
        List of dot products
    """
    results = []
    for v_i in velocities_i:
        for v_j in velocities_j:
            dot_product = sum(a * b for a, b in zip(v_i, v_j))
            results.append(dot_product)
    return results

def generate_velocities_pairlist(n: int) -> List[Tuple[Tuple[float, float, float], Tuple[float, float, float]]]:
    pairs = []
    for _ in range(n):
        pairs.append((random.random() * 2 - 1, random.random() * 2 - 1, random.random() * 2 - 1))
    return pairs

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", type=int, help="Size of velocity arrays")
    parser.add_argument("--repeat", type=int, default=10)
    parser.add_argument("--log", type=str)
    args = parser.parse_args()

    if args.log:
        logger.addHandler(logging.FileHandler(args.log))
    
    # Generate sample data
    import random
    random.seed(0)
    velocities_i = [(random.uniform(-1, 1), random.uniform(-1, 1), random.uniform(-1, 1)) 
                    for _ in range(args.size)]
    velocities_j = [(random.uniform(-1, 1), random.uniform(-1, 1), random.uniform(-1, 1)) 
                    for _ in range(args.size)]

    logger.info(f"N={args.size} - Pure Python dot product test")

    total_elapsed_time = 0
    for i in range(args.repeat):
        started_at = time.time()
        dot_products = compute_dot_products(velocities_i, velocities_j)
        del dot_products
        elapsed_time = time.time() - started_at
        total_elapsed_time += elapsed_time
        logger.info(f"elapsed_time: {elapsed_time:.4f}s at {i}th iteration")
    
    avg_elapsed_time = total_elapsed_time / args.repeat
    logger.info(f"result size: {len(dot_products)}")
    logger.info(f"avg_elapsed_time: {avg_elapsed_time:.4f}s")
