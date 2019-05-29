package stitch.error;

import haxe.PosInfos;
import stitch.Collection;
import stitch.core.Error;

class CannotSaveError extends Error {

  public function new(collection:Collection<Dynamic>, ?pos:PosInfos) {
    var msg = 'Cannot save a model without an id to the collection "${collection.path}" collection';
    super(InternalError, msg, pos);
  }

}
