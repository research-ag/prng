/// Collection of pseudo-random number generators
///
/// The algorithms deliver deterministic statistical randomness,
/// not cryptographic randomness.
///
/// Algorithm 1: 128-bit Seiran PRNG
/// See: https://github.com/andanteyk/prng-seiran
///
/// Algorithm 2: SFC64 and SFC32 (Chris Doty-Humphrey’s Small Fast Chaotic PRNG)
/// See: https://numpy.org/doc/stable/reference/random/bit_generators/sfc64.html
///
/// Copyright: 2023-26 MR Research AG
/// Main author: Timo Hanke (timohanke)
/// Contributors: Andy Gura (AndyGura), react0r-com

import Seiran128_ "./Seiran128";
import SFC64_ "./SFC64";
import SFC32_ "./SFC32";

module {

  /// 128-bit Seiran PRNG.
  ///
  /// A deterministic statistical pseudo-random number generator with 128 bits
  /// of state, producing `Nat64` output values. Provides constant-time
  /// `jump32`, `jump64`, and `jump96` operations for advancing the state by
  /// `2^32`, `2^64`, and `2^96` steps respectively — useful for splitting a
  /// stream across parallel workers.
  ///
  /// Not cryptographically secure.
  ///
  /// Re-export of the `Seiran128` module. See `Seiran128` for the full API.
  public let Seiran128 = Seiran128_;

  /// SFC64 — Chris Doty-Humphrey's Small Fast Chaotic 64-bit PRNG.
  ///
  /// A deterministic statistical pseudo-random number generator with 256 bits
  /// of state (four `Nat64` words) and three tuning parameters `(p, q, r)`,
  /// producing `Nat64` output values. The convenience constructor `SFC64a`
  /// uses the parameter set `(24, 11, 3)`, which matches numpy's
  /// `numpy.random.SFC64`; `SFC64b` uses `(25, 12, 3)`.
  ///
  /// Not cryptographically secure.
  ///
  /// Re-export of the `SFC64` module. See `SFC64` for the full API.
  public let SFC64 = SFC64_;

  /// SFC32 — Chris Doty-Humphrey's Small Fast Chaotic 32-bit PRNG.
  ///
  /// A deterministic statistical pseudo-random number generator with 128 bits
  /// of state (four `Nat32` words) and three tuning parameters `(p, q, r)`,
  /// producing `Nat32` output values. Two parameter sets are recommended:
  /// `SFC32a` uses `(21, 9, 3)` and `SFC32b` uses `(15, 8, 3)`. A third
  /// variant `SFC32c` (parameters `(25, 8, 3)`) is exposed for completeness
  /// but is not recommended for general use.
  ///
  /// Not cryptographically secure.
  ///
  /// Re-export of the `SFC32` module. See `SFC32` for the full API.
  public let SFC32 = SFC32_;

};
