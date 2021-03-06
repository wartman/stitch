package stitch.error;

import stitch.Collection;
import stitch.core.Error;

class NotFoundError extends Error {

  public function new(collection:Collection<Dynamic>, id:String, ?pos) {
    var msg = 'No model with the id "${id}" was found in the "${collection.path}" collection';
    super(NotFound, msg, pos);
  }

}
