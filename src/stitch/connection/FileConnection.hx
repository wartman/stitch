package stitch.connection;

import haxe.ds.Option;
import stitch.Connection;
import stitch.Document;

using sys.FileSystem;
using sys.io.File;
using haxe.io.Path;

class FileConnection implements Connection {

  final root:String;

  public function new(root:String) {
    this.root = root;
  }

  public function list(dir:String):Array<String> {
    return FileSystem.readDirectory(Path.join([ root, dir ]));
  }

  public function exists(path:String):Bool {
    return switch resolve(path) {
      case Some(_): true;
      case None: false;
    }
  }

  public function read(id:String):Document {
    return switch resolve(id) {
      case Some(path): 
        var stat = FileSystem.stat(path);
        new Document({
          name: Document.getNameFromPath(path),
          path: path,
          contents: File.getContent(path),
          modified: stat.mtime,
          created: stat.ctime
        });
      case None:
        null;
    }
  }

  public function write(id:String, content:String):Bool {
    var path = Path.join([ root, id ]);
    var dir = path.directory();
    if (!dir.isDirectory()) {
      FileSystem.createDirectory(dir);
    }
    if (dir.exists() && !dir.isDirectory()) {
      return false;
    }
    File.saveContent(path, content);
    return true;
  }

  public function remove(path:String):Bool {
    return switch resolve(path) {
      case Some(path):
        if (path.isDirectory()) {
          FileSystem.deleteDirectory(path);
        } else {
          FileSystem.deleteFile(path);
        }
        true;
      default: 
        false;
    }
  }

  function resolve(path:String):Option<String> {
    var path = Path.join([ root, path ]);
    if (path.exists()) return Some(path);
    return None;
  }

}