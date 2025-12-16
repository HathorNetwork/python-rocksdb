from . cimport options
from libc.stdint cimport uint64_t, uint32_t
from .status cimport Status
from libcpp cimport bool as cpp_bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from .types cimport SequenceNumber
from .slice_ cimport Slice
from .snapshot cimport Snapshot
from .iterator cimport Iterator

cdef extern from "rocksdb/write_batch.h" namespace "rocksdb":
    cdef cppclass WriteBatch:
        WriteBatch() except+ nogil
        WriteBatch(string) except+ nogil
        void Put(const Slice&, const Slice&) except+ nogil
        void Put(ColumnFamilyHandle*, const Slice&, const Slice&) except+ nogil
        void Merge(const Slice&, const Slice&) except+ nogil
        void Merge(ColumnFamilyHandle*, const Slice&, const Slice&) except+ nogil
        void Delete(const Slice&) except+ nogil
        void Delete(ColumnFamilyHandle*, const Slice&) except+ nogil
        void PutLogData(const Slice&) except+ nogil
        void Clear() except+ nogil
        const string& Data() except+ nogil
        uint32_t Count() except+ nogil

cdef extern from "cpp/write_batch_iter_helper.hpp" namespace "py_rocks":
    cdef enum BatchItemOp "RecordItemsHandler::Optype":
        BatchItemOpPut "py_rocks::RecordItemsHandler::Optype::PutRecord"
        BatchItemOpMerge "py_rocks::RecordItemsHandler::Optype::MergeRecord"
        BatchItemOpDelte "py_rocks::RecordItemsHandler::Optype::DeleteRecord"

    cdef cppclass BatchItem "py_rocks::RecordItemsHandler::BatchItem":
        BatchItemOp op
        uint32_t column_family_id
        Slice key
        Slice value

    Status get_batch_items(WriteBatch* batch, vector[BatchItem]* items)


