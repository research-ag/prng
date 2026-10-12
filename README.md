# Statistical pseudo-random number generators for Motoko

## Overview

The package provides multiple pseudo-random number generators.

Note: The PRNGs generate _statistical_ pseudo-random numbers. They are not cryptographically secure.

Currently implemented generators:

- [Seiran128](https://github.com/andanteyk/prng-seiran)
- [SFC64](https://numpy.org/doc/stable/reference/random/bit_generators/sfc64.html), SFC32

### Links

The package is published on [Mops](https://mops.one/prng) and [GitHub](https://github.com/research-ag/prng).

API documentation: [here on Mops](https://mops.one/prng/docs/lib)

For updates, help, questions, feedback and other requests related to this package join us on:

- [OpenChat group](https://oc.app/2zyqk-iqaaa-aaaar-anmra-cai)
- [Twitter](https://twitter.com/mr_research_ag)
- [Dfinity forum](https://forum.dfinity.org/)

## Usage

### Install with mops

You need `mops` installed. In your project directory run:

```bash
mops add prng
```

In the Motoko source file import the generators you need:

```motoko
import { Seiran128; SFC64; SFC32 } "mo:prng";

```

(Importing the modules directly — e.g. `import Seiran128 "mo:prng/Seiran128"` — works too and is required for the `rng.next()` method-call syntax to resolve.)

### Example

The two most commonly used generators from this package are Seiran128 and SFC64a.
They both produce Nat64 output values.
SFC64a is compatible with numpy.

```motoko
import { Seiran128; SFC64 } "mo:prng";

let seed : Nat64 = 0;

let rng = Seiran128.new(seed);
let seq : [Nat64] = [rng.next(), rng.next()];

let rng2 = SFC64.SFC64a(seed);
let seq2 : [Nat64] = [rng2.next(), rng2.next()];

```

The seed argument is optional; omitting it uses each algorithm's default seed:

```motoko
import { Seiran128; SFC64 } "mo:prng";

let rng = Seiran128.new(); // uses defaultSeiran128Seed
let rng2 = SFC64.SFC64a(); // uses defaultSFC64Seed

```

There are also two recommended Nat32 generators, SFC32a and SFC32b, used as follows.

```motoko
import { SFC32 } "mo:prng";

let seed : Nat32 = 0;

let rng = SFC32.SFC32a(seed); // or SFC32.SFC32b(seed)
let seq : [Nat32] = [rng.next(), rng.next()];

```

For SFC the internal parameters of the generator can also be customized with a constructor like `SFC64.new(24, 11, 3, seed)`.
For more details take a look at the test files, the documentation in the source code, or https://mops.one/prng/docs.

### Build & test

Run:

```bash
git clone git@github.com:research-ag/prng.git
cd prng
mops test
```

## Formatting

To format the code, run:

```bash
npm install --no-save prettier prettier-plugin-motoko
npx prettier --plugin prettier-plugin-motoko --write '**/*.{mo,json,md}'
```

## Benchmarks

### Mops benchmark

Run

```bash
mops bench
```

### Results

Produced with `mops bench` using moc 2.0.0 (enhanced orthogonal persistence,
64-bit heap, incremental GC) with `wasm-opt -O3` applied.

### Time

Wasm instructions per invocation of `next()` (including loop overhead).

| method | Seiran128 | SFC64 | SFC32 |
| ------ | --------- | ----- | ----- |
| next   | 324       | 551   | 251   |

### Memory

Heap allocation per invocation of `next()`, in bytes.

This is the boxed `Nat64` return value (32 bytes for outputs ≥ 2^60);
updating the state allocates nothing.

| method | Seiran128 | SFC64 | SFC32 |
| ------ | --------- | ----- | ----- |
| next   | 30        | 30    | 0     |

### Benchmark history

The Versions page on mops.one compares each version's benchmarks with the
previous version's. Most of the large jumps come from changes in the
measurement setup, not from the code. Instructions per `next()` call as
published (Seiran128 / SFC64 / SFC32):

| Version | Instructions per call | Setup                                 | Cause of the change                                                                                                                                                      |
| ------- | --------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 0.0.7   | 244 / 383 / 332       | moc 1.1.0, dfx 0.29.2                 |                                                                                                                                                                          |
| 0.0.8   | 150 / 288 / 238       | moc 1.1.0, dfx 0.29.2                 | Bench rewritten with less loop and per-cell overhead                                                                                                                     |
| 0.1.0   | 288 / 575 / 524       | moc 1.8.2, pocket-ic 9.0.3            | New static API; the bench called `next` through a closure returning `Any`; new moc and replica                                                                           |
| 0.0.10  | 198 / 303 / 253       | moc 1.8.2, pocket-ic 9.0.3            | Old API. Published after 0.1.0, so mops.one compares it with 0.1.0. The bench now seeds Seiran128 (before, its state was all zeros)                                      |
| 0.1.1   | 167 / 320 / 271       | moc 1.8.2, dfx 0.31.0                 | Bench calls `next` directly instead of through a closure                                                                                                                 |
| 0.2.0   | 382 / 754 / 380       | moc 1.8.2, dfx 0.31.0                 | Code only: the state is stored in `Nat16` slots, so state updates no longer allocate on the 32-bit heap (only the returned value does), at the cost of more instructions |
| 0.3.0   | 665 / 1239 / 607      | moc 2.0.0, pocket-ic 15.0.0, wasm-opt | Enhanced orthogonal persistence (64-bit heap, incremental GC) instead of legacy persistence; same code as 0.2.0                                                          |
| 0.3.1   | 324 / 551 / 251       | moc 2.0.0, pocket-ic 15.0.0, wasm-opt | Code only: the state is stored in `Nat32` slots, which are never boxed on the 64-bit heap                                                                                |

Up to 0.2.0, `mops publish` measured with legacy persistence and the copying
GC; from 0.3.0 on with enhanced orthogonal persistence and the incremental GC.

## Copyright

MR Research AG, 2023-26

## Authors

Main author: Timo Hanke (timohanke)

Contributors: Andy Gura (AndyGura), react0r-com

## License

Apache-2.0
