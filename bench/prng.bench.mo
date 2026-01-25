import Bench "helper";
import Prng "../src";

module {
  public func init() : Bench.V1 {
    let schema : Bench.Schema = {
      name = "Prng";
      description = "Benchmark N `next` calls for different PRNGs";
      rows = ["Seiran128", "SFC64", "SFC32"];
      cols = ["10", "100", "1000", "10000"];
    };

    let methods : [{ next : () -> Any }] = [
      Prng.Seiran128(),
      Prng.SFC64a(),
      Prng.SFC32a(),
    ];

    let ns : [Nat16] = [10, 100, 1000, 10000];

    func run(ri : Nat, ci : Nat) {
      let n = ns[ci];
      let next = methods[ri].next;
      var i : Nat16 = 0;
      while (i < n) {
        ignore next();
        i +%= 1;
      };
    };

    Bench.V1(schema, run);
  };
};
