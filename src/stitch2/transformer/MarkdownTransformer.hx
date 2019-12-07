package stitch2.transformer;

import Markdown.markdownToHtml;
import stitch2.Markdown;

class MarkdownTransformer {
  
  public static function __decode(info:Info, data:String):Markdown {
    return {
      raw: data,
      parsed: markdownToHtml(data)
    };
  }

  public static function __encode(data:Markdown):String {
    return data.raw;
  }

}
