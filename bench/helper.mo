module {

  public type Schema = {
    name : Text;
    description : Text;
    rows : [Text];
    cols : [Text];
  };

  public class V1(schema : Schema, run : (Nat, Nat) -> ()) {
    public func getVersion() : Nat = 1;
    public func getSchema() : Schema = schema;
    public let runCell = run;
  };
}