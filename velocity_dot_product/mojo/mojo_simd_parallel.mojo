from python import Python
import benchmark
from benchmark import Unit
from random import random_float64
from math import sqrt
from time import sleep
from sys.info import simdwidthof
from collections.list import List
from collections.inline_array import InlineArray
from random import random_float64
from algorithm import parallelize
from memory import UnsafePointer, memset_zero
from sys.info import simdwidthof
import math
from time import perf_counter_ns
from sys import argv, num_physical_cores
# from DType import DType
# from memory.unsafe import Pointer

fn write_log(log_file: String, message: String) raises -> None:
    builtins = Python.import_module("builtins")
    f = builtins.open(log_file, "a")
    f.write(message + "\n")
    f.close()

struct Velocity(CollectionElement):
    var x: Float32
    var y: Float32
    var z: Float32
    
    fn __init__(inout self, x: Float32, y: Float32, z: Float32):
        self.x = x
        self.y = y
        self.z = z
    
    fn __copyinit__(inout self, other: Self):
        self.x = other.x
        self.y = other.y
        self.z = other.z
    
    fn __moveinit__(inout self, owned other: Self):
        self.x = other.x
        self.y = other.y
        self.z = other.z
    
    fn dot(self, other: Velocity) -> Float32:
        return self.x * other.x + self.y * other.y + self.z * other.z

struct DotProductMatrix:
    var data: UnsafePointer[Float32]
    var rows: Int
    var cols: Int

    fn __init__(inout self, rows: Int, cols: Int):
        self.rows = rows
        self.cols = cols
        self.data = UnsafePointer[Float32].alloc(rows * cols)
    
    fn __copyinit__(inout self, other: Self):
        self.rows = other.rows
        self.cols = other.cols
        self.data = other.data
    
    fn __moveinit__(inout self, owned other: Self):
        self.rows = other.rows
        self.cols = other.cols
        self.data = other.data
    
    fn store[nelts: Int](self, row: Int, col: Int, val: SIMD[DType.float32, nelts]):
        self.data.store[width=nelts](row * self.cols + col, val)
    
    fn free(self):
        self.data.free()
    
    fn load[nelts: Int](self, row: Int, col: Int) -> SIMD[DType.float32, nelts]:
        return self.data.load[width=nelts](row*self.cols + col)
    
    fn zeros(inout self):
        memset_zero(self.data, self.rows*self.cols)

fn compute_dot_products_parallel(velocities_i: List[Velocity], 
                               velocities_j: List[Velocity], threads: Int):
    var n = len(velocities_i)
    var m = len(velocities_j)
    
    # SIMDのグループサイズを設定
    alias nelts = simdwidthof[DType.float32]()
    var results_ptr = UnsafePointer[Float32]().alloc(n * m)
    
    # 結果を0で初期化
    memset_zero(results_ptr, n * m)
    
    @parameter
    fn worker(row: Int, v_i: Velocity, results: UnsafePointer[Float32], 
             v_j_x: UnsafePointer[Float32], v_j_y: UnsafePointer[Float32], 
             v_j_z: UnsafePointer[Float32], cols: Int):
        # 各行（velocity_i）に対して
        for col in range(0, cols, nelts):
            var x = SIMD[DType.float32, nelts]()
            var y = SIMD[DType.float32, nelts]()
            var z = SIMD[DType.float32, nelts]()
            
            # SIMDでvelocity_jの要素をロード
            x = v_j_x.load[width=nelts](col)
            y = v_j_y.load[width=nelts](col)
            z = v_j_z.load[width=nelts](col)
            
            # ドット積を計算
            var dot = x * v_i.x + y * v_i.y + z * v_i.z
            
            # 結果を保存
            results.store[width=nelts](row * cols + col, dot)
    
    # velocity_jのコンポーネントを別々の配列に分離
    var v_j_x = UnsafePointer[Float32]().alloc(m)
    var v_j_y = UnsafePointer[Float32]().alloc(m)
    var v_j_z = UnsafePointer[Float32]().alloc(m)
    
    for j in range(m):
        v_j_x.store(j, velocities_j[j].x)
        v_j_y.store(j, velocities_j[j].y)
        v_j_z.store(j, velocities_j[j].z)
    
    @parameter
    fn parallel_worker(i: Int):
        worker(i, velocities_i[i], results_ptr, v_j_x, v_j_y, v_j_z, m)
    
    # 並列処理を実行
    parallelize[parallel_worker](n, 4)
    
    # 結果をListに変換
    # var results = List[Float32]()
    # for i in range(n * m):
    #     results.append(results_ptr.load(i))
    
    # メモリ解放
    results_ptr.free()
    v_j_x.free()
    v_j_y.free()
    v_j_z.free()
    
    # return results

fn generate_random_velocities(size: Int) -> List[Velocity]:
    var velocities = List[Velocity]()
    for _ in range(size):
        var x = random_float64(-1.0, 1.0).cast[DType.float32]()
        var y = random_float64(-1.0, 1.0).cast[DType.float32]()
        var z = random_float64(-1.0, 1.0).cast[DType.float32]()
        var velocity = Velocity(x, y, z)
        velocities.append(velocity)
    return velocities

fn benchmark_dot_products(size: Int, repeat: Int, out: String, threads: Int) raises:
    # Generate sample data
    var velocities_i = generate_random_velocities(size)
    var velocities_j = generate_random_velocities(size)

    print("calculating started")

    # @parameter
    # fn compute():
    #     _ = compute_dot_products_parallel(velocities_i, velocities_j)

    # var report = benchmark.run[compute](2)
    # print("N=", size, " - Mojo dot product test")
    # avg_time_text = "avg_elapsed_time: " + str(report.mean("s")) + "s"
    # write_log(out, avg_time_text)
    # report.print()
    # print("avg elapsed time:", report.mean("s"), "s")
    # print("result size:", size * size)
    elapsed_time_multi_simd = 0.0
    executed_size = 2*3*size*size
    for _ in range(repeat):
        started_at = perf_counter_ns()
        # bench_parallel()
        _ = compute_dot_products_parallel(velocities_i, velocities_j, threads)
        elapsed_time_multi_simd += perf_counter_ns() - started_at
    elapsed_time_multi_simd /= (1_000_000_000 * repeat)
    text = "Multi threads SIMD: " + str(elapsed_time_multi_simd)
    flops = executed_size/(elapsed_time_multi_simd * 1_000_000_000)
    text_flops = str(flops) + " GFLOP/s"
    print(text)
    print(text_flops)
    write_log(out, text)
    write_log(out, text_flops)

    # result = compute_dot_products_parallel(velocities_i, velocities_j)
    # for i in range(10):
    #     print(result[i])

fn main() raises:
    args = argv()
    size = int(args[1])
    repeat = int(args[2])
    out = args[3]
    threads = int(args[4])

    write_log(out, "Mojo benchmark test started")
    benchmark_dot_products(size, repeat, out, threads)