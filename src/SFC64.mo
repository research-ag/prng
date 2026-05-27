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
  let nat8To16 = Prim.nat8ToNat16;
  let nat16To32 = Prim.nat16ToNat32;
  let nat32To16 = Prim.nat32ToNat16;
  let nat32To64 = Prim.nat32ToNat64;
  let nat64To32 = Prim.nat64ToNat32;

  /// State of an SFC 64-bit generator.
  /// Layout: state words `a`, `b`, `c`, `d` occupy slots `[0..3]`, `[4..7]`,
  /// `[8..11]`, `[12..15]` respectively — each split little-endian into four
  /// `Nat16` slots, with the lowest 16 bits at the lower index. Tuning
  /// parameters `p`, `q`, `r` live in slots `[16]`, `[17]`, `[18]` as raw
  /// `Nat16` values (they only need to fit shift amounts ≤ 64).
  public type SFC64 = [var Nat16];

  /// Default seed for SFC64 generators.
  public let defaultSFC64Seed : Nat64 = 0xcafef00dbeef5eed;

  // Split a Nat64 into four little-endian Nat16 slots starting at `base`.
  // Used only on the init cold path; `next` inlines packing via `explodeNat64`.
  func writeU64(self : SFC64, base : Nat, v : Nat64) {
    self[base] := nat32To16(nat64To32(v & 0xFFFF));
    self[base + 1] := nat32To16(nat64To32((v >> 16) & 0xFFFF));
    self[base + 2] := nat32To16(nat64To32((v >> 32) & 0xFFFF));
    self[base + 3] := nat32To16(nat64To32(v >> 48));
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
    let p16 = nat32To16(nat64To32(p & 0xFFFF));
    let q16 = nat32To16(nat64To32(q & 0xFFFF));
    let r16 = nat32To16(nat64To32(r & 0xFFFF));
    let prng : SFC64 = [var 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, p16, q16, r16];
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
    writeU64(self, 4, seed2);
    writeU64(self, 8, seed3);
    writeU64(self, 12, 1);

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
    let a = nat32To64(nat16To32(self[0])) | (nat32To64(nat16To32(self[1])) << 16) | (nat32To64(nat16To32(self[2])) << 32) | (nat32To64(nat16To32(self[3])) << 48);
    let b = nat32To64(nat16To32(self[4])) | (nat32To64(nat16To32(self[5])) << 16) | (nat32To64(nat16To32(self[6])) << 32) | (nat32To64(nat16To32(self[7])) << 48);
    let c = nat32To64(nat16To32(self[8])) | (nat32To64(nat16To32(self[9])) << 16) | (nat32To64(nat16To32(self[10])) << 32) | (nat32To64(nat16To32(self[11])) << 48);
    let d = nat32To64(nat16To32(self[12])) | (nat32To64(nat16To32(self[13])) << 16) | (nat32To64(nat16To32(self[14])) << 32) | (nat32To64(nat16To32(self[15])) << 48);

    let p = nat32To64(nat16To32(self[16]));
    let q = nat32To64(nat16To32(self[17]));
    let r = nat32To64(nat16To32(self[18]));

    let result = a +% b +% d;

    let na = b ^ (b >> q);
    let nb = c +% (c << r);
    let nc = (c <<> p) +% result;
    let nd = d +% 1;

    let (a0, a1, a2, a3, a4, a5, a6, a7) = Prim.explodeNat64(na);
    let (b0, b1, b2, b3, b4, b5, b6, b7) = Prim.explodeNat64(nb);
    let (c0, c1, c2, c3, c4, c5, c6, c7) = Prim.explodeNat64(nc);
    let (d0, d1, d2, d3, d4, d5, d6, d7) = Prim.explodeNat64(nd);
    self[0] := nat8To16(a6) << 8 | nat8To16(a7);
    self[1] := nat8To16(a4) << 8 | nat8To16(a5);
    self[2] := nat8To16(a2) << 8 | nat8To16(a3);
    self[3] := nat8To16(a0) << 8 | nat8To16(a1);
    self[4] := nat8To16(b6) << 8 | nat8To16(b7);
    self[5] := nat8To16(b4) << 8 | nat8To16(b5);
    self[6] := nat8To16(b2) << 8 | nat8To16(b3);
    self[7] := nat8To16(b0) << 8 | nat8To16(b1);
    self[8] := nat8To16(c6) << 8 | nat8To16(c7);
    self[9] := nat8To16(c4) << 8 | nat8To16(c5);
    self[10] := nat8To16(c2) << 8 | nat8To16(c3);
    self[11] := nat8To16(c0) << 8 | nat8To16(c1);
    self[12] := nat8To16(d6) << 8 | nat8To16(d7);
    self[13] := nat8To16(d4) << 8 | nat8To16(d5);
    self[14] := nat8To16(d2) << 8 | nat8To16(d3);
    self[15] := nat8To16(d0) << 8 | nat8To16(d1);

    result;
  };

  /// SFC64a is the same as numpy.
  /// See: [sfc64_next()](https://github.com/numpy/numpy/blob/b6d372c25fab5033b828dd9de551eb0b7fa55800/numpy/random/src/sfc64/sfc64.h#L28)
  public func SFC64a(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(24, 11, 3, seed);

  /// Not recommended. Use `SFC64a` version.
  public func SFC64b(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(25, 12, 3, seed);
};
