# Statistical pseudo-random number generators for Motoko

## Overview

The package provides multiple pseudo-random number generators.

Note: The PRNGs generate _statistical_ pseudo-random numbers. They are not cryptographically secure.

Currently implemented generators:
* [Seiran128](https://github.com/andanteyk/prng-seiran)
* [SFC64](https://numpy.org/doc/stable/reference/random/bit_generators/sfc64.html), SFC32

### Links

The package is published on [Mops](https://mops.one/prng) and [GitHub](https://github.com/research-ag/prng).
Please refer to the README on GitHub where it renders properly with formulas and tables.

API documentation: [here on Mops](https://mops.one/prng/docs/lib)

For updates, help, questions, feedback and other requests related to this package join us on:

* [OpenChat group](https://oc.app/2zyqk-iqaaa-aaaar-anmra-cai)
* [Twitter](https://twitter.com/mr_research_ag)
* [Dfinity forum](https://forum.dfinity.org/)

## Usage

### Install with mops

You need `mops` installed. In your project directory run:
```
mops add prng
```

In the Motoko source file import the package as:
```
import Prng "mo:prng";
```

### Example

The two most commonly used generators from this package are Seiran128 und SFC64a.
They both produce Nat64 output values.
SFC64a is compatible to numpy.

```
import Prng "mo:prng";

let seed : Nat64 = 0;

let rng = Prng.Seiran128();
rng.init(seed);
let seq : [Nat64] = [rng.next(), rng.next()];

let rng2 = Prng.SFC64a();
rng2.init(seed);
let seq2 : [Nat64] = [rng2.next(), rng2.next()];
```

There are also two recommended Nat32 generators, SFC32a and SFC32b, used as follows.

```
import Prng "mo:prng";

let seed : Nat32 = 0;

let rng = Prng.SFC32a(); // or Prng.SFC32b()
rng.init(seed);
let seq : [Nat32] = [rng.next(), rng.next()];
```

For SFC the internal parameters of the generator can also be customized with a constructor like `Prng.SFC64(24, 11, 3)`.
For more details take a look at the test file, the documentation in the source code, or https://mops.one/prng/docs.

### Build & test

Run:
```
git clone git@github.com:research-ag/prng.git
cd prng
mops test
```

## Benchmarks

The benchmarking code can be found here: [canister-profiling](https://github.com/research-ag/canister-profiling)
The values below were measured with moc 0.11.1 and dfx 0.20.1.

### Time

Wasm instructions per invocation of `next()`.

|method|Seiran128|SFC64|SFC32|
|---|---|---|---|
|next|215|320|274|

### Memory

Heap allocation per invocation of `next()`.
 
|method|Seiran128|SFC64|SFC32|
|---|---|---|---|
|next|36|48|16|

## Copyright

MR Research AG, 2023-24
## Authors

Main author: react0r-com

Contributors: Timo Hanke (timohanke) 
## License 

Apache-2.0
