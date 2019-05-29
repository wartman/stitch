package stitch.field.support;

import stitch.*;

@Collection( path = 'field' )
class FieldModel implements Model {

  public static function getModel() {
    return new FieldModel({ id: 'ok' });
  }

}
