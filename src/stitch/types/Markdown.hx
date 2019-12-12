package stitch.types;

import Markdown.markdownToHtml;

typedef MarkdownImpl = {
  raw:String,
  parsed:String
};

@:forward
abstract Markdown(MarkdownImpl) from MarkdownImpl {
  
  @:from public static function ofString(raw:String) {
    return new Markdown(raw, null);
  }

  public function new(raw, ?parsed) {
    this = {
      raw: raw,
      parsed: parsed
    };
  }

  @:to public function toString():String {
    if (this.parsed == null) {
      this.parsed = markdownToHtml(this.raw);
    }
    return this.parsed;
  }

}
