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

    let seiran = Seiran128.new(0);
    let sfc64 = SFC64.SFC64a();
    let sfc32 = SFC32.SFC32a();
    let rngs : [{ next : () -> Any }] = [
      { next = func() : Any = seiran.next() },
      { next = func() : Any = sfc64.next() },
      { next = func() : Any = sfc32.next() },
    ];

    let ns : [Nat16] = [10, 100, 1000, 10000];

    let run : Bench.Runner = func(ri, ci) {
      let n = ns[ci];
      let next = rngs[ri].next;
      var i : Nat16 = 0;
      while (i < n) {
        ignore next();
        i +%= 1;
      };
    };

    Bench.V1(schema, run);
  };
};
