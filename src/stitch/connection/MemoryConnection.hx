package stitch.connection;

import haxe.ds.Map;
import stitch.Connection;
import stitch.Document;

using haxe.io.Path;

typedef FakeDirectory = {
  dirs:Map<String, FakeDirectory>,
  documents:Map<String, Document>
};

class MemoryConnection implements Connection {

  final data:FakeDirectory = { dirs: [], documents: [] };

  public function new(?raw:Map<String, Dynamic>) {
    if (raw != null) for (id => value in raw) {
      if (!Std.is(value, String)) { // uh
        var sub:Map<String, String> = value;
        for (key => value in sub) {
          write(Path.join([ id, key ]), value);
        }
      } else {
        write(id, value);
      }
    }
  }

  public function list(path:String):Array<String> {
    var parts = path.normalize().split('/');
    var dir = data;
    for (part in parts) {
      dir = dir.dirs.get(part);
      if (dir == null) return [];
    }
    return [for (k in dir.dirs.keys()) k]
      .concat([for (k in dir.documents.keys()) k]);
  }

  public function exists(path:String):Bool {
    var parts = path.normalize().split('/');
    var dir = data;
    for (part in parts) {
      if (part.extension() != '') {
        return dir.documents.exists(part);
      }
      dir = dir.dirs.get(part);
      if (dir == null) return false;
    }
    return dir != null;
  }

  public function read(path:String):Document {
    var parts = path.normalize().split('/');
    var file = parts.pop();
    var dir = data;
    for (part in parts) {
      dir = dir.dirs.get(part);
      if (dir == null) return null;
    }
    return dir.documents.get(file);
  }

  public function write(path:String, content:String):Bool {
    var parts = path.normalize().split('/');
    var file = parts.pop();
    var dir = data;
    
    for (part in parts) {
      if (!dir.dirs.exists(part)) {
        dir.dirs.set(part, { dirs: [], documents: [] });
      }
      dir = dir.dirs.get(part);
    }

    if (dir.documents.exists(file)) {
      var c = dir.documents.get(file);
      c.contents = content;
      c.modified = Date.now();
      return true;
    }

    dir.documents.set(file, Document.create(path, content));
    return true;
  }

  public function remove(path:String):Bool {
    var parts = path.normalize().split('/');
    var file = parts.pop();
    var dir = data;
    if (file == null) return false;
    for (part in parts) {
      dir = dir.dirs.get(part);
      if (dir == null) return false;
    }
    if (dir.documents.exists(file)) {
      dir.documents.remove(file);
      return true;
    }
    if (dir.dirs.exists(file)) {
      dir.dirs.remove(file);
      return true;
    }
    return false;
  }

}
