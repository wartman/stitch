package stitch.connection;

import haxe.ds.Option;
import stitch.Connection;
import stitch.Info;

using sys.FileSystem;
using sys.io.File;
using haxe.io.Path;

class FileConnection implements Connection {
  
  final root:String;

  public function new(root:String) {
    this.root = root;
  }

  public function getInfo(path:String):Info {
    return switch resolve(path) {
      case Some(path):
        var stat = FileSystem.stat(path);
        return {
          name: path.withoutDirectory().withoutExtension(),
          path: path.directory().split('/'),
          extension: path.extension(),
          created: stat.ctime,
          modified: stat.mtime
        };
      case None: null;
    }
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

  public function read(path:String):String {
    return switch resolve(path) {
      case Some(path): File.getContent(path);
      case None: null;
    }
  }

  public function write(path:String, data:String):Bool {
    var path = Path.join([ root, path ]).normalize();
    var dir = path.directory();
    if (!dir.isDirectory()) {
      FileSystem.createDirectory(dir);
    }
    if (dir.exists() && !dir.isDirectory()) {
      return false;
    }
    File.saveContent(path, data);
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
    var path = Path.join([ root, path ]).normalize();
    if (path.exists()) return Some(path);
    return None;
  }

}