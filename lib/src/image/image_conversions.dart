import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/src/image/color_space_type.dart';
import 'package:tflite_flutter_helper/src/tensorbuffer/tensorbuffer.dart';

/// Implements some stateless image conversion methods.
///
/// This class is an internal helper.
class ImageConversions {
  // static Image convertRgbTensorBufferToImageOld(TensorBuffer buffer) {
  //   List<int> shape = buffer.getShape();
  //   ColorSpaceType rgb = ColorSpaceType.RGB;
  //   rgb.assertShape(shape);
  //
  //   int h = rgb.getHeight(shape);
  //   int w = rgb.getWidth(shape);
  //   Image image = Image(height: h, width: w);
  //
  //   List<int> rgbValues = buffer.getIntList();
  //   assert(rgbValues.length == w * h * 3);
  //
  //   for (int i = 0, j = 0, wi = 0, hi = 0; j < rgbValues.length; i++) {
  //     int r = rgbValues[j++];
  //     int g = rgbValues[j++];
  //     int b = rgbValues[j++];
  //     image.setPixelRgba(wi, hi, r, g, b);
  //     wi++;
  //     if (wi % w == 0) {
  //       wi = 0;
  //       hi++;
  //     }
  //   }
  //
  //   return image;
  // }

  static Image convertRgbTensorBufferToImage(TensorBuffer buffer) {
    List<int> shape = buffer.getShape();
    ColorSpaceType rgb = ColorSpaceType.RGB;
    rgb.assertShape(shape);

    int h = rgb.getHeight(shape);
    int w = rgb.getWidth(shape);
    Image image = Image(height: h, width: w);

    List<int> rgbValues = buffer.getIntList();
    assert(rgbValues.length == w * h * 3);

    for (int i = 0, j = 0, wi = 0, hi = 0; j < rgbValues.length; i++) {
      int r = rgbValues[j++];
      int g = rgbValues[j++];
      int b = rgbValues[j++];
      int a = 255; // Assuming full opacity if alpha is not provided
      image.setPixelRgba(wi, hi, r, g, b, a);
      wi++;
      if (wi % w == 0) {
        wi = 0;
        hi++;
      }
    }

    return image;
  }

  static Image convertGrayscaleTensorBufferToImage(TensorBuffer buffer) {
    // Convert buffer into Uint8 as needed.
    TensorBuffer uint8Buffer = buffer.getDataType() == TfLiteType.uint8
        ? buffer
        : TensorBuffer.createFrom(buffer, TfLiteType.uint8);

    final shape = uint8Buffer.getShape();
    final grayscale = ColorSpaceType.GRAYSCALE;
    grayscale.assertShape(shape);

    final image = Image.fromBytes(
      width: grayscale.getWidth(shape),
      height: grayscale.getHeight(shape),
      bytes: uint8Buffer.getBuffer(),
    );

    return image;
  }

  // static void convertImageToTensorBufferOld(Image image, TensorBuffer buffer) {
  //   int w = image.width;
  //   int h = image.height;
  //   List<int> intValues = image.data;
  //   int flatSize = w * h * 3;
  //   List<int> shape = [h, w, 3];
  //   switch (buffer.getDataType()) {
  //     case TfLiteType.uint8:
  //       List<int> byteArr = List.filled(flatSize, 0);
  //       for (int i = 0, j = 0; i < intValues.length; i++) {
  //         byteArr[j++] = ((intValues[i]) & 0xFF);
  //         byteArr[j++] = ((intValues[i] >> 8) & 0xFF);
  //         byteArr[j++] = ((intValues[i] >> 16) & 0xFF);
  //       }
  //       buffer.loadList(byteArr, shape: shape);
  //       break;
  //     case TfLiteType.float32:
  //       List<double> floatArr = List.filled(flatSize, 0.0);
  //       for (int i = 0, j = 0; i < intValues.length; i++) {
  //         floatArr[j++] = ((intValues[i]) & 0xFF).toDouble();
  //         floatArr[j++] = ((intValues[i] >> 8) & 0xFF).toDouble();
  //         floatArr[j++] = ((intValues[i] >> 16) & 0xFF).toDouble();
  //       }
  //       buffer.loadList(floatArr, shape: shape);
  //       break;
  //     default:
  //       throw StateError(
  //           "${buffer.getDataType()} is unsupported with TensorBuffer.");
  //   }
  // }

