.PHONY: test

test:
	pip install -e .[test]
	pytest rocksdb/tests/
