/// SFC32 — Chris Doty-Humphrey's Small Fast Chaotic 32-bit PRNG.
///
/// A deterministic statistical pseudo-random number generator with 128 bits
/// of state (four `Nat32` words) and three tuning parameters `(p, q, r)`,
/// producing `Nat32` output values. Two parameter sets are recommended:
/// `SFC32a` uses `(21, 9, 3)` and `SFC32b` uses `(15, 8, 3)`. A third variant
/// `SFC32c` (parameters `(25, 8, 3)`) is exposed for completeness but is not
/// recommended for general use.
///
/// Not cryptographically secure.
///
/// Reference: https://numpy.org/doc/stable/reference/random/bit_generators/sfc64.html
///
/// ```motoko name=import
/// import SFC32 "mo:prng/SFC32";
/// ```
///
/// Copyright: 2023-26 MR Research AG
/// Main author: Timo Hanke (timohanke)
/// Contributors: Andy Gura (AndyGura), react0r-com

import Prim "mo:prim";

module SFC32 {
  let nat8To16 = Prim.nat8ToNat16;
  let nat16To32 = Prim.nat16ToNat32;
  let nat32To16 = Prim.nat32ToNat16;

  /// State of an SFC 32-bit generator.
  /// Layout: state words `a`, `b`, `c`, `d` occupy slots `[0..1]`, `[2..3]`,
  /// `[4..5]`, `[6..7]` respectively — each split little-endian into two
  /// `Nat16` slots, with the lowest 16 bits at the lower index. Tuning
  /// parameters `p`, `q`, `r` live in slots `[8]`, `[9]`, `[10]` as raw
  /// `Nat16` values (they only need to fit shift amounts ≤ 32).
  public type SFC32 = [var Nat16];

  /// Default seed for SFC32 generators.
  public let defaultSFC32Seed : Nat32 = 0xbeef5eed;

  // Split a Nat32 into two little-endian Nat16 slots starting at `base`.
  // Used only on the init cold path; `next` inlines packing via `explodeNat32`.
  func writeU32(self : SFC32, base : Nat, v : Nat32) {
    self[base] := nat32To16(v & 0xFFFF);
    self[base + 1] := nat32To16(v >> 16);
  };

  /// Constructs an SFC 32-bit generator.
  /// The recommended constructor arguments are:
  ///  a) 21, 9, 3 or
  ///  b) 15, 8, 3
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.SFC32.new(21, 9, 3);
  /// ```
  /// For convenience, the functions `SFC32a()` and `SFC32b()` return
  /// generators with the parameter sets a) and b) given above.
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.SFC32.SFC32a();
  /// ```
  public func new(p : Nat32, q : Nat32, r : Nat32, seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 {
    let p16 = nat32To16(p & 0xFFFF);
    let q16 = nat32To16(q & 0xFFFF);
    let r16 = nat32To16(r & 0xFFFF);
    let prng : SFC32 = [var 0, 0, 0, 0, 0, 0, 0, 0, p16, q16, r16];
    prng.init(seed);
    prng;
  };

  /// Initializes the PRNG state with a particular seed
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.SFC32.SFC32a();
  /// rng.init(0);
  /// ```
  public func init(self : SFC32, seed : (implicit : (defaultSFC32Seed : Nat32))) = init3(self, seed, seed, seed);

  /// Initializes the PRNG state with three seeds
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.SFC32.SFC32a();
  /// rng.init3(0, 1, 2);
  /// ```
  public func init3(self : SFC32, seed1 : Nat32, seed2 : Nat32, seed3 : Nat32) {
    writeU32(self, 0, seed1);
    writeU32(self, 2, seed2);
    writeU32(self, 4, seed3);
    writeU32(self, 6, 1);

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
  /// let rng = Prng.SFC32.SFC32a();
  /// rng.init(0);
  /// rng.next(); // -> 1_363_572_419
  /// ```
  public func next(self : SFC32) : Nat32 {
    let a = nat16To32(self[0]) | (nat16To32(self[1]) << 16);
    let b = nat16To32(self[2]) | (nat16To32(self[3]) << 16);
    let c = nat16To32(self[4]) | (nat16To32(self[5]) << 16);
    let d = nat16To32(self[6]) | (nat16To32(self[7]) << 16);

    let p = nat16To32(self[8]);
    let q = nat16To32(self[9]);
    let r = nat16To32(self[10]);

    let result = a +% b +% d;

    let na = b ^ (b >> q);
    let nb = c +% (c << r);
    let nc = (c <<> p) +% result;
    let nd = d +% 1;

    let (a0, a1, a2, a3) = Prim.explodeNat32(na);
    let (b0, b1, b2, b3) = Prim.explodeNat32(nb);
    let (c0, c1, c2, c3) = Prim.explodeNat32(nc);
    let (d0, d1, d2, d3) = Prim.explodeNat32(nd);
    self[0] := nat8To16(a2) << 8 | nat8To16(a3);
    self[1] := nat8To16(a0) << 8 | nat8To16(a1);
    self[2] := nat8To16(b2) << 8 | nat8To16(b3);
    self[3] := nat8To16(b0) << 8 | nat8To16(b1);
    self[4] := nat8To16(c2) << 8 | nat8To16(c3);
    self[5] := nat8To16(c0) << 8 | nat8To16(c1);
    self[6] := nat8To16(d2) << 8 | nat8To16(d3);
    self[7] := nat8To16(d0) << 8 | nat8To16(d1);

    result;
  };

  /// Ok to use
  public func SFC32a(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(21, 9, 3, seed);

  /// Ok to use
  public func SFC32b(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(15, 8, 3, seed);

  /// Not recommended. Use `SFC32a` or `SFC32b` version.
  public func SFC32c(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(25, 8, 3, seed);
};
