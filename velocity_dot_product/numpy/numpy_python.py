import numpy as np
import time
import argparse
import logging
from threadpoolctl import threadpool_info
from typing import Tuple

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

def compute_dot_products(velocities_i: np.ndarray, velocities_j: np.ndarray) -> np.ndarray:
    """
    Compute dot products between two arrays of 3D velocities using numpy.
    
    Args:
        velocities_i: Array of shape (N, 3) containing first set of velocities
        velocities_j: Array of shape (M, 3) containing second set of velocities
    
    Returns:
        Array of shape (N*M,) containing all dot products
    """
    # Reshape velocities_i to (N, 1, 3) and velocities_j to (1, M, 3)
    # This enables broadcasting for efficient computation
    vi_expanded = velocities_i[:, np.newaxis, :]
    vj_expanded = velocities_j[np.newaxis, :, :]
    
    # Compute dot products using numpy's sum along last axis
    # Result will be of shape (N, M)
    dot_products = np.sum(vi_expanded * vj_expanded, axis=2)
    
    # Flatten the result to match the pure Python implementation
    return dot_products.flatten()

if __name__ == "__main__":
    print(threadpool_info())
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", type=int, help="Size of velocity arrays")
    parser.add_argument("--repeat", type=int, default=10)
    parser.add_argument("--log", type=str)
    args = parser.parse_args()

    if args.log:
        logger.addHandler(logging.FileHandler(args.log))
    
    # Generate sample data using numpy (using same seed for consistency)
    np.random.seed(0)
    velocities_i = np.random.uniform(-1, 1, (args.size, 3))
    velocities_j = np.random.uniform(-1, 1, (args.size, 3))

    logger.info(f"N={args.size} - Numpy dot product test")

    total_elapsed_time = 0
    for i in range(args.repeat):
        started_at = time.time()
        dot_products = compute_dot_products(velocities_i, velocities_j)
        elapsed_time = time.time() - started_at
        total_elapsed_time += elapsed_time
        logger.info(f"elapsed_time: {elapsed_time:.4f}s at {i}th iteration")
        
        del dot_products
    
    avg_elapsed_time = total_elapsed_time / args.repeat
    # logger.info(f"result size: {len(dot_products)}")
    logger.info(f"avg_elapsed_time: {avg_elapsed_time:.4f}s")
