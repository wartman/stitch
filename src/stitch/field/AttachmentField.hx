package stitch.field;

// Todo: think of a way to make this work using the Connection class?
//       will be good for tests
import sys.FileSystem;
import sys.io.File;

import stitch.*;
import stitch.Field;
import stitch.resource.FolderResource;

using Type;
using haxe.io.Path;
using stitch.ModelTools;

typedef Attachment = {
  src:String
}

class AttachmentField 
  implements ReadOnlyField<Array<Attachment>>
  implements DecodeableField
{

  final model:Model;
  @:prop var path:String;
  @:prop @:optional var extensions:Array<String> = [ 'png', 'jpg', 'jpeg', 'gif' ];
  // @:prop @:optional var isRelative:Bool = false;
  var modelPath:String;
  var attachments:Array<Attachment>;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }

  public function get() {
    if (attachments == null) load();
    return attachments;
  }

  public function getJson() {
    return null;
  }

  public function decode(doc:Document, _:String) {
    switch model.getModelCollection().resource.getClass() {
      case FolderResource: modelPath = doc.path.directory();
      default: modelPath = doc.path.withoutExtension();
    }
  }

  public function load() {
    var realPath = Path.join([ modelPath, path ]);
    attachments = [];
    if (!FileSystem.exists(realPath)) return;
    for (item in FileSystem.readDirectory(realPath)) {
      // this will get complex: we need a way to convert this to the correct
      // path to show in the server :P.
      // for now whatever
      if (extensions.indexOf(item.extension()) > -1) {
        attachments.push({
          src: item
        });
      }
    }
  }

}
