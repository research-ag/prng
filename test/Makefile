MOPS_PKGS=$(shell mops sources)

all: mops test

mops: 
	mops install

test:
	moc $(MOPS_PKGS) -wasi-system-api prng.mo && wasmtime prng.wasm
