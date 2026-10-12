# Prng changelog

## 0.3.1

- Store the generator state in `Nat32` slots: about half the instructions per `next()` on the 64-bit heap.
- **Breaking:** State type changed from `[var Nat16]` to `[var Nat32]`.
- Add a test that `next()` allocates only its return value.

## 0.3.0

- Compiles warning-free with moc 2.0.0.
- Benchmarks: +60–74% instructions due to the compiler switch to the 64-bit heap.

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
