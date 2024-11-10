from python import Python
import benchmark
from benchmark import Unit
from random import random_float64
from math import sqrt
from time import sleep
from sys.info import simdwidthof
from collections.list import List
from random import random_float64
from sys import argv
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

fn compute_dot_products(velocities_i: List[Velocity], 
                       velocities_j: List[Velocity]) -> List[Float32]:
    n = len(velocities_i)
    m = len(velocities_j)
    var results = List[Float32](n * m)
    
    for i in range(n):
        v_i = velocities_i[i]
        for j in range(m):
            v_j = velocities_j[j]
            results.append(v_i.dot(v_j))
    
    return results

fn generate_random_velocities(size: Int) -> List[Velocity]:
    var velocities = List[Velocity]()
    for _ in range(size):
        var x = random_float64(-1.0, 1.0).cast[DType.float32]()
        var y = random_float64(-1.0, 1.0).cast[DType.float32]()
        var z = random_float64(-1.0, 1.0).cast[DType.float32]()
        var velocity = Velocity(x, y, z)
        velocities.append(velocity)
    return velocities

fn benchmark_dot_products(size: Int, repeat: Int, out: String) raises:
    # Generate sample data
    var velocities_i = generate_random_velocities(size)
    var velocities_j = generate_random_velocities(size)

    print("calculating started")
    write_log(out, "Mojo benchmark test started")

    @parameter
    fn compute():
        _ = compute_dot_products(velocities_i, velocities_j)
    
    var report = benchmark.run[compute](2)
    print("N=", size, " - Mojo dot product test")
    avg_time_text = "avg_elapsed_time: " + str(report.mean("s")) + "s"
    write_log(out, avg_time_text)
    # print("avg_elapsed_time:", report.mean() / 1e9, "s")
    print("avg elapsed time:", report.mean("s"), "s")
    print("result size:", size * size)

fn main() raises:
    var args = argv()
    size = int(args[1])
    repeat = int(args[2])
    out = args[3]
    
    benchmark_dot_products(size, repeat, out)