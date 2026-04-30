#pragma once

#include <memory>
#include <string>
#include <vector>

#include "rocksdb/version.h"
#include "rocksdb/db.h"

#ifndef ROCKSDB_MAKE_VERSION_INT
#define ROCKSDB_MAKE_VERSION_INT(a, b, c) ((a) * 1000000 + (b) * 1000 + (c))
#endif
#ifndef ROCKSDB_VERSION_INT
#define ROCKSDB_VERSION_INT \
    ROCKSDB_MAKE_VERSION_INT(ROCKSDB_MAJOR, ROCKSDB_MINOR, ROCKSDB_PATCH)
#endif
#ifndef ROCKSDB_VERSION_GE
#define ROCKSDB_VERSION_GE(a, b, c) \
    (ROCKSDB_VERSION_INT >= ROCKSDB_MAKE_VERSION_INT(a, b, c))
#endif

namespace py_rocks {

inline rocksdb::Status DBOpen(
        const rocksdb::Options& options,
        const std::string& name,
        rocksdb::DB** dbptr) {
    *dbptr = nullptr;
#if ROCKSDB_VERSION_GE(10, 0, 0)
    std::unique_ptr<rocksdb::DB> db;
    auto status = rocksdb::DB::Open(options, name, &db);
    if (status.ok()) {
        *dbptr = db.release();
    }
    return status;
#else
    return rocksdb::DB::Open(options, name, dbptr);
#endif
}

inline rocksdb::Status DBOpenColumnFamilies(
        const rocksdb::Options& options,
        const std::string& name,
        const std::vector<rocksdb::ColumnFamilyDescriptor>& column_families,
        std::vector<rocksdb::ColumnFamilyHandle*>* handles,
        rocksdb::DB** dbptr) {
    *dbptr = nullptr;
#if ROCKSDB_VERSION_GE(10, 0, 0)
    std::unique_ptr<rocksdb::DB> db;
    auto status = rocksdb::DB::Open(
            options,
            name,
            column_families,
            handles,
            &db);
    if (status.ok()) {
        *dbptr = db.release();
    }
    return status;
#else
    return rocksdb::DB::Open(
            options,
            name,
            column_families,
            handles,
            dbptr);
#endif
}

inline rocksdb::Status DBOpenAsSecondary(
        const rocksdb::Options& options,
        const std::string& name,
        const std::string& secondary_path,
        rocksdb::DB** dbptr) {
    *dbptr = nullptr;
#if ROCKSDB_VERSION_GE(10, 0, 0)
    std::unique_ptr<rocksdb::DB> db;
    auto status = rocksdb::DB::OpenAsSecondary(
            options,
            name,
            secondary_path,
            &db);
    if (status.ok()) {
        *dbptr = db.release();
    }
    return status;
#else
    return rocksdb::DB::OpenAsSecondary(options, name, secondary_path, dbptr);
#endif
}

inline rocksdb::Status DBOpenAsSecondaryColumnFamilies(
        const rocksdb::Options& options,
        const std::string& name,
        const std::string& secondary_path,
        const std::vector<rocksdb::ColumnFamilyDescriptor>& column_families,
        std::vector<rocksdb::ColumnFamilyHandle*>* handles,
        rocksdb::DB** dbptr) {
    *dbptr = nullptr;
#if ROCKSDB_VERSION_GE(10, 0, 0)
    std::unique_ptr<rocksdb::DB> db;
    auto status = rocksdb::DB::OpenAsSecondary(
            options,
            name,
            secondary_path,
            column_families,
            handles,
            &db);
    if (status.ok()) {
        *dbptr = db.release();
    }
    return status;
#else
    return rocksdb::DB::OpenAsSecondary(
            options,
            name,
            secondary_path,
            column_families,
            handles,
            dbptr);
#endif
}

inline rocksdb::Status DBOpenForReadOnly(
        const rocksdb::Options& options,
        const std::string& name,
        rocksdb::DB** dbptr,
        bool error_if_wal_file_exists) {
    *dbptr = nullptr;
#if ROCKSDB_VERSION_GE(10, 0, 0)
    std::unique_ptr<rocksdb::DB> db;
    auto status = rocksdb::DB::OpenForReadOnly(
            options,
            name,
            &db,
            error_if_wal_file_exists);
    if (status.ok()) {
        *dbptr = db.release();
    }
    return status;
#else
    return rocksdb::DB::OpenForReadOnly(
            options,
            name,
            dbptr,
            error_if_wal_file_exists);
#endif
}

inline rocksdb::Status DBOpenForReadOnlyColumnFamilies(
        const rocksdb::Options& options,
        const std::string& name,
        const std::vector<rocksdb::ColumnFamilyDescriptor>& column_families,
        std::vector<rocksdb::ColumnFamilyHandle*>* handles,
        rocksdb::DB** dbptr,
        bool error_if_wal_file_exists) {
    *dbptr = nullptr;
#if ROCKSDB_VERSION_GE(10, 0, 0)
    std::unique_ptr<rocksdb::DB> db;
    auto status = rocksdb::DB::OpenForReadOnly(
            options,
            name,
            column_families,
            handles,
            &db,
            error_if_wal_file_exists);
    if (status.ok()) {
        *dbptr = db.release();
    }
    return status;
#else
    return rocksdb::DB::OpenForReadOnly(
            options,
            name,
            column_families,
            handles,
            dbptr,
            error_if_wal_file_exists);
#endif
}

inline void DBDestroy(rocksdb::DB* db) {
    delete db;
}

}  // namespace py_rocks
