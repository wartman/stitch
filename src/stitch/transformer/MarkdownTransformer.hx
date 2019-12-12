package stitch.transformer;

import stitch.types.Markdown;

class MarkdownTransformer {
  
  public static function __decode(info:Info, data:String):Markdown {
    return new Markdown(data);
  }

  public static function __encode(data:Markdown):String {
    return data.raw;
  }

}
