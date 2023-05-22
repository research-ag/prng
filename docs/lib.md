# lib
Collection of pseudo-random number generators

The algorithms deliver deterministic statistical randomness,
not cryptographic randomness.

Algorithm 1: 128-bit Seiran PRNG\
See: https://github.com/andanteyk/prng-seiran

Algorithm 2: SFC64 and SFC32 (Chris Doty-Humphrey’s Small Fast Chaotic PRNG)\
See: https://numpy.org/doc/stable/reference/random/bit_generators/sfc64.html

Copyright: 2023 MR Research AG\
Main author: react0r-com\
Contributors: Timo Hanke (timohanke) 

## Class `Seiran128`

``` motoko no-repl
class Seiran128()
```

Constructs a Seiran128 generator.

Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.Seiran128(); 
```  

### Function `init`
``` motoko no-repl
func init(seed : Nat64)
```

Initializes the PRNG state with a particular seed.
 
Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.Seiran128(); 
rng.init(0);
``` 


### Function `next`
``` motoko no-repl
func next() : Nat64
```

Returns one output and advances the PRNG's state.
 
Example:
```motoko
let rng = Prng.Seiran128(); 
rng.init(0);
rng.next(); // -> 11_505_474_185_568_172_049
``` 


### Function `jump32`
``` motoko no-repl
func jump32()
```

Advances the state 2^32 times.


### Function `jump64`
``` motoko no-repl
func jump64()
```

Advances the state 2^64 times.


### Function `jump96`
``` motoko no-repl
func jump96()
```

Advances the state 2^96 times.

## Class `SFC64`

``` motoko no-repl
class SFC64(p : Nat64, q : Nat64, r : Nat64)
```

Constructs an SFC 64-bit generator.
The recommended constructor arguments are: 24, 11, 3.

Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC64(24, 11, 3); 
```  
For convenience, the function `SFC64a()` returns a generator constructed
with the recommended parameter set (24, 11, 3).
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC64a(); 
```  

### Function `init`
``` motoko no-repl
func init(seed : Nat64)
```

Initializes the PRNG state with a particular seed
 
Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC64a(); 
rng.init(0);
``` 


### Function `init_pre`
``` motoko no-repl
func init_pre()
```

Initializes the PRNG state with a hardcoded seed.
No argument is required.
 
Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC64a(); 
rng.init_pre();
``` 


### Function `init3`
``` motoko no-repl
func init3(seed1 : Nat64, seed2 : Nat64, seed3 : Nat64)
```

Initializes the PRNG state with three state variables
 
Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC64a(); 
rng.init3(0, 1, 2);
``` 


### Function `next`
``` motoko no-repl
func next() : Nat64
```

Returns one output and advances the PRNG's state
 
Example:
```motoko
let rng = Prng.SFC64a(); 
rng.init(0);
rng.next(); // -> 4_237_781_876_154_851_393 
``` 

## Class `SFC32`

``` motoko no-repl
class SFC32(p : Nat32, q : Nat32, r : Nat32)
```

Constructs an SFC 32-bit generator.
The recommended constructor arguments are:
 a) 21, 9, 3 or
 b) 15, 8, 3 

Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC32(21, 9, 3); 
```  
For convenience, the functions `SFC32a()` and `SFC32b()` return
generators with the parameter sets a) and b) given above.
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC32a(); 
```  

### Function `init`
``` motoko no-repl
func init(seed : Nat32)
```

Initializes the PRNG state with a particular seed
 
Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC32(); 
rng.init(0);
``` 


### Function `init_pre`
``` motoko no-repl
func init_pre()
```

Initializes the PRNG state with a hardcoded seed.
No argument is required.
 
Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC32a(); 
rng.init_pre();
``` 


### Function `init3`
``` motoko no-repl
func init3(seed1 : Nat32, seed2 : Nat32, seed3 : Nat32)
```

Initializes the PRNG state with three seeds
 
Example:
```motoko
import Prng "mo:prng"; 
let rng = Prng.SFC32a(); 
rng.init3(0, 1, 2);
``` 


### Function `next`
``` motoko no-repl
func next() : Nat32
```

Returns one output and advances the PRNG's state
 
Example:
```motoko
let rng = Prng.SFC32a(); 
rng.init(0);
rng.next(); // -> 1_363_572_419 
``` 

## Function `SFC64a`
``` motoko no-repl
func SFC64a() : SFC64
```

SFC64a is the same as numpy.
See: [sfc64_next()](https:///github.com/numpy/numpy/blob/b6d372c25fab5033b828dd9de551eb0b7fa55800/numpy/random/src/sfc64/sfc64.h#L28)

## Function `SFC32a`
``` motoko no-repl
func SFC32a() : SFC32
```

Ok to use

## Function `SFC32b`
``` motoko no-repl
func SFC32b() : SFC32
```

Ok to use

## Function `SFC64b`
``` motoko no-repl
func SFC64b() : SFC64
```

Not recommended. Use `SFC64a` version.

## Function `SFC32c`
``` motoko no-repl
func SFC32c() : SFC32
```

Not recommended. Use `SFC32a` or `SFC32b` version.
