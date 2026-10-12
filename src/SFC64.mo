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
/// Reference: https://numpy.org/doc/stable/reference/random/bit_generators/sfc64.html
///
/// ```motoko name=import
/// import SFC64 "mo:prng/SFC64";
/// ```
///
/// Copyright: 2023-26 MR Research AG
/// Main author: Timo Hanke (timohanke)
/// Contributors: Andy Gura (AndyGura), react0r-com

import Prim "mo:prim";

module SFC64 {
  let nat32To64 = Prim.nat32ToNat64;
  let nat64To32 = Prim.nat64ToNat32;

  /// State of an SFC 64-bit generator.
  /// Layout: state words `a`, `b`, `c`, `d` occupy slots `[0..1]`, `[2..3]`,
  /// `[4..5]`, `[6..7]` respectively — each split into two `Nat32` slots,
  /// low half first. Tuning parameters `p`, `q`, `r` live in slots `[8]`,
  /// `[9]`, `[10]` as raw `Nat32` values (they only need to fit shift
  /// amounts ≤ 64).
  public type SFC64 = [var Nat32];

  /// Default seed for SFC64 generators.
  public let defaultSFC64Seed : Nat64 = 0xcafef00dbeef5eed;

  // Split a Nat64 into two Nat32 slots (low half first) starting at `base`.
  func writeU64(self : SFC64, base : Nat, v : Nat64) {
    self[base] := nat64To32(v & 0xFFFF_FFFF);
    self[base + 1] := nat64To32(v >> 32);
  };

  /// Constructs an SFC 64-bit generator.
  /// The recommended constructor arguments are: 24, 11, 3.
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.SFC64.new(24, 11, 3);
  /// ```
  /// For convenience, the function `SFC64a()` returns a generator constructed
  /// with the recommended parameter set (24, 11, 3).
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.SFC64.SFC64a();
  /// ```
  public func new(p : Nat64, q : Nat64, r : Nat64, seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 {
    let p32 = nat64To32(p & 0xFFFF_FFFF);
    let q32 = nat64To32(q & 0xFFFF_FFFF);
    let r32 = nat64To32(r & 0xFFFF_FFFF);
    let prng : SFC64 = [var 0, 0, 0, 0, 0, 0, 0, 0, p32, q32, r32];
    prng.init(seed);
    prng;
  };

  /// Initializes the PRNG state with a particular seed
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.SFC64.SFC64a();
  /// rng.init(0);
  /// ```
  public func init(self : SFC64, seed : (implicit : (defaultSFC64Seed : Nat64))) = init3(self, seed, seed, seed);

  /// Initializes the PRNG state with three state variables
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.SFC64.SFC64a();
  /// rng.init3(0, 1, 2);
  /// ```
  public func init3(self : SFC64, seed1 : Nat64, seed2 : Nat64, seed3 : Nat64) {
    writeU64(self, 0, seed1);
    writeU64(self, 2, seed2);
    writeU64(self, 4, seed3);
    writeU64(self, 6, 1);

    var i_ : Nat8 = 12;
    while (i_ > 0) {
      ignore next(self);
      i_ -%= 1;
    };
  };

  /// Returns one output and advances the PRNG's state
  ///
  /// Example:
  /// ```motoko
  /// let rng = Prng.SFC64.SFC64a();
  /// rng.init(0);
  /// rng.next(); // -> 4_237_781_876_154_851_393
  /// ```
  public func next(self : SFC64) : Nat64 {
    let a = nat32To64(self[0]) | (nat32To64(self[1]) << 32);
    let b = nat32To64(self[2]) | (nat32To64(self[3]) << 32);
    let c = nat32To64(self[4]) | (nat32To64(self[5]) << 32);
    let d = nat32To64(self[6]) | (nat32To64(self[7]) << 32);

    let p = nat32To64(self[8]);
    let q = nat32To64(self[9]);
    let r = nat32To64(self[10]);

    let result = a +% b +% d;

    let na = b ^ (b >> q);
    let nb = c +% (c << r);
    let nc = (c <<> p) +% result;
    let nd = d +% 1;

    self[0] := nat64To32(na & 0xFFFF_FFFF);
    self[1] := nat64To32(na >> 32);
    self[2] := nat64To32(nb & 0xFFFF_FFFF);
    self[3] := nat64To32(nb >> 32);
    self[4] := nat64To32(nc & 0xFFFF_FFFF);
    self[5] := nat64To32(nc >> 32);
    self[6] := nat64To32(nd & 0xFFFF_FFFF);
    self[7] := nat64To32(nd >> 32);

    result;
  };

  /// SFC64a is the same as numpy.
  /// See: [sfc64_next()](https://github.com/numpy/numpy/blob/b6d372c25fab5033b828dd9de551eb0b7fa55800/numpy/random/src/sfc64/sfc64.h#L28)
  public func SFC64a(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(24, 11, 3, seed);

  /// Not recommended. Use `SFC64a` version.
  public func SFC64b(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(25, 12, 3, seed);
};
