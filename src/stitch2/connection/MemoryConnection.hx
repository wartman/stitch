package stitch2.connection;

using haxe.io.Path;

typedef FakeDirectory = {
  dirs:Map<String, FakeDirectory>,
  documents:Map<String, String>
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

  public function getInfo(path:String):Info {
    var parts = path.normalize().split('/');
    var file = parts.pop();
    var dir = data;
    for (part in parts) {
      dir = dir.dirs.get(part);
      if (dir == null) return null;
    }
    return {
      created: Date.now(),
      modified: Date.now(),
      extension: file.extension(),
      path: parts,
      name: file.withoutExtension()
    };
  }

  public function listInfo(path:String):Array<Info> {
    var parts = path.normalize().split('/');
    var dir = data;
    for (part in parts) {
      dir = dir.dirs.get(part);
      if (dir == null) return [];
    }
    return [ for (file => _ in dir.documents) {
      created: Date.now(),
      modified: Date.now(),
      extension: file.extension(),
      path: parts,
      name: file.withoutExtension()
    } ];
  }

  public function exists(path:String):Bool {
    var parts = path.normalize().split('/');
    var file = parts.pop();
    var dir = data;
    for (part in parts) {
      dir = dir.dirs.get(part);
      if (dir == null) return false;
    }
    return dir.documents.exists(file);
  }

  public function read(path:String):String {
    var parts = path.normalize().split('/');
    var file = parts.pop();
    var dir = data;
    for (part in parts) {
      dir = dir.dirs.get(part);
      if (dir == null) return null;
    }
    return dir.documents.get(file);
  }

  public function write(path:String, contents:String):Bool {
    var parts = path.normalize().split('/');
    var file = parts.pop();
    var dir = data;
    
    for (part in parts) {
      if (!dir.dirs.exists(part)) {
        dir.dirs.set(part, { dirs: [], documents: [] });
      }
      dir = dir.dirs.get(part);
    }

    dir.documents.set(file, contents);
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
