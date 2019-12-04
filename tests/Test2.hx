import stitch2.*;
import stitch2.connection.MemoryConnection;
import stitch2.parser.JsonParser;

class Test2 {
  
  static function main() {
    var store = new Store(new MemoryConnection([
      'testers' => [
        'one.json' => '{
          "foo": "foo",
          "bar": "bar",
          "sub": {
            "bin": "1",
            "content": "###foo"
          }
        }'
      ]
    ]), [
      'json' => new JsonParser()
    ]);
    var test = store.getRepository(Tester).get('one');
    trace(test);
  }

}

@:repository( path = 'testers' )
class Tester implements Model {
  @:info(name) var id:String;
  @:info var created:Date;
  @:info(modified) var updated:Date;
  @:field var foo:String;
  @:field var bar:String;
  @:field var sub:Sub;
}

class Sub implements Model {
  @:field var bin:Int;
  @:field var content:Markdown;
}
