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
/// Copyright: 2023 MR Research AG
/// Main author: react0r-com
/// Contributors: Timo Hanke (timohanke)

module Seiran128 {
  /// State of a Seiran128 generator.
  public type Seiran128 = {
    var a : Nat64;
    var b : Nat64;
  };

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
    let prng : Seiran128 = { var a = 0; var b = 0 };
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
    self.a := seed *% 6364136223846793005 +% 1442695040888963407;
    self.b := self.a *% 6364136223846793005 +% 1442695040888963407;
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
    let a_ = self.a;
    let b_ = self.b;

    let result = (((a_ +% b_) *% 9) <<> 29) +% a_;

    self.a := a_ ^ (b_ <<> 29);
    self.b := a_ ^ (b_ << 9);

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
          t0 ^= self.a;
          t1 ^= self.b;
        };

        w >>= 1;
        ignore next(self);
        i_ -%= 1;
      };
    };

    self.a := t0;
    self.b := t1;
  };

  /// Advances the state 2^32 times.
  public func jump32(self : Seiran128) = jump(self, [0x40165CBAE9CA6DEB, 0x688E6BFC19485AB1]);

  /// Advances the state 2^64 times.
  public func jump64(self : Seiran128) = jump(self, [0xF4DF34E424CA5C56, 0x2FE2DE5C2E12F601]);

  /// Advances the state 2^96 times.
  public func jump96(self : Seiran128) = jump(self, [0x185F4DF8B7634607, 0x95A98C7025F908B2]);
};
