import cupy as cp
import numpy as np
import time
import argparse
import logging

# Original implementation
def compute_dot_products_original(velocities_i: cp.ndarray, velocities_j: cp.ndarray) -> cp.ndarray:
    N = velocities_i.shape[0]
    M = velocities_j.shape[0]
    
    vi_expanded = velocities_i.reshape(N, 1, 3)
    vj_expanded = velocities_j.reshape(1, M, 3)
    
    dot_products = cp.sum(vi_expanded * vj_expanded, axis=2, dtype=cp.float32)
    return dot_products.ravel()

# Optimization 1: Using matmul
def compute_dot_products_matmul(velocities_i: cp.ndarray, velocities_j: cp.ndarray) -> cp.ndarray:
    """
    Optimized version using matrix multiplication instead of broadcasting
    """
    return cp.matmul(velocities_i, velocities_j.T).ravel()

# Optimization 2: Custom CUDA kernel
dot_product_kernel = cp.RawKernel(r'''
extern "C" __global__ void dot_product_kernel(
    const float* velocities_i,
    const float* velocities_j,
    float* output,
    int N,
    int M
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= N * M) return;
    
    int i = idx / M;
    int j = idx % M;
    
    float sum = 0.0f;
    for (int k = 0; k < 3; k++) {
        sum += velocities_i[i * 3 + k] * velocities_j[j * 3 + k];
    }
    output[idx] = sum;
}
''', 'dot_product_kernel')

def compute_dot_products_cuda_kernel(velocities_i: cp.ndarray, velocities_j: cp.ndarray) -> cp.ndarray:
    """
    Optimized version using custom CUDA kernel
    """
    N, _ = velocities_i.shape
    M, _ = velocities_j.shape
    
    # Ensure contiguous memory layout
    velocities_i = cp.ascontiguousarray(velocities_i, dtype=cp.float32)
    velocities_j = cp.ascontiguousarray(velocities_j, dtype=cp.float32)
    
    # Prepare output array
    output = cp.empty(N * M, dtype=cp.float32)
    
    # Configure grid and block dimensions
    threads_per_block = 256
    blocks_per_grid = (N * M + threads_per_block - 1) // threads_per_block
    
    # Launch kernel
    dot_product_kernel(
        (blocks_per_grid,), 
        (threads_per_block,),
        (velocities_i, velocities_j, output, N, M)
    )
    
    return output

# Benchmark function
def benchmark(func, velocities_i, velocities_j, num_runs=10):
    # Warm-up run
    _ = func(velocities_i, velocities_j)
    cp.cuda.Stream.null.synchronize()
    
    times = []
    for _ in range(num_runs):
        start = time.perf_counter()
        result = func(velocities_i, velocities_j)
        cp.cuda.Stream.null.synchronize()
        end = time.perf_counter()
        times.append(end - start)
    
    return np.mean(times), np.std(times)

# Test and benchmark
def run_benchmarks(base_filename, size: int):
    # Test sizes
    sizes = [size]*2
    
    print("Running benchmarks...")
    print("\nFormat: mean_time ± std_time (seconds)")
    print("-" * 60)
    
    for N, M in sizes:
        print(f"\nArray sizes: {N}x3 and {M}x3")
        
        # Generate random test data
        velocities_i = cp.random.random((N, 3), dtype=cp.float32)
        velocities_j = cp.random.random((M, 3), dtype=cp.float32)
        
        # Benchmark each implementation
        implementations = [
            ("Original", compute_dot_products_original),
            ("Matmul", compute_dot_products_matmul),
            ("CUDA Kernel", compute_dot_products_cuda_kernel)
        ]
        
        for name, func in implementations:
            mean_time, std_time = benchmark(func, velocities_i, velocities_j)
            print(f"{name:12}: {mean_time:.6f} ± {std_time:.6f}")
            
            # Verify results match original implementation
            if name != "Original":
                result = func(velocities_i, velocities_j)
                original_result = compute_dot_products_original(velocities_i, velocities_j)
                max_diff = cp.max(cp.abs(result - original_result))
                print(f"{' '*12}  Max difference from original: {max_diff}")

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
    velocities_i = cp.random.uniform(-1, 1, (args.size, 3), dtype=cp.float32)
    velocities_j = cp.random.uniform(-1, 1, (args.size, 3), dtype=cp.float32)
    run_benchmarks()