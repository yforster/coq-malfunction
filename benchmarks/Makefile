COQOPTS = -R ./ VerifiedExtraction.Benchmarks -R lib VerifiedExtraction.Benchmarks.lib

# Names of the benchmarks
TESTS=$(shell cat TESTS)

all: lib tests

.PHONY: all default clean lib cleanlib tests run copy $(TESTS)

.SILENT: lib

lib:
	@echo "Building benchmark files in Coq"
	make -C lib > /dev/null 2>&1

cleanlib:
	$(MAKE) clean -C lib

tests: lib
	make -C ocaml-o0 all
	make -C ocaml all
	make -C ocaml-noopt all
	make -C malfunction all
	make -C malfunction-o2 all
	make -C malfunction-verified all
	make -C malfunction-verified-o2 all

run:
#	$(MAKE) -C ocaml-o0 run
	$(MAKE) -C ocaml run
	$(MAKE) -C ocaml-noopt run
	$(MAKE) -C malfunction run
	$(MAKE) -C malfunction-o2 run
	$(MAKE) -C malfunction-verified run
	$(MAKE) -C malfunction-verified-o2 run

