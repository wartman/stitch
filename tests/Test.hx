import sys.FileSystem;
import medic.Runner;
import stitch.*;
import stitch.field.*;
import stitch.connection.*;
import stitch.formatter.*;

using haxe.io.Path;

class Test {

  public static function main() {
    var runner = new Runner();
    var resources = Path.join([ Sys.programPath().directory().directory(), 'tests/res' ]);
    var runner = new Runner();
    
    if (!FileSystem.exists(resources)) {
      throw 'The required test folder "${resources}" was not found';
    }

    runner.add(new ModelTest());
    runner.add(new StoreTest());
    
    runner.add(new FileConnectionTest(resources));
    runner.add(new MemoryConnectionTest());

    runner.add(new TextFormatterTest());

    runner.add(new MetaFieldTest());

    runner.run();
  }

}