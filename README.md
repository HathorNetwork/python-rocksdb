# python-rocksdb

This project is based off the efforts from
https://github.com/NightTsarina/python-rocksdb and basically strips backup
support, filter support and several options, so that it can work on rocksdb
from 5.17 (which is what's available on Ubuntu 20.04) through 7.0 (the current
latest release, already the only one published on homebrew and alpine repos).

It isn't intended for general use and should eventually be superseded by the
project is is based off when repos catch on and rocksdb 7.0 is properly
(without stripped features) supported.
