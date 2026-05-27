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

module SFC32 {
  /// State of an SFC 32-bit generator.
  public type SFC32 = {
    p : Nat32;
    q : Nat32;
    r : Nat32;
    var a : Nat32;
    var b : Nat32;
    var c : Nat32;
    var d : Nat32;
  };

  /// Default seed for SFC32 generators.
  public let defaultSFC32Seed : Nat32 = 0xbeef5eed;

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
    let prng : SFC32 = {
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
  /// let rng = Prng.SFC32.SFC32a();
  /// rng.init(0);
  /// rng.next(); // -> 1_363_572_419
  /// ```
  public func next(self : SFC32) : Nat32 {
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

  /// Ok to use
  public func SFC32a(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(21, 9, 3, seed);

  /// Ok to use
  public func SFC32b(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(15, 8, 3, seed);

  /// Not recommended. Use `SFC32a` or `SFC32b` version.
  public func SFC32c(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(25, 8, 3, seed);
};
