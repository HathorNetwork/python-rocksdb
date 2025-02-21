import platform
from Cython.Build import cythonize
from setuptools import setup, Extension

extra_compile_args = [
    "-std=c++17",
    "-O2",
    "-Wno-unreachable-code-fallthrough",
    "-Wno-dangling-pointer",
    "-Wno-maybe-uninitialized",
    "-fno-strict-aliasing",
    "-fno-rtti",
]

if platform.system() == "Darwin":
    extra_compile_args += ["-mmacosx-version-min=10.7", "-stdlib=libc++"]

rocksdb_extension = Extension(
    "rocksdb._rocksdb",
    ["rocksdb/_rocksdb.pyx"],
    extra_compile_args=extra_compile_args,
    language="c++",
    libraries=["rocksdb", "snappy", "bz2", "z", "lz4"],
)

setup(ext_modules=cythonize([rocksdb_extension]))
