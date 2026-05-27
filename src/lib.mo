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

import Seiran128_ "./Seiran128";
import SFC64_ "./SFC64";
import SFC32_ "./SFC32";

module {

  public let Seiran128 = Seiran128_;
  public let SFC64 = SFC64_;
  public let SFC32 = SFC32_;

};
