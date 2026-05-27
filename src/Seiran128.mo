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

module Seiran128 {
  /// State of a Seiran128 generator.
  public type Seiran128 = [var Nat64];

  /// Default seed for Seiran128 generators.
  public let defaultSeiran128Seed : Nat64 = 0;

  /// Constructs a Seiran128 generator.
  ///
  /// Example:
  /// ```motoko
  /// import Prng "mo:prng";
  /// let rng = Prng.Seiran128.new();
  /// ```
  public func new(seed : (implicit : (defaultSeiran128Seed : Nat64))) : Seiran128 {
    let prng : Seiran128 = [var 0, 0];
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
    self[0] := seed *% 6364136223846793005 +% 1442695040888963407;
    self[1] := self[0] *% 6364136223846793005 +% 1442695040888963407;
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
    let a_ = self[0];
    let b_ = self[1];

    let result = (((a_ +% b_) *% 9) <<> 29) +% a_;

    self[0] := a_ ^ (b_ <<> 29);
    self[1] := a_ ^ (b_ << 9);

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
          t0 ^= self[0];
          t1 ^= self[1];
        };

        w >>= 1;
        ignore next(self);
        i_ -%= 1;
      };
    };

    self[0] := t0;
    self[1] := t1;
  };

  /// Advances the state 2^32 times.
  public func jump32(self : Seiran128) = jump(self, [0x40165CBAE9CA6DEB, 0x688E6BFC19485AB1]);

  /// Advances the state 2^64 times.
  public func jump64(self : Seiran128) = jump(self, [0xF4DF34E424CA5C56, 0x2FE2DE5C2E12F601]);

  /// Advances the state 2^96 times.
  public func jump96(self : Seiran128) = jump(self, [0x185F4DF8B7634607, 0x95A98C7025F908B2]);
};
