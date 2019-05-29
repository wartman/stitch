package stitch.field;

import Markdown.markdownToHtml;
import stitch.Field;
import stitch.Document;

class MarkdownField 
  implements MutableField<String>
  implements PersistantField
{

  final model:Model;
  var value:String = '';
  var raw:String;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }
  
  public function get() {
    return value;
  }

  public function getJson():Dynamic {
    return get();
  }

  public function getRaw() {
    return raw;
  }

  public function set(value:String) {
    raw = value;
    return this.value = markdownToHtml(value);
  }

  public function encode() {
    return raw;
  }

  public function decode(document:Document, value:String) {
    if (value == null) return;
    set(value);
  }

}
