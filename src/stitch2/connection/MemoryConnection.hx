package stitch2.connection;

using haxe.io.Path;

typedef FakeDirectory = {
  dirs:Map<String, FakeDirectory>,
  documents:Map<String, String>
};

class MemoryConnection implements Connection {
  
  final data:FakeDirectory = { dirs: [], documents: [] };

  public function new(?raw:Map<String, Dynamic>) {
    function create(id:String, value:Dynamic) {
      if (Std.is(value, String)) { // uh
        write(id, value);
      } else {
        var sub:Map<String, String> = value;
        for (key => value in sub) {
          create(Path.join([ id, key ]), value);
        }
      }
    }
    
    if (raw != null) for (id => value in raw) {
      create(id, value);
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

  public function list(path:String):Array<String> {
    var parts = path.normalize().split('/');
    var dir = data;
    for (part in parts) {
      dir = dir.dirs.get(part);
      if (dir == null) return [];
    }
    return [ for (file => _ in dir.documents) file ]
      .concat([ for (d => _ in dir.dirs) d ]);
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
