package stitch.error;

import tink.core.Error;
import stitch.Model;

using Type;

class ModelNotFoundError extends Error {

  public function new(model:String, id:Dynamic, ?pos) {
    super(NotFound, 'Model ${model} does not have an item with the id ${id}', pos);
  }

}