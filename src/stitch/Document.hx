package stitch;

using haxe.io.Path;

typedef DocumentObject = {
  name:String,
  path:String,
  contents:String,
  created:Date,
  modified:Date
};

@:forward
abstract Document(DocumentObject) from DocumentObject {

  public static function create(path:String, contents:String) {
    var time = Date.now();
    return new Document({
      name: getNameFromPath(path),
      path: path,
      contents: contents,
      created: time,
      modified: time
    });
  }

  public static function getNameFromPath(path:String) {
    return path.withoutDirectory().withoutExtension();
  }

  public inline function new(props:DocumentObject) {
    this = props;
  }

}
