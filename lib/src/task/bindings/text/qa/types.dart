import 'dart:ffi';

import 'package:ffi/ffi.dart';

sealed class TfLiteBertQuestionAnswerer extends Opaque {}

sealed class TfLiteQaAnswer extends Struct {
  @Int32()
  external int start;
  @Int32()
  external int end;
  @Double()
  external double logit;

  external Pointer<Utf8> text;
}

sealed class TfLiteQaAnswers extends Struct {
  @Int32()
  external int size;

  external Pointer<TfLiteQaAnswer> answers;
}
