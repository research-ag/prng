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

module {
  public module Seiran128 {
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
      let result = (((self.a +% self.b) *% 9) <<> 29) +% self.a;

      let a_ = self.a;
      self.a := self.a ^ (self.b <<> 29);
      self.b := a_ ^ (self.b << 9);

      result;
    };

    // Given a bit polynomial, advances the state (see below functions)
    func jump(self : Seiran128, jumppoly : [Nat64]) {
      var t0 : Nat64 = 0;
      var t1 : Nat64 = 0;

      for (jp in jumppoly.vals()) {
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

  public module SFC64 {
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

    /// Initializes the PRNG state with a hardcoded seed.
    /// No argument is required.
    ///
    /// Example:
    /// ```motoko
    /// import Prng "mo:prng";
    /// let rng = Prng.SFC64.SFC64a();
    /// rng.init_pre();
    /// ```
    //public func init_pre(self : SFC64) = init(self, 0xcafef00dbeef5eed);

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
      let tmp = self.a +% self.b +% self.d;
      self.a := self.b ^ (self.b >> self.q);
      self.b := self.c +% (self.c << self.r);
      self.c := (self.c <<> self.p) +% tmp;
      self.d +%= 1;
      tmp;
    };

    /// SFC64a is the same as numpy.
    /// See: [sfc64_next()](https:///github.com/numpy/numpy/blob/b6d372c25fab5033b828dd9de551eb0b7fa55800/numpy/random/src/sfc64/sfc64.h#L28)
    public func SFC64a(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(24, 11, 3, seed);

    /// Not recommended. Use `SFC64a` version.
    public func SFC64b(seed : (implicit : (defaultSFC64Seed : Nat64))) : SFC64 = new(25, 12, 3, seed);
  };

  public module SFC32 {
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

    /// Initializes the PRNG state with a hardcoded seed.
    /// No argument is required.
    ///
    /// Example:
    /// ```motoko
    /// import Prng "mo:prng";
    /// let rng = Prng.SFC32.SFC32a();
    /// rng.init_pre();
    /// ```
    //public func init_pre(self : SFC32) = init(self, 0xbeef5eed);

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
      let tmp = self.a +% self.b +% self.d;
      self.a := self.b ^ (self.b >> self.q);
      self.b := self.c +% (self.c << self.r);
      self.c := (self.c <<> self.p) +% tmp;
      self.d +%= 1;
      tmp;
    };

    /// Ok to use
    public func SFC32a(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(21, 9, 3, seed);

    /// Ok to use
    public func SFC32b(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(15, 8, 3, seed);

    /// Not recommended. Use `SFC32a` or `SFC32b` version.
    public func SFC32c(seed : (implicit : (defaultSFC32Seed : Nat32))) : SFC32 = new(25, 8, 3, seed);
  };
};
