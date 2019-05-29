package stitch;

using Type;
using Reflect;

class ModelTools {

  public static function getModelCollection<T:Model>(model:T):Collection<T> {
    return model.getClass().getProperty('collection');
  }
  
  public static function getCollection<T:Model>(modelClass:Class<T>):Collection<T> {
    return modelClass.getProperty('collection');
  }

}