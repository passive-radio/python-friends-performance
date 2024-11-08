import os

from setuptools import setup
from setuptools.extension import Extension

from Cython.Build import cythonize
import numpy

extra_compile_args_math_optimized    = ['-march=native', '-O3', '-msse', '-msse2', '-mfma', '-mfpmath=sse']
extra_compile_args_math_debug        = ['-march=native', '-O0', '-g']
extra_link_args_math_optimized       = []
extra_link_args_math_debug           = []

extra_compile_args_nonmath_optimized = ['-O3']
extra_compile_args_nonmath_debug     = ['-O0', '-g']
extra_link_args_nonmath_optimized    = []
extra_link_args_nonmath_debug        = []

openmp_compile_args = ['-fopenmp']
openmp_link_args    = ['-fopenmp']

def declare_cython_extension(extName, use_math=False, use_openmp=False, include_dirs=None):
    """Declare a Cython extension module for setuptools.

Parameters:
    extName : str
        Absolute module name, e.g. use `mylibrary.mypackage.mymodule`
        for the Cython source file `mylibrary/mypackage/mymodule.pyx`.

    use_math : bool
        If True, set math flags and link with ``libm``.

    use_openmp : bool
        If True, compile and link with OpenMP.

Return value:
    Extension object
        that can be passed to ``setuptools.setup``.
"""
    extPath = extName.replace(".", os.path.sep)+".pyx"

    if use_math:
        compile_args = list(extra_compile_args_math_optimized) # copy
        link_args    = list(extra_link_args_math_optimized)
        libraries    = ["m"]  # link libm; this is a list of library names without the "lib" prefix
    else:
        compile_args = list(extra_compile_args_nonmath_optimized)
        link_args    = list(extra_link_args_nonmath_optimized)
        libraries    = None  # value if no libraries, see setuptools.extension._Extension

    # OpenMP
    if use_openmp:
        compile_args.extend(openmp_compile_args)
        link_args.extend(openmp_link_args)

    # See
    #    http://docs.cython.org/src/tutorial/external.html
    #
    # on linking libraries to your Cython extensions.
    #
    return Extension( extName,
                    [extPath],
                    extra_compile_args=compile_args,
                    extra_link_args=link_args,
                    include_dirs=include_dirs,
                    libraries=libraries,
                    )

ext_module = declare_cython_extension("velocity_dot_product.cython.cython_core",
                                    use_math=True, use_openmp=True,)
cython_modules = cythonize([ext_module])

setup(
    name="velocity_dot_product",
    version="0.1",
    
    ext_modules=cython_modules,
    include_dirs=[numpy.get_include()]
) 