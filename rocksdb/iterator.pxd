from libcpp cimport bool as cpp_bool
from .slice_ cimport Slice
from .status cimport Status

cdef extern from "rocksdb/iterator.h" namespace "rocksdb":
    cdef cppclass Iterator:
        cpp_bool Valid() except+ nogil 
        void SeekToFirst() except+ nogil 
        void SeekToLast() except+ nogil 
        void Seek(const Slice&) except+ nogil 
        void Next() except+ nogil 
        void Prev() except+ nogil 
        void SeekForPrev(const Slice&) except+ nogil 
        Slice key() except+ nogil 
        Slice value() except+ nogil 
        Status status() except+ nogil 
