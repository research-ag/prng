import Bench "mo:bench-helper";
import { Seiran128; SFC64; SFC32 } "../src";

module {
  public func init() : Bench.V1 {
    let schema : Bench.Schema = {
      name = "Prng";
      description = "Benchmark N `next` calls for different PRNGs";
      rows = ["Seiran128", "SFC64", "SFC32"];
      cols = ["10", "100", "1000", "10000"];
    };

    let seiran = Seiran128.new();
    let sfc64 = SFC64.SFC64a();
    let sfc32 = SFC32.SFC32a();

    let ns : [Nat16] = [10, 100, 1000, 10000];

    let run : Bench.Runner = func(ri, ci) {
      let n = ns[ci];
      switch (ri) {
        case (0) {
          var i : Nat16 = 0;
          while (i < n) {
            ignore Seiran128.next(seiran);
            i +%= 1;
          };
        };
        case (1) {
          var i : Nat16 = 0;
          while (i < n) {
            ignore SFC64.next(sfc64);
            i +%= 1;
          };
        };
        case (2) {
          var i : Nat16 = 0;
          while (i < n) {
            ignore SFC32.next(sfc32);
            i +%= 1;
          };
        };
        case (_) assert false;
      };
    };

    Bench.V1(schema, run);
  };
};
