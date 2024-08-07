import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/src/image/color_space_type.dart';
import 'package:tflite_flutter_helper/src/tensorbuffer/tensorbuffer.dart';

/// Implements some stateless image conversion methods.
///
/// This class is an internal helper.
class ImageConversions {
  static img.Image convertRgbTensorBufferToImage(TensorBuffer buffer) {
    List<int> shape = buffer.getShape();
    ColorSpaceType rgb = ColorSpaceType.RGB;
    rgb.assertShape(shape);

    int h = rgb.getHeight(shape);
    int w = rgb.getWidth(shape);
    img.Image image = img.Image(width: w, height: h);

    List<int> rgbValues = buffer.getIntList();
    assert(rgbValues.length == w * h * 3);

    for (int i = 0, j = 0, wi = 0, hi = 0; j < rgbValues.length; i++) {
      int r = rgbValues[j++];
      int g = rgbValues[j++];
      int b = rgbValues[j++];
      image.setPixel(wi, hi, img.ColorInt8.rgb(r, g, b));
      wi++;
      if (wi % w == 0) {
        wi = 0;
        hi++;
      }
    }

    return image;
  }

  static img.Image convertGrayscaleTensorBufferToImage(TensorBuffer buffer) {
    // Convert buffer into Uint8 as needed.
    TensorBuffer uint8Buffer = buffer.getDataType() == TensorType.uint8
        ? buffer
        : TensorBuffer.createFrom(buffer, TensorType.uint8);

    final shape = uint8Buffer.getShape();
    final grayscale = ColorSpaceType.GRAYSCALE;
    grayscale.assertShape(shape);

    final image = img.Image.fromBytes(
      width: grayscale.getWidth(shape),
      height: grayscale.getHeight(shape), bytes: uint8Buffer.getBuffer(),
      // format: img.Format.l8
    );

    return image;
  }

  static void convertImageToTensorBufferOld(
      img.Image image, TensorBuffer buffer) {
    int w = image.width;
    int h = image.height;
    List<int> intValues = image.getBytes(order: img.ChannelOrder.rgb);
    int flatSize = w * h * 3;
    List<int> shape = [h, w, 3];

    switch (buffer.getDataType()) {
      case TensorType.uint8:
        List<int> byteArr = List.filled(flatSize, 0);
        for (int i = 0, j = 0; i < intValues.length; i += 3) {
          byteArr[j++] = intValues[i];
          byteArr[j++] = intValues[i + 1];
          byteArr[j++] = intValues[i + 2];
        }
        buffer.loadList(byteArr, shape: shape);
        break;
      case TensorType.float32:
        List<double> floatArr = List.filled(flatSize, 0.0);
        for (int i = 0, j = 0; i < intValues.length; i += 3) {
          floatArr[j++] = intValues[i].toDouble();
          floatArr[j++] = intValues[i + 1].toDouble();
          floatArr[j++] = intValues[i + 2].toDouble();
        }
        buffer.loadList(floatArr, shape: shape);
        break;
      default:
        throw StateError(
            "${buffer.getDataType()} is unsupported with TensorBuffer.");
    }
  }

  static void convertImageToTensorBuffer(img.Image image, TensorBuffer buffer) {
    int w = image.width;
    int h = image.height;
    List<int> intValues = image.getBytes(order: img.ChannelOrder.rgb);
    int flatSize = w * h * 3;
    List<int> shape = [h, w, 3];

    print("Image dimensions: width = $w, height = $h");
    print("Expected flat size: $flatSize");
    print("intValues length: ${intValues.length}");

    switch (buffer.getDataType()) {
      case TensorType.uint8:
        List<int> byteArr = List.filled(flatSize, 0);
        for (int i = 0, j = 0; i < intValues.length; i += 3) {
          if (j >= flatSize) {
            print("Index out of bounds: j = $j, flatSize = $flatSize");
            break;
          }
          byteArr[j++] = intValues[i];
          byteArr[j++] = intValues[i + 1];
          byteArr[j++] = intValues[i + 2];
        }
        buffer.loadList(byteArr, shape: shape);
        break;
      case TensorType.float32:
        List<double> floatArr = List.filled(flatSize, 0.0);
        for (int i = 0, j = 0; i < intValues.length; i += 3) {
          if (j >= flatSize) {
            print("Index out of bounds: j = $j, flatSize = $flatSize");
            break;
          }
          floatArr[j++] = intValues[i].toDouble();
          floatArr[j++] = intValues[i + 1].toDouble();
          floatArr[j++] = intValues[i + 2].toDouble();
        }
        buffer.loadList(floatArr, shape: shape);
        break;
      default:
        throw StateError(
            "${buffer.getDataType()} is unsupported with TensorBuffer.");
    }
  }
}
