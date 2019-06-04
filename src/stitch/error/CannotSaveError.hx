package stitch.error;

import stitch.Collection;
import stitch.core.Error;

class CannotSaveError extends Error {

  public function new(collection:Collection<Dynamic>, ?pos) {
    var msg = 'Cannot save a model without an id to the collection "${collection.path}" collection';
    super(InternalError, msg, pos);
  }

}
