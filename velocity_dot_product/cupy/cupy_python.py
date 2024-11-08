import cupy as cp
import time
import argparse
import logging
from typing import Tuple

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

def compute_dot_products(velocities_i: cp.ndarray, velocities_j: cp.ndarray) -> cp.ndarray:
    """
    Compute dot products between two arrays of 3D velocities using cupy on GPU.
    
    Args:
        velocities_i: CuPy array of shape (N, 3) containing first set of velocities
        velocities_j: CuPy array of shape (M, 3) containing second set of velocities
    
    Returns:
        CuPy array of shape (N*M,) containing all dot products
    """
    # Reshape velocities_i to (N, 1, 3) and velocities_j to (1, M, 3)
    # This enables broadcasting for efficient computation on GPU
    vi_expanded = velocities_i[:, cp.newaxis, :]
    vj_expanded = velocities_j[cp.newaxis, :, :]
    
    # Compute dot products using cupy's sum along last axis
    # Result will be of shape (N, M)
    dot_products = cp.sum(vi_expanded * vj_expanded, axis=2)
    
    # Flatten the result to match the other implementations
    return dot_products.flatten()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", type=int, help="Size of velocity arrays")
    parser.add_argument("--repeat", type=int, default=10)
    parser.add_argument("--log", type=str)
    args = parser.parse_args()

    if args.log:
        logger.addHandler(logging.FileHandler(args.log))
    
    # Generate sample data using cupy (using same seed for consistency)
    cp.random.seed(0)
    velocities_i = cp.random.uniform(-1, 1, (args.size, 3))
    velocities_j = cp.random.uniform(-1, 1, (args.size, 3))

    # Warm up GPU to ensure timing is fair
    _ = compute_dot_products(velocities_i[:100], velocities_j[:100])
    cp.cuda.Stream.null.synchronize()

    logger.info(f"N={args.size} - CuPy GPU dot product test")

    total_elapsed_time = 0
    for i in range(args.repeat):
        # Ensure GPU is synchronized before starting timer
        cp.cuda.Stream.null.synchronize()
        started_at = time.time()
        
        dot_products = compute_dot_products(velocities_i, velocities_j)
        
        # Ensure GPU computation is complete before stopping timer
        cp.cuda.Stream.null.synchronize()
        elapsed_time = time.time() - started_at
        total_elapsed_time += elapsed_time
        logger.info(f"elapsed_time: {elapsed_time:.4f}s at {i}th iteration")
    
    avg_elapsed_time = total_elapsed_time / args.repeat
    logger.info(f"result size: {len(dot_products)}")
    logger.info(f"avg_elapsed_time: {avg_elapsed_time:.4f}s")
