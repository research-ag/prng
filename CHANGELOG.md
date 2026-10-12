# Prng changelog

## 0.3.0

- Compiles warning-free with moc 2.0.0.
- Benchmarks are now measured with moc 2.0.0 (enhanced orthogonal persistence, 64-bit heap, incremental GC, wasm-opt) instead of legacy persistence: +60–74% instructions per `next()` compared to 0.2.0, with unchanged code. See "Benchmark history" in the README.

## 0.2.0

- Allocation-free version
- `next()` only allocates for the returned value
- **Breaking:** State representation changed

## 0.1.1

- Add documentation
- Fix benchmark accuracy

## 0.1.0

- Rewrite of the API
- Use static records for easier persistency
- Require `moc 1.0.0` or higher

## 0.0.10

- Fix benchmark accuracy

## 0.0.9

- Use bench-helper package
- Simplify bench code

## 0.0.8

- Improve benchmark accuracy

## 0.0.7

- Update dev-dependencies

## 0.0.6

- Remove base dependency entirely

## 0.0.5

- Bump moc/base to 0.11.2

## 0.0.4

- Bump dependencies
- Make tests run by `mops test`
- Documentation updates
