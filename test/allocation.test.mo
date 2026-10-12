// @testmode wasi

// Asserts that `next()` allocates nothing except its return value, so that
// later commits don't accidentally introduce allocations in the state update.
//
// Follows caffeinelabs/motoko-core's test/List.allocation.test.mo:
// `Prim.rts_total_allocation()` is a monotonic counter of all bytes ever
// allocated, so a delta around a code section is exactly what that section
// allocated (independent of GC). This requires wasi test mode (real RTS); in
// the interpreter the counter is not maintained, and the "allocation is
// detected" harness test below fails, so a wrong test mode cannot produce
// silent false passes.
//
// The return value cannot be kept from allocating: `next` boxes a large
// Nat64 before the caller sees it, whether the caller uses it or not. The
// expected numbers are therefore specific to the 64-bit heap of moc 2.0.0
// (the `[toolchain] moc`):
// - A Nat64 below 2^60 is stored unboxed; from 2^60 on it is boxed in a
//   32-byte object (2-word header, 8-byte payload).
// - A Nat32 is always unboxed.
// The test counts the large outputs on a twin generator (same seed, outside
// the measurement) and expects exactly 32 bytes per large output.

import Prim "mo:prim";
import { test } "mo:test";

import SFC32 "../src/SFC32";
import SFC64 "../src/SFC64";
import Seiran128 "../src/Seiran128";

let n = 1_000;
let boxedNat64Size = 32;
let unboxedNat64Limit : Nat64 = 0x1000_0000_0000_0000; // 2^60

// Bytes allocated by `f`.
func alloc(f : () -> ()) : Nat {
  let before = Prim.rts_total_allocation();
  f();
  Prim.rts_total_allocation() - before;
};

// Runs `f` once as a warm-up, so one-time allocations are not counted, then
// returns the bytes allocated by a second run.
func allocDelta(f : () -> ()) : Nat {
  f();
  alloc(f);
};

// Number of outputs of `next` among the following `count` calls that are
// boxed on the 64-bit heap.
func countBoxed(next : () -> Nat64, count : Nat) : Nat {
  var boxed = 0;
  var i = 0;
  while (i < count) {
    if (next() >= unboxedNat64Limit) boxed += 1;
    i += 1;
  };
  boxed;
};

// --- Harness validation ---

test(
  "measurement harness: empty loop does not allocate",
  func() {
    let delta = allocDelta(func() { var i = 0; while (i < n) { i += 1 } });
    assert delta == 0;
  },
);

test(
  "measurement harness: allocation is detected",
  func() {
    var r : [var Nat] = [var];
    let delta = allocDelta(func() { r := Prim.Array_init(8, 0) });
    assert delta > 0;
  },
);

test(
  "measurement harness: one boxed Nat64 is 32 bytes",
  func() {
    var r : [var Nat64] = Prim.Array_init(1, 0 : Nat64);
    let large : Nat64 = unboxedNat64Limit;
    let delta = allocDelta(func() { r[0] := large +% 1 });
    assert delta == boxedNat64Size;
  },
);

// --- next() ---

test(
  "SFC32.next does not allocate",
  func() {
    let rng = SFC32.SFC32a();
    let delta = allocDelta(func() { var i = 0; while (i < n) { ignore SFC32.next(rng); i += 1 } });
    if (delta != 0) Prim.debugPrint("SFC32.next: " # debug_show delta);
    assert delta == 0;
  },
);

test(
  "SFC64.next allocates only its boxed return values",
  func() {
    let rng = SFC64.SFC64a();
    let twin = SFC64.SFC64a();
    ignore countBoxed(func() = SFC64.next(twin), n); // warm-up run
    let expected = boxedNat64Size * countBoxed(func() = SFC64.next(twin), n);
    let delta = allocDelta(func() { var i = 0; while (i < n) { ignore SFC64.next(rng); i += 1 } });
    if (delta != expected) Prim.debugPrint("SFC64.next: " # debug_show delta # ", expected " # debug_show expected);
    assert delta == expected;
  },
);

test(
  "Seiran128.next allocates only its boxed return values",
  func() {
    let rng = Seiran128.new();
    let twin = Seiran128.new();
    ignore countBoxed(func() = Seiran128.next(twin), n); // warm-up run
    let expected = boxedNat64Size * countBoxed(func() = Seiran128.next(twin), n);
    let delta = allocDelta(func() { var i = 0; while (i < n) { ignore Seiran128.next(rng); i += 1 } });
    if (delta != expected) Prim.debugPrint("Seiran128.next: " # debug_show delta # ", expected " # debug_show expected);
    assert delta == expected;
  },
);
