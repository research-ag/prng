import Array "mo:core/Array";
import Nat "mo:core/Nat";
import Runtime "mo:core/Runtime";
import Text "mo:core/Text";

import Bench "mo:bench";

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
        let ?ri = rows.indexOf(Text.equal, row) else Runtime.trap("Cannot determine row: " # row);
        let ?n = Nat.fromText(col) else Runtime.trap("Cannot parse N");
        let next = methods[ri].next;
        for (i in Nat.range(0, n)) {
          ignore next();
        };
      }
    );

    bench;
  };
};