cdef extern from "rocksdb/db.h" namespace "rocksdb":
    string kDefaultColumnFamilyName

    cdef struct LiveFileMetaData:
        string name
        int level
        uint64_t size
        string smallestkey
        string largestkey
        SequenceNumber smallest_seqno
        SequenceNumber largest_seqno

    # cdef struct SstFileMetaData:
    #     uint64_t size
    #     string name
    #     uint64_t file_number
    #     string db_path
    #     string smallestkey
    #     string largestkey
    #     SequenceNumber smallest_seqno
    #     SequenceNumber largest_seqno

    # cdef struct LevelMetaData:
    #     int level
    #     uint64_t size
    #     string largestkey
    #     LiveFileMetaData files

    cdef struct ColumnFamilyMetaData:
        uint64_t size
        uint64_t file_count
        # string largestkey
        # LevelMetaData levels

    cdef cppclass Range:
        Range(const Slice&, const Slice&)

    cdef cppclass DB:
        Status Put(
            const options.WriteOptions&,
            ColumnFamilyHandle*,
            const Slice&,
            const Slice&) except+ nogil

        Status Delete(
            const options.WriteOptions&,
            ColumnFamilyHandle*,
            const Slice&) except+ nogil

        Status Merge(
            const options.WriteOptions&,
            ColumnFamilyHandle*,
            const Slice&,
            const Slice&) except+ nogil

        Status Write(
            const options.WriteOptions&,
            WriteBatch*) except+ nogil

        Status Get(
            const options.ReadOptions&,
            ColumnFamilyHandle*,
            const Slice&,
            string*) except+ nogil

        vector[Status] MultiGet(
            const options.ReadOptions&,
            const vector[ColumnFamilyHandle*]&,
            const vector[Slice]&,
            vector[string]*) except+ nogil

        cpp_bool KeyMayExist(
            const options.ReadOptions&,
            ColumnFamilyHandle*,
            Slice&,
            string*,
            cpp_bool*) except+ nogil

        cpp_bool KeyMayExist(
            const options.ReadOptions&,
            ColumnFamilyHandle*,
            Slice&,
            string*) except+ nogil

        Iterator* NewIterator(
            const options.ReadOptions&,
            ColumnFamilyHandle*) except+ nogil

        void NewIterators(
            const options.ReadOptions&,
            vector[ColumnFamilyHandle*]&,
            vector[Iterator*]*) except+ nogil

        const Snapshot* GetSnapshot() except+ nogil

        void ReleaseSnapshot(const Snapshot*) except+ nogil

        cpp_bool GetProperty(
            ColumnFamilyHandle*,
            const Slice&,
            string*) except+ nogil

        void GetApproximateSizes(
            ColumnFamilyHandle*,
            const Range*
            int,
            uint64_t*) except+ nogil

        Status CompactRange(
            const options.CompactRangeOptions&,
            ColumnFamilyHandle*,
            const Slice*,
            const Slice*) except+ nogil

        Status CreateColumnFamily(
            const options.ColumnFamilyOptions&,
            const string&,
            ColumnFamilyHandle**) except+ nogil

        Status DropColumnFamily(
            ColumnFamilyHandle*) except+ nogil

        int NumberLevels(ColumnFamilyHandle*) except+ nogil
        int MaxMemCompactionLevel(ColumnFamilyHandle*) except+ nogil
        int Level0StopWriteTrigger(ColumnFamilyHandle*) except+ nogil
        const string& GetName() except+ nogil
        const options.Options& GetOptions(ColumnFamilyHandle*) except+ nogil
        Status Flush(const options.FlushOptions&, ColumnFamilyHandle*) except+ nogil
        Status Flush(const options.FlushOptions&, const vector[ColumnFamilyHandle*]&) except+ nogil
        Status DisableFileDeletions() except+ nogil
        Status EnableFileDeletions() except+ nogil
        Status Close() except+ nogil

        # TODO: Status GetSortedWalFiles(VectorLogPtr& files)
        # TODO: SequenceNumber GetLatestSequenceNumber()
        # TODO: Status GetUpdatesSince(
                  # SequenceNumber seq_number,
                  # unique_ptr[TransactionLogIterator]*)

        Status DeleteFile(string) except+ nogil
        void GetLiveFilesMetaData(vector[LiveFileMetaData]*) except+ nogil
        void GetColumnFamilyMetaData(ColumnFamilyHandle*, ColumnFamilyMetaData*) except+ nogil
        ColumnFamilyHandle* DefaultColumnFamily()
        Status TryCatchUpWithPrimary() nogil except+


    cdef Status DB_Open "rocksdb::DB::Open"(
        const options.Options&,
        const string&,
        DB**) except+ nogil

    cdef Status DB_Open_ColumnFamilies "rocksdb::DB::Open"(
        const options.Options&,
        const string&,
        const vector[ColumnFamilyDescriptor]&,
        vector[ColumnFamilyHandle*]*,
        DB**) except+ nogil

    cdef Status DB_OpenAsSecondary "rocksdb::DB::OpenAsSecondary"(
        const options.Options&,
        const string&,
        const string&,
        DB**) nogil except+

    cdef Status DB_OpenAsSecondary_ColumnFamilies "rocksdb::DB::OpenAsSecondary"(
        const options.Options&,
        const string&,
        const string&,
        const vector[ColumnFamilyDescriptor]&,
        vector[ColumnFamilyHandle*]*,
        DB**) nogil except+

    cdef Status DB_OpenForReadOnly "rocksdb::DB::OpenForReadOnly"(
        const options.Options&,
        const string&,
        DB**,
        cpp_bool) except+ nogil

    cdef Status DB_OpenForReadOnly_ColumnFamilies "rocksdb::DB::OpenForReadOnly"(
        const options.Options&,
        const string&,
        const vector[ColumnFamilyDescriptor]&,
        vector[ColumnFamilyHandle*]*,
        DB**,
        cpp_bool) except+ nogil

    cdef Status RepairDB(const string& dbname, const options.Options&)

    cdef Status ListColumnFamilies "rocksdb::DB::ListColumnFamilies" (
        const options.Options&,
        const string&,
        vector[string]*) except+ nogil

    cdef cppclass ColumnFamilyHandle:
        const string& GetName() except+ nogil
        uint32_t GetID() except+ nogil

    cdef cppclass ColumnFamilyDescriptor:
        ColumnFamilyDescriptor() except+ nogil
        ColumnFamilyDescriptor(
	    const string&,
            const options.ColumnFamilyOptions&) except+ nogil
        string name
        options.ColumnFamilyOptions options

cdef extern from "rocksdb/convenience.h" namespace "rocksdb":
    void CancelAllBackgroundWork(DB*, cpp_bool) except+ nogil
