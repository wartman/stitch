package stitch.connection;

// Note: this is dependent upon a real folder with the following
// structure:
//
// flat -|
//       |- a.json
//       |- b.json
// pages -|
//        |- a
//        |- b
class FileConnectionTest extends ConnectionTest {

  public function new(root) {
    super(() -> new FileConnection(root));
  }

}
