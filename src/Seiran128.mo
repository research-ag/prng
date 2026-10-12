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
  let nat32To64 = Prim.nat32ToNat64;
  let nat64To32 = Prim.nat64ToNat32;

  /// State of a Seiran128 generator.
  /// Layout: two logical `Nat64` words `a` and `b`, each split into two
  /// `Nat32` slots, low half first — `a = [s0, s1]`, `b = [s2, s3]`.
  public type Seiran128 = [var Nat32];

  /// Default seed for Seiran128 generators.
  public let defaultSeiran128Seed : Nat64 = 0;

  // Reassemble a Nat64 from two Nat32 slots (low half first) starting at `base`.
  func readU64(self : Seiran128, base : Nat) : Nat64 {
    nat32To64(self[base]) | (nat32To64(self[base + 1]) << 32);
  };

  // Split a Nat64 into two Nat32 slots (low half first) starting at `base`.
  func writeU64(self : Seiran128, base : Nat, v : Nat64) {
    self[base] := nat64To32(v & 0xFFFF_FFFF);
    self[base + 1] := nat64To32(v >> 32);
  };

  /// Constructs a Seiran128 generator.
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.Seiran128.new();
  /// ```
  public func new(seed : (implicit : (defaultSeiran128Seed : Nat64))) : Seiran128 {
    let prng : Seiran128 = [var 0, 0, 0, 0];
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
    writeU64(self, 2, b);
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
    let a = nat32To64(self[0]) | (nat32To64(self[1]) << 32);
    let b = nat32To64(self[2]) | (nat32To64(self[3]) << 32);

    let result = (((a +% b) *% 9) <<> 29) +% a;

    let na = a ^ (b <<> 29);
    let nb = a ^ (b << 9);

    self[0] := nat64To32(na & 0xFFFF_FFFF);
    self[1] := nat64To32(na >> 32);
    self[2] := nat64To32(nb & 0xFFFF_FFFF);
    self[3] := nat64To32(nb >> 32);

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
          t1 ^= readU64(self, 2);
        };

        w >>= 1;
        ignore next(self);
        i_ -%= 1;
      };
    };

    writeU64(self, 0, t0);
    writeU64(self, 2, t1);
  };

  /// Advances the state 2^32 times.
  public func jump32(self : Seiran128) = jump(self, [0x40165CBAE9CA6DEB, 0x688E6BFC19485AB1]);

  /// Advances the state 2^64 times.
  public func jump64(self : Seiran128) = jump(self, [0xF4DF34E424CA5C56, 0x2FE2DE5C2E12F601]);

  /// Advances the state 2^96 times.
  public func jump96(self : Seiran128) = jump(self, [0x185F4DF8B7634607, 0x95A98C7025F908B2]);
};
