import 'dart:ffi';

import 'package:ffi/ffi.dart';

sealed class TfLiteNLClassifier extends Opaque {}

sealed class TfLiteNLClassifierOptions extends Struct {
  @Int32()
  external int inputTensorIndex;

  @Int32()
  external int outputScoreTensorIndex;

  @Int32()
  external int outputLabelTensorIndex;

  external Pointer<Utf8> inputTensorName;

  external Pointer<Utf8> outputScoreTensorName;

  external Pointer<Utf8> outputLabelTensorName;

  static Pointer<TfLiteNLClassifierOptions> allocate(
    int inputTensorIndex,
    int outputScoreTensorIndex,
    int outputLabelTensorIndex,
    String inputTensorName,
    String outputScoreTensorName,
    String outputLabelTensorName,
  ) {
    final result = calloc<TfLiteNLClassifierOptions>();
    result.ref
      ..inputTensorIndex = inputTensorIndex
      ..outputScoreTensorIndex = outputScoreTensorIndex
      ..outputLabelTensorIndex = outputLabelTensorIndex
      ..inputTensorName = inputTensorName.toNativeUtf8()
      ..outputScoreTensorName = outputScoreTensorName.toNativeUtf8()
      ..outputLabelTensorName = outputLabelTensorName.toNativeUtf8();
    return result;
  }
}

sealed class TfLiteCategories extends Struct {
  @Int32()
  external int size;

  external Pointer<TfLiteCategory> categories;
}

sealed class TfLiteCategory extends Struct {
  external Pointer<Utf8> text;

  @Double()
  external double score;
}

sealed class TfLiteBertNLClassifier extends Opaque {}

sealed class TfLiteBertNLClassifierOptions extends Struct {
  @Int32()
  external int maxSeqLen;

  static Pointer<TfLiteBertNLClassifierOptions> allocate(
    int maxSeqLen,
  ) {
    final result = calloc<TfLiteBertNLClassifierOptions>();
    result.ref.maxSeqLen = maxSeqLen;
    return result;
  }
}
