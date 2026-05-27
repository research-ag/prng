# Statistical pseudo-random number generators for Motoko

## Overview

The package provides multiple pseudo-random number generators.

Note: The PRNGs generate _statistical_ pseudo-random numbers. They are not cryptographically secure.

Currently implemented generators:

- [Seiran128](https://github.com/andanteyk/prng-seiran)
- [SFC64](https://numpy.org/doc/stable/reference/random/bit_generators/sfc64.html), SFC32

### Links

The package is published on [Mops](https://mops.one/prng) and [GitHub](https://github.com/research-ag/prng).
Please refer to the README on GitHub where it renders properly with formulas and tables.

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
npx -y prettier --plugin prettier-plugin-motoko --write '**/*.{mo,json,md}'
```

## Benchmarks

### Mops benchmark

Run

```bash
mops bench
```

### Profiling

The benchmarks were produced with `mops bench --replica dfx`.

### Time

Wasm instructions per invocation of `next()`.

| method | Seiran128 | SFC64 | SFC32 |
| ------ | --------- | ----- | ----- |
| next   | 382       | 754   | 380   |

### Memory

Heap allocation per invocation of `next()`.

| method | Seiran128 | SFC64 | SFC32 |
| ------ | --------- | ----- | ----- |
| next   | 12        | 12    | 4    |

## Copyright

MR Research AG, 2023-26

## Authors

Main author: Timo Hanke (timohanke)

Contributors: Andy Gura (AndyGura), react0r-com

## License

Apache-2.0
