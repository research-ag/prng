import Prim "mo:prim";

import SFC32 "../src/SFC32";

let prng3 = SFC32.SFC32a();

Prim.debugPrint("Testing SFC32 (default seed)");
for (
  v in [
    0xB1BE92EA : Nat32,
    0x35152DE6 : Nat32,
    0xF57C4105 : Nat32,
    0xD1F7B548 : Nat32,
  ].vals()
) {
  let n = prng3.next();
  assert (v == n);
};

let prng4 = SFC32.SFC32a();
prng4.init3(1, 2, 3);

Prim.debugPrint("Testing SFC32 (split seed)");
for (
  v in [
    0x736A3B41 : Nat32,
    0xB2E53014 : Nat32,
    0x3D56E4C7 : Nat32,
    0xEDA6A65F : Nat32,
  ].vals()
) {
  let n = prng4.next();
  assert (v == n);
};
