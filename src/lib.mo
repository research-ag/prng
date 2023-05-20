/// Collection of pseudo-random number generators
///
/// The algorithms deliver statistical randomness,
/// not cryptographic randomness.

/// Algorithm 1: 128-bit Seiran PRNG
/// See: https://github.com/andanteyk/prng-seiran
///
/// Algorithm 2: SFC
/// This is one of four PRNGs that are part of numpy.
///
/// Copyright: 2023 MR Research AG
/// Main author: react0r-com 
/// Contributors: Timo Hanke (timohanke) 


import { range } "mo:base/Iter";

module {
  public class Seiran128() {

    // state
    var a : Nat64 = 0;
    var b : Nat64 = 0;

    /// Initialize the PRNG with a particular seed
    public func init(seed : Nat64) {
      a := seed *% 6364136223846793005 +% 1442695040888963407;
      b := a *% 6364136223846793005 +% 1442695040888963407;
    };

    /// Return the PRNG result and advance the state
    public func next() : Nat64 {
      let result = (((a +% b) *% 9) <<> 29) +% a;

      let a_ = a;
      a := a ^ (b <<> 29);
      b := a_ ^ (b << 9);

      result;
    };

    /// Given a bit polynomial, advance the state (see below functions)
    func jump(jumppoly : [Nat64]) {
      var t0 : Nat64 = 0;
      var t1 : Nat64 = 0;

      for (jp in jumppoly.vals()) {
        var w = jp;
        for (_ in range(0, 63)) {
          if (w & 1 == 1) {
            t0 ^= a;
            t1 ^= b;
          };

          w >>= 1;
          ignore next();
        };
      };

      a := t0;
      b := t1;
    };

    /// Advance the state 2^32 times
    public func jump32() = jump([0x40165CBAE9CA6DEB, 0x688E6BFC19485AB1]);

    /// Advance the state 2^64 times
    public func jump64() = jump([0xF4DF34E424CA5C56, 0x2FE2DE5C2E12F601]);

    /// Advance the state 2^96 times
    public func jump96() = jump([0x185F4DF8B7634607, 0x95A98C7025F908B2]);
  };

  public class SFC64(p : Nat64, q : Nat64, r : Nat64) {
    // state
    var a : Nat64 = 0;
    var b : Nat64 = 0;
    var c : Nat64 = 0;
    var d : Nat64 = 0;

    // directly set the entire internal state (almost) 
    public func init3(seed1 : Nat64, seed2 : Nat64, seed3 : Nat64) {
      a := seed1;
      b := seed2;
      c := seed3;
      d := 1;

      for (_ in range(0, 11)) ignore next();
    };

    /// default init function with a single seed
    public func init(seed : Nat64) = init3(seed, seed, seed);

    // init without arguments, pre-configured seed
    public func init_pre() = init(0xcafef00dbeef5eed);

    /// return one output value and advance the state
    public func next() : Nat64 {
      let tmp = a +% b +% d;
      a := b ^ (b >> q);
      b := c +% (c << r);
      c := (c <<> p) +% tmp;
      d +%= 1;
      tmp;
    };
  };

  public class SFC32(p : Nat32, q : Nat32, r : Nat32) {
    var a : Nat32 = 0;
    var b : Nat32 = 0;
    var c : Nat32 = 0;
    var d : Nat32 = 0;

    public func init3(seed1 : Nat32, seed2 : Nat32, seed3 : Nat32) {
      a := seed1;
      b := seed2;
      c := seed3;
      d := 1;

      for (_ in range(0, 11)) ignore next();
    };

    public func init(seed : Nat32) = init3(seed, seed, seed);

    public func init_pre() = init(0xbeef5eed);

    public func next() : Nat32 {
      let tmp = a +% b +% d;
      a := b ^ (b >> q);
      b := c +% (c << r);
      c := (c <<> p) +% tmp;
      d +%= 1;
      tmp;
    };
  };

  /// SFC64a is same as numpy:
  /// https:///github.com/numpy/numpy/blob/b6d372c25fab5033b828dd9de551eb0b7fa55800/numpy/random/src/sfc64/sfc64.h#L28
  public func SFC64a() : SFC64 { SFC64(24, 11, 3) };

  /// Use this  
  public func SFC32a() : SFC32 { SFC32(21, 9, 3) };
  
  /// Use this.
  public func SFC32b() : SFC32 { SFC32(15, 8, 3) };

  /// Not recommended. Use `a` version.
  public func SFC64b() : SFC64 { SFC64(25, 12, 3) };

  /// Not recommended. Use `a` version.
  public func SFC32c() : SFC32 { SFC32(25, 8, 3) };
};
