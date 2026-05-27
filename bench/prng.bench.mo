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

    let seiran128 = Prng.Seiran128();
    seiran128.init(0);
    let sfc64a = Prng.SFC64a();
    sfc64a.init_pre();
    let sfc32a = Prng.SFC32a();
    sfc32a.init_pre();

    let functions : [() -> Any] = [
      seiran128.next,
      sfc64a.next,
      sfc32a.next,
    ];

    let ns : [Nat16] = [10, 100, 1000, 10000];

    let run : Bench.Runner = func(ri, ci) {
      let n = ns[ci];
      let next = functions[ri];
      var i : Nat16 = 0;
      while (i < n) {
        ignore next();
        i +%= 1;
      };
    };

    Bench.V1(schema, run);
  };
};
