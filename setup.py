import os
import platform
import subprocess
from Cython.Build import cythonize
from setuptools import setup, Extension

def get_brew_prefix(package):
    try:
        return subprocess.check_output(["brew", "--prefix", package], universal_newlines=True).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

include_dirs = []
library_dirs = []
extra_compile_args = [
    "-std=c++20",
    "-O2",
    "-fno-strict-aliasing",
    "-fno-rtti",
    "-Wno-unreachable-code-fallthrough",
]

if platform.system() == "Darwin":
    extra_compile_args.extend([
        "-mmacosx-version-min=11.0",
        "-stdlib=libc++",
        "-Wno-unreachable-code",
    ])
    for dep in ["rocksdb", "snappy", "lz4"]:
        dep_prefix = get_brew_prefix(dep)
        if dep_prefix:
            include_dirs.append(os.path.join(dep_prefix, "include"))
            library_dirs.append(os.path.join(dep_prefix, "lib"))
else:
    extra_compile_args.extend([
        "-Wno-dangling-pointer",
        "-Wno-maybe-uninitialized",
    ])

setup(ext_modules=cythonize([Extension(
    "rocksdb._rocksdb",
    ["rocksdb/_rocksdb.pyx"],
    include_dirs=include_dirs,
    library_dirs=library_dirs,
    extra_compile_args=extra_compile_args,
    language="c++",
    libraries=["rocksdb", "snappy", "bz2", "z", "lz4"],
)]))
