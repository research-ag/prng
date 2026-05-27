import Prim "mo:prim";

import SFC64 "../src/SFC64";

let prng1 = SFC64.SFC64a();

Prim.debugPrint("Testing SFC64 (default seed)");
for (
  v in [
    0xC85C4D72435E6052 : Nat64,
    0x578AB8DCF2A49A64 : Nat64,
    0x8F3B7045FBEE3B23 : Nat64,
    0xC4BC2F2013F16994 : Nat64,
  ].vals()
) {
  let n = prng1.next();
  assert (v == n);
};

let prng2 = SFC64.SFC64a();
prng2.init3(1, 2, 3);

Prim.debugPrint("Testing SFC64 (split seed)");
for (
  v in [
    0x43F18723CBD74146 : Nat64,
    0x0274759CF623808D : Nat64,
    0x709CC2D648942177 : Nat64,
    0x410445D3D048B085 : Nat64,
  ].vals()
) {
  let n = prng2.next();
  assert (v == n);
};

Prim.debugPrint("Testing SFC64 (numpy)");
// The seed values were created with numpy like this:
//   import numpy
//   ss = numpy.random.SeedSequence(0)
//   ss.generate_state(3, dtype='uint64')
// produces output:
//   array([15793235383387715774, 12390638538380655177,  2361836109651742017], dtype=uint64)
// Then the next() values were created with numpy like this:
//   bg = numpy.random.SFC64(ss)
//   bg.random_raw(2)
// produces output:
//   array([10490465040999277362,  4331856608414834465], dtype=uint64)
let c = SFC64.new(24, 11, 3);
c.init3(15793235383387715774, 12390638538380655177, 2361836109651742017);
assert ([c.next(), c.next()] == [10490465040999277362, 4331856608414834465]);
