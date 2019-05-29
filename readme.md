Stitch
======
A framework for creating flat file "databases" (intended for use in things like static site generators).

Decorators and Annotations
--------------------------
Stitch makes heavy use of what I'm terming Decorators and Annotations -- a macro-based
framework that converts metadata into real classes. This makes it easy to extend Stitch
with your fields without ever having to touch macro code yourself. Additionally, 
the DecoratorBuilder enforces types, meaning you will never be able to use an improper decorator.

> Note: although currently errors are almost useless and point to the wrong place. 
But hey, baby steps

See below for examples of this in action.

Model
-----
> Todo: Fields need validation! This should be easy to add.

Stitch models are just data loaded from flat files. Simple!

That said, they are extremely flexible.

Defining a new model is simple:

```haxe
package example;

import stitch.Model;
import stitch.Colleciton;
import stitch.Selection;
import stitch.formatter.YamlFormatter;
import stitch.resource.FolderResource;
import stitch.field.*; // Required -- needed to find decorators

// Every model has a Collection that defines how they can be found and
// other configuration data. This collection becomes available as the static
// property `collection` on the model class.
//
// All options here besides 'path' are optional. In fact, even having a
// `@Colleciton` decorator is optional -- Stitch can derive a path
// from the model's class name if no path is provided.
@Collection(

  // The `path` maps to the folder all documents of this model type
  // will be saved.
  path = 'foo',

  // By default, Stitch loads files using a simple key/value format. You
  // can use other formatters by passing in a `Stitch.framework.data.Formatter`.
  // In this case, we're using a YamlFormatter.
  //
  // This will also define the allowed file extensions your data can use, although
  // that is also overrideable in the collection config.
  formatter = new YamlFormatter(),

  // By default, Stitch will load each model from a single file that matches
  // the model's ID. You can change this by using a different Resource --
  // this one will store all the model's information in a folder that matches
  // its ID and a file (in this case) with the name '_data'.
  //
  // This might be useful if you need a model with a lot of children or other
  // assets.
  resource = new FolderResource('_data')

)
class Foo implements Model {
  
  // Maps to the `foo` key in the related document.
  @StringField public var foo:String;
  
  // A children field will load models from a sub-folder.
  // You can optionally set the sub-folder name here -- otherwise,
  // it will default to the relation's `collection.path`.
  @ChildrenField(
    relation = Post,
    folder = 'posts'
  ) public var children:Selection<Post>;

  // This field doesn't read anything directly from the document -- instead,
  // it looks at the document directly. This is handy if you want to know when
  // a model was created or modified, for example.
  @DocumentField( 
    handler = doc -> doc.modified 
  ) public var modified:Date;

  // ... and there are a number of other Fields you can use.

}
```

Store
-----

All models are accessed using the `stitch.Store` class. It works
like this:

```haxe
// Create a connection pointing to the root folder for your data
var connection = new stitch.connection.FileConnection('/my/content/');

// Create a store for that connection.
var store = new Store(connection);

// Loading models is quite simple: we get a `stitch.Selection` for a given
// model, and then can filter the results as needed:
var foos = store.get(example.Foo);

// Find one:
var foo:example.Foo = foos.find('bar');
trace(foo.foo);

// List all:
var all:Array<example.Foo> = foos.all();
trace(all.length);

// get the first:
var first:example.Foo = foos.first();

// ... and so forth
```
