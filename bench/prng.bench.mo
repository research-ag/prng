import Array "mo:base/Array";
import Bench "mo:bench";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Text "mo:base/Text";

import Prng "../src";

module {

  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Prng");
    bench.description("Benchmark N `next` calls for different PRNG methods");

    let rows = [
      "Seiran128",
      "SFC64",
      "SFC32",
    ];

    let cols = [
      "10",
      "100",
      "1000",
      "10000",
    ];

    bench.rows(rows);
    bench.cols(cols);

    let methods : [{ next : () -> Any }] = [
      Prng.Seiran128(),
      Prng.SFC64a(),
      Prng.SFC32a(),
    ];

    bench.runner(
      func(row, col) {
        let ?ri = Array.indexOf<Text>(row, rows, Text.equal) else Prim.trap("Cannot determine row: " # row);
        let ?n = Nat.fromText(col) else Prim.trap("Cannot parse N");
        let method = methods[ri];
        for (i in Iter.range(1, n)) {
          ignore method.next();
        };
      }
    );

    bench;
  };
};
