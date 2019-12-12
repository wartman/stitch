Stitch
======
A framework for creating flat file "databases" (intended for use in things like static site generators).

About
-----

Here's an example blog thing:

```haxe

import stitch.Model;
import stitch.types.Markdown;

enum abstract EntryStatus(String) from String to String {
  var Published;
  var Draft;
  var Trashed;
}

@:repository(
  path = 'entries',
  isDirectory = true
)
class Entry implements Model {
  @:id(info) var id:String;
  @:info var created:Data;
  @:info var modified:Date;
  @:field var status:EntryStatus = Draft;
  @:field var title:String;
  @:field var blocks:Array<Block>;
  @:belongsTo var author:User;
  @:belongsTo @:optional var parent:Entry;
  @:hasMany(on = parent_id) var children:Array<Entry>;
  @:children var images:Array<Image>;
}

class Block implements Model {
  @:id var id:String;
  @:field @:optional var title:String;
  @:field @:optional var content:Markdown; 
  @:field @:optional var images:Array<String>;
  @:field @:optional var menu:Menu;
}


@:repository(
  path = 'menus'
)
class Menu implements Model {
  @:id(info) var id:String;
  @:field var options:Array<MenuOption>;
}

enum abstract MenuOptionType(String) from String to String {
  var Link;
  var Trigger;
}

class MenuOption implements Model {
  @:id var id:String;
  @:field var label:String;
  @:field var type:MenuOptionType = Link;
  @:field var action:String;
}

@:repository(
  path = 'users' 
)
class User implements Model {
  @:id(info) var id:String;
  @:field var username:String;
  @:field var realName:String;
  @:hasMany(on = author_id) var entries:Array<Entry>;
}

```

This will read the following data (using TOML, although Stitch supports all kinds of file types):

```toml
# in `data/entries/foo/_data.toml`

title = "Foo"
status = "Published"
author_id = "admin"

[[blocks]]
  title = "Thing"
  content = """
Here is some content.
It is a block.
Yay.
"""

[[blocks]]
  title = "Some Menu"
  menu.id = "main"
  [[menu.options]]
    type = "Trigger"
    label = "Some Modal?"
    action = "modal:main"
  [[menu.options]]
    type = "Link"
    label = "Yay"
    action = "https://www.peterwartman.com"
```

Loading this data is simple:

```haxe

import haxe.io.Path;
import stitch.Store;
import stitch.connection.FileConnection;
import stitch.formatter.TomlFormatter;

class Main {

    static function main() {
        var root = Path.join([ Sys.getCwd(), 'data' ]);
        var store = new Store(new FileConnection(root), [
            'toml' => new TomlFormatter()
        ]);
        var entries = store.getRepository(Entries)
            .select()
            .where(e -> e.status = Published)
            .all();

        trace(entires.title); // => Foo
        trace(entries.blocks[0].title); // => Thing
        // etc
    }

}

```

> More details later -- still figuring out the API here.
