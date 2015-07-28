
library interpolate.transformer;

import 'package:barback/barback.dart';
import 'package:analyzer/analyzer.dart';


class InterpolateTransformer extends Transformer {

  InterpolateTransformer.asPlugin();

  String get allowedExtensions => ".dart";

  Future apply(Transform transform) async {
    var content = await transform.primaryInput.readAsString();
    var id = transform.primaryInput.id;
    // locate interpolations, generate accessors, and splice code
    var newContent = copyright + content;
    transform.addOutput(new Asset.fromString(id, newContent));
  }
}