cdef extern from "<memory>" namespace "std":
    cdef cppclass shared_ptr[T]:
        shared_ptr() except+ nogil 
        shared_ptr(T*) except+ nogil 
        void reset() except+ nogil 
        void reset(T*) except+ nogil 
        T* get() except+ nogil 
