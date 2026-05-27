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

module SFC64 {
  /// State of an SFC 64-bit generator.
  /// Layout: `[a, b, c, d, p, q, r]`
  public type SFC64 = [var Nat64];

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
    let prng : SFC64 = [var 0, 0, 0, 0, p, q, r];
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
    self[0] := seed1;
    self[1] := seed2;
    self[2] := seed3;
    self[3] := 1;

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
    let a = self[0];
    let b = self[1];
    let c = self[2];
    let d = self[3];

    let result = a +% b +% d;

    self[0] := b ^ (b >> self[5]);
    self[1] := c +% (c << self[6]);
    self[2] := (c <<> self[4]) +% result;
    self[3] := d +% 1;

    result;
  };

  /// SFC64a is the same as numpy.
  /// See: [sfc64_next()](https://github.com/numpy/numpy/blob/b6d372c25fab5033b828dd9de551eb0b7fa55800/numpy/random/src/sfc64/sfc64.h#L28)
  public func SFC64a(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(24, 11, 3, seed);

  /// Not recommended. Use `SFC64a` version.
  public func SFC64b(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(25, 12, 3, seed);
};