  static void convertImageToTensorBuffer1(Image image, TensorBuffer buffer) {
    int w = image.width;
    int h = image.height;

    // Ensure image.data is of type List<int>
    // Assuming image.data is of type ImageData? and you need to convert it to List<int>
    List<int> intValues;
    if (image.data is Uint8List) {
      intValues = (image.data as Uint8List).toList();
    } else {
      throw StateError("image.data is not of type Uint8List");
    }
    int flatSize = w * h * 3;
    List<int> shape = [h, w, 3];
    switch (buffer.getDataType()) {
      case TfLiteType.uint8:
        List<int> byteArr = List.filled(flatSize, 0);
        for (int i = 0, j = 0; i < intValues.length; i++) {
          byteArr[j++] = ((intValues[i]) & 0xFF);
          byteArr[j++] = ((intValues[i] >> 8) & 0xFF);
          byteArr[j++] = ((intValues[i] >> 16) & 0xFF);
        }
        buffer.loadList(byteArr, shape: shape);
        break;
      case TfLiteType.float32:
        List<double> floatArr = List.filled(flatSize, 0.0);
        for (int i = 0, j = 0; i < intValues.length; i++) {
          floatArr[j++] = ((intValues[i]) & 0xFF).toDouble();
          floatArr[j++] = ((intValues[i] >> 8) & 0xFF).toDouble();
          floatArr[j++] = ((intValues[i] >> 16) & 0xFF).toDouble();
        }
        buffer.loadList(floatArr, shape: shape);
        break;
      default:
        throw StateError(
            "${buffer.getDataType()} is unsupported with TensorBuffer.");
    }
  }

  static void convertImageToTensorBuffer(Image image, TensorBuffer buffer) {
    // Ensure image.data is not null and is of type Uint8List
    if (image.data == null) {
      throw StateError("image.data is null");
    }

    List<int> intValues;
    if (image.data is Uint8List) {
      intValues = (image.data as Uint8List).toList();
    } else if (image.data is List<int>) {
      intValues = image.data as List<int>;
    } else {
      throw StateError("image.data is not of type Uint8List or List<int>");
    }

    int w = image.width;
    int h = image.height;
    int flatSize = w * h * 3;
    List<int> shape = [h, w, 3];

    switch (buffer.getDataType()) {
      case TfLiteType.uint8:
        List<int> byteArr = List.filled(flatSize, 0);
        for (int i = 0, j = 0; i < intValues.length; i++) {
          byteArr[j++] = ((intValues[i]) & 0xFF);
          byteArr[j++] = ((intValues[i] >> 8) & 0xFF);
          byteArr[j++] = ((intValues[i] >> 16) & 0xFF);
        }
        buffer.loadList(byteArr, shape: shape);
        break;
      case TfLiteType.float32:
        List<double> floatArr = List.filled(flatSize, 0.0);
        for (int i = 0, j = 0; i < intValues.length; i++) {
          floatArr[j++] = ((intValues[i]) & 0xFF).toDouble();
          floatArr[j++] = ((intValues[i] >> 8) & 0xFF).toDouble();
          floatArr[j++] = ((intValues[i] >> 16) & 0xFF).toDouble();
        }
        buffer.loadList(floatArr, shape: shape);
        break;
      default:
        throw StateError(
            "${buffer.getDataType()} is unsupported with TensorBuffer.");
    }
  }

}
