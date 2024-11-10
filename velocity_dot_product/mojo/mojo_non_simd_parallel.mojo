from python import Python
from benchmark import Unit
from random import random_float64
from math import sqrt
from time import sleep
from collections.list import List
from sys import argv
from algorithm import parallelize
from memory import UnsafePointer
# from sys.info import simdwidthof

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
    
    fn store(self, row: Int, col: Int, val: Float32):
        self.data.store(row * self.cols + col, val)
    
    fn free(self):
        self.data.free()

fn generate_random_velocities(size: Int) -> List[Velocity]:
    var velocities = List[Velocity]()
    for _ in range(size):
        var x = random_float64(-1.0, 1.0).cast[DType.float32]()
        var y = random_float64(-1.0, 1.0).cast[DType.float32]()
        var z = random_float64(-1.0, 1.0).cast[DType.float32]()
        velocities.append(Velocity(x, y, z))
    return velocities

fn compute_dot_products(velocities_i: List[Velocity], 
                       velocities_j: List[Velocity], result_matrix: DotProductMatrix):
    var n = len(velocities_i)
    var m = len(velocities_j)
    
    @parameter
    fn worker(i: Int):
        var v_i = velocities_i[i]
        for j in range(m):
            var v_j = velocities_j[j]
            result_matrix.store(i, j, v_i.dot(v_j))
    
    # 並列処理の実行
    parallelize[worker](2, 2)  # チャンクサイズをnに設定

fn benchmark_dot_products(size: Int, repeat: Int, out: String) raises:
    var velocities_i = generate_random_velocities(size)
    var velocities_j = generate_random_velocities(size)

    write_log(out, "Mojo parallel benchmark test started")

    var n = len(velocities_i)
    var m = len(velocities_j)
    var result_matrix = DotProductMatrix(n, m)  # スコープ外で宣言

    @parameter
    fn compute():
        compute_dot_products(velocities_i, velocities_j, result_matrix)
    
    var report = benchmark.run[compute](repeat)
    print("N=", size, " - Mojo parallel dot product test")
    var avg_time = report.mean("ms")
    var avg_time_text = "avg_elapsed_time: " + str(avg_time) + "ms"
    write_log(out, avg_time_text)
    print("avg elapsed time:", avg_time, "ms")
    print("result size:", size * size)

    # メモリの解放
    result_matrix.free()

fn main() raises:
    var args = argv()
    size = int(args[1])
    repeat = int(args[2])
    out = args[3]
    benchmark_dot_products(size, repeat, out)