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

module SFC64 {
  /// State of an SFC 64-bit generator.
  public type SFC64 = {
    p : Nat64;
    q : Nat64;
    r : Nat64;
    var a : Nat64;
    var b : Nat64;
    var c : Nat64;
    var d : Nat64;
  };

  /// Default seed for SFC64 generators.
  public let defaultSFC64Seed : Nat64 = 0xcafef00dbeef5eed;

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
    let prng : SFC64 = {
      p;
      q;
      r;
      var a = 0;
      var b = 0;
      var c = 0;
      var d = 0;
    };
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
    self.a := seed1;
    self.b := seed2;
    self.c := seed3;
    self.d := 1;

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
    let a_ = self.a;
    let b_ = self.b;
    let c_ = self.c;
    let d_ = self.d;

    let result = a_ +% b_ +% d_;

    self.a := b_ ^ (b_ >> self.q);
    self.b := c_ +% (c_ << self.r);
    self.c := (c_ <<> self.p) +% result;
    self.d := d_ +% 1;

    result;
  };

  /// SFC64a is the same as numpy.
  /// See: [sfc64_next()](https:///github.com/numpy/numpy/blob/b6d372c25fab5033b828dd9de551eb0b7fa55800/numpy/random/src/sfc64/sfc64.h#L28)
  public func SFC64a(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(24, 11, 3, seed);

  /// Not recommended. Use `SFC64a` version.
  public func SFC64b(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(25, 12, 3, seed);
};
