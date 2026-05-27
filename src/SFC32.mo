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

module SFC32 {
  /// State of an SFC 32-bit generator.
  /// Layout: `[a, b, c, d, p, q, r]`
  public type SFC32 = [var Nat32];

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
    let prng : SFC32 = [var 0, 0, 0, 0, p, q, r];
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
  /// let rng = Prng.SFC32.SFC32a();
  /// rng.init(0);
  /// rng.next(); // -> 1_363_572_419
  /// ```
  public func next(self : SFC32) : Nat32 {
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

  /// Ok to use
  public func SFC32a(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(21, 9, 3, seed);

  /// Ok to use
  public func SFC32b(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(15, 8, 3, seed);

  /// Not recommended. Use `SFC32a` or `SFC32b` version.
  public func SFC32c(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(25, 8, 3, seed);
};
