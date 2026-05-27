/// 128-bit Seiran PRNG.
///
/// A deterministic statistical pseudo-random number generator with 128 bits
/// of state, producing `Nat64` output values. Provides constant-time `jump32`,
/// `jump64`, and `jump96` operations for advancing the state by `2^32`,
/// `2^64`, and `2^96` steps respectively — useful for splitting a stream
/// across parallel workers.
///
/// Not cryptographically secure.
///
/// Reference: https://github.com/andanteyk/prng-seiran
///
/// ```motoko name=import
/// import Seiran128 "mo:prng/Seiran128";
/// ```
///
/// Copyright: 2023-26 MR Research AG
/// Main author: Timo Hanke (timohanke)
/// Contributors: Andy Gura (AndyGura), react0r-com

import Prim "mo:prim";

module Seiran128 {
  let nat8To16 = Prim.nat8ToNat16;
  let nat16To32 = Prim.nat16ToNat32;
  let nat32To16 = Prim.nat32ToNat16;
  let nat32To64 = Prim.nat32ToNat64;
  let nat64To32 = Prim.nat64ToNat32;

  /// State of a Seiran128 generator.
  /// Layout: two logical `Nat64` words `a` and `b`, each split little-endian
  /// into four `Nat16` slots — `a = [s0, s1, s2, s3]`, `b = [s4, s5, s6, s7]`,
  /// where slot `0` and `4` hold the lowest 16 bits.
  public type Seiran128 = [var Nat16];

  /// Default seed for Seiran128 generators.
  public let defaultSeiran128Seed : Nat64 = 0;

  // Reassemble a Nat64 from four little-endian Nat16 slots starting at `base`.
  func readU64(self : Seiran128, base : Nat) : Nat64 {
    let w0 = nat32To64(nat16To32(self[base]));
    let w1 = nat32To64(nat16To32(self[base + 1]));
    let w2 = nat32To64(nat16To32(self[base + 2]));
    let w3 = nat32To64(nat16To32(self[base + 3]));
    w0 | (w1 << 16) | (w2 << 32) | (w3 << 48);
  };

  // Split a Nat64 into four little-endian Nat16 slots starting at `base`.
  func writeU64(self : Seiran128, base : Nat, v : Nat64) {
    self[base] := nat32To16(nat64To32(v & 0xFFFF));
    self[base + 1] := nat32To16(nat64To32((v >> 16) & 0xFFFF));
    self[base + 2] := nat32To16(nat64To32((v >> 32) & 0xFFFF));
    self[base + 3] := nat32To16(nat64To32(v >> 48));
  };

  /// Constructs a Seiran128 generator.
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.Seiran128.new();
  /// ```
  public func new(seed : (implicit : (defaultSeiran128Seed : Nat64))) : Seiran128 {
    let prng : Seiran128 = [var 0, 0, 0, 0, 0, 0, 0, 0];
    prng.init(seed);
    prng;
  };

  /// Initializes the PRNG state with a particular seed.
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.Seiran128.new();
  /// rng.init(0);
  /// ```
  public func init(self : Seiran128, seed : (implicit : (defaultSeiran128Seed : Nat64))) {
    let a = seed *% 6364136223846793005 +% 1442695040888963407;
    let b = a *% 6364136223846793005 +% 1442695040888963407;
    writeU64(self, 0, a);
    writeU64(self, 4, b);
  };

  /// Returns one output and advances the PRNG's state.
  ///
  /// Example:
  /// ```motoko
  /// let rng = Prng.Seiran128.new();
  /// rng.init(0);
  /// rng.next(); // -> 11_505_474_185_568_172_049
  /// ```
  public func next(self : Seiran128) : Nat64 {
    let a = nat32To64(nat16To32(self[0])) | (nat32To64(nat16To32(self[1])) << 16) | (nat32To64(nat16To32(self[2])) << 32) | (nat32To64(nat16To32(self[3])) << 48);
    let b = nat32To64(nat16To32(self[4])) | (nat32To64(nat16To32(self[5])) << 16) | (nat32To64(nat16To32(self[6])) << 32) | (nat32To64(nat16To32(self[7])) << 48);

    let result = (((a +% b) *% 9) <<> 29) +% a;

    let na = a ^ (b <<> 29);
    let nb = a ^ (b << 9);
 
    let (a0, a1, a2, a3, a4, a5, a6, a7) = Prim.explodeNat64(na);
    let (b0, b1, b2, b3, b4, b5, b6, b7) = Prim.explodeNat64(nb);
    self[0] := nat8To16(a6) << 8 | nat8To16(a7);
    self[1] := nat8To16(a4) << 8 | nat8To16(a5);
    self[2] := nat8To16(a2) << 8 | nat8To16(a3);
    self[3] := nat8To16(a0) << 8 | nat8To16(a1);
    self[4] := nat8To16(b6) << 8 | nat8To16(b7);
    self[5] := nat8To16(b4) << 8 | nat8To16(b5);
    self[6] := nat8To16(b2) << 8 | nat8To16(b3);
    self[7] := nat8To16(b0) << 8 | nat8To16(b1);

    result;
  };

  // Given a bit polynomial, advances the state (see below functions)
  func jump(self : Seiran128, jumppoly : [Nat64]) {
    var t0 : Nat64 = 0;
    var t1 : Nat64 = 0;

    for (jp in jumppoly.values()) {
      var w = jp;
      var i_ : Nat8 = 64;
      while (i_ > 0) {
        if (w & 1 == 1) {
          t0 ^= readU64(self, 0);
          t1 ^= readU64(self, 4);
        };

        w >>= 1;
        ignore next(self);
        i_ -%= 1;
      };
    };

    writeU64(self, 0, t0);
    writeU64(self, 4, t1);
  };

  /// Advances the state 2^32 times.
  public func jump32(self : Seiran128) = jump(self, [0x40165CBAE9CA6DEB, 0x688E6BFC19485AB1]);

  /// Advances the state 2^64 times.
  public func jump64(self : Seiran128) = jump(self, [0xF4DF34E424CA5C56, 0x2FE2DE5C2E12F601]);

  /// Advances the state 2^96 times.
  public func jump96(self : Seiran128) = jump(self, [0x185F4DF8B7634607, 0x95A98C7025F908B2]);
};
