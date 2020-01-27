package stitch.connection;

import haxe.ds.Option;
import stitch.Connection;
import stitch.Info;

using sys.FileSystem;
using sys.io.File;
using haxe.io.Path;
using tink.CoreApi;

class FileConnection implements Connection {
  
  final root:String;

  public function new(root:String) {
    this.root = root;
  }

  public function getInfo(path:String):Promise<Info> {
    return switch resolve(path) {
      case Some(path):
        var stat = FileSystem.stat(path);
        return {
          name: path.withoutDirectory().withoutExtension(),
          path: path.directory().split('/'),
          extension: path.extension(),
          created: stat.ctime,
          modified: stat.mtime,
          fullPath: path
        };
      case None: new Error(NotFound, 'The file ${path} does not exist');
    }
  }

  public function list(dir:String):Promise<Array<String>> {
    return FileSystem.readDirectory(Path.join([ root, dir ]));
  }

  public function read(path:String):Promise<String> {
    return switch resolve(path) {
      case Some(path): File.getContent(path);
      case None: new Error(NotFound, 'The file ${path} does not exist');
    }
  }

  public function write(path:String, data:String):Promise<Bool> {
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

  public function remove(path:String):Promise<Bool> {
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