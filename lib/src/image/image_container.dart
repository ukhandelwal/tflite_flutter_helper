import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/src/image/base_image_container.dart';
import 'package:tflite_flutter_helper/src/image/image_conversions.dart';
import 'package:tflite_flutter_helper/src/tensorbuffer/tensorbuffer.dart';
import 'package:tflite_flutter_helper/src/image/color_space_type.dart';

class ImageContainer extends BaseImageContainer {
  late final Image _image;

  ImageContainer._(Image image) {
    this._image = image;
  }

  static ImageContainer create(Image image) {
    return ImageContainer._(image);
  }

  @override
  BaseImageContainer clone() {
    return create(_image.clone());
  }

  // @override
  // ColorSpaceType get colorSpaceType {
  //   int len = _image.data!.length;
  //   bool isGrayscale = true;
  //   for (int i = (len / 4).floor(); i < _image.data!.length; i++) {
  //     if (_image.data![i] != 0) {
  //       isGrayscale = false;
  //       break;
  //     }
  //   }
  //   if (isGrayscale) {
  //     return ColorSpaceType.GRAYSCALE;
  //   } else {
  //     return ColorSpaceType.RGB;
  //   }
  // }

  @override
  ColorSpaceType get colorSpaceType {
    // Ensure _image.data is not null
    if (_image.data == null) {
      throw StateError("_image.data is null");
    }

    // Assuming _image.data is Uint8List and converting to List<int>
    List<int> intValues;
    if (_image.data is Uint8List) {
      intValues = (_image.data as Uint8List).toList();
    } else {
      throw StateError("_image.data is not of type Uint8List");
    }

    int len = intValues.length;
    bool isGrayscale = true;

    for (int i = (len / 4).floor(); i < intValues.length; i++) {
      if (intValues[i] != 0) {
        isGrayscale = false;
        break;
      }
    }

    if (isGrayscale) {
      return ColorSpaceType.GRAYSCALE;
    } else {
      return ColorSpaceType.RGB;
    }
  }


  @override
  TensorBuffer getTensorBuffer(TensorType dataType) {
    TensorBuffer buffer = TensorBuffer.createDynamic(dataType);
    ImageConversions.convertImageToTensorBuffer(image, buffer);
    return buffer;
  }

  @override
  int get height => _image.height;

  @override
  Image get image => _image;

  @override
  CameraImage get mediaImage => throw UnsupportedError(
      'Converting from Image to CameraImage is unsupported');

  @override
  int get width => _image.width;
}
