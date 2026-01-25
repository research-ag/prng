module {

  public type Schema = {
    name : Text;
    description : Text;
    rows : [Text];
    cols : [Text];
  };

  public class V1(schema : Schema, run : (Nat, Nat) -> ()) {
    // unused stuff just to satisfy types
    public func name(_ : Text) {};
    public func description(_ : Text) {};
    public func rows(_ : [Text]) {};
    public func cols(_ : [Text]) {};
    public func runner(_ : (Text, Text) -> ()) {};
    // end unused stuff

    public func getVersion() : Nat = 1;
    public func getSchema() : Schema = schema;
    public let runCell = run;
  };
}