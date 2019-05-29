package stitch.support;

import stitch.Document;

class DocumentTools {

  public static function createDocument(contents:String) {
    return new Document({
      name: '',
      path: '',
      contents: contents,
      created: Date.now(),
      modified: Date.now()
    });
  }

}
