// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:smarthrm_flutter/utils/extensions/float32list_extension.dart';

enum FaceAspect { NORMAL, UP, DOWN, LEFT, RIGHT }

class NativeResponseData extends Equatable {
  final Float32List faceInfo;
  final Map<String, int> faceAspect;

  const NativeResponseData({
    required this.faceInfo,
    required this.faceAspect,
  });

  NativeResponseData copyWith({
    Float32List? faceInfo,
    Map<String, int>? faceAspect,
  }) {
    return NativeResponseData(
      faceInfo: faceInfo ?? this.faceInfo,
      faceAspect: faceAspect ?? this.faceAspect,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'faceInfo': faceInfo,
      'faceAspect': faceAspect,
    };
  }

  factory NativeResponseData.fromMap(Map<Object?, Object?> map) {
    return NativeResponseData(
      faceInfo: ((map['faceInfo'] ??
              Float32List.fromList(
                <double>[],
              )) as List<Object?>)
          .toFloat32List(),
      faceAspect: Map<String, double>.from(
        (map['faceAspect'] ??
            <String, int>{
              "${FaceAspect.UP}": 0,
              "${FaceAspect.DOWN}": 0,
              "${FaceAspect.LEFT}": 0,
              "${FaceAspect.RIGHT}": 0,
              "${FaceAspect.NORMAL}": 0,
            }) as Map<Object?, Object?>,
      ).toMapInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory NativeResponseData.fromJson(String source) =>
      NativeResponseData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        faceInfo,
        faceAspect,
      ];
}
