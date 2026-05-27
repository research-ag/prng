import Prim "mo:prim";

import Seiran128 "../src/Seiran128";

let prng = Seiran128.new(401);

Prim.debugPrint("Testing first values");
for (
  v in [
    0x8D4E3629D245305F : Nat64,
    0x941C2B08EB30A631 : Nat64,
    0x4246BDC17AD8CA1E : Nat64,
    0x5D5DA3E87E82EB7C : Nat64,
  ].vals()
) {
  let n = prng.next();
  assert (v == n);
};

Prim.debugPrint("Testing value after jump32");
prng.jump32();
assert (prng.next() == 0x3F6239D7246826A9);

Prim.debugPrint("Testing value after jump64");
prng.jump64();
assert (prng.next() == 0xD780EC14D59D2D33);

Prim.debugPrint("Testing value after jump96");
prng.jump96();
assert (prng.next() == 0x7DA59A41DC8721F2);
