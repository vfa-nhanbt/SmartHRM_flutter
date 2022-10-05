// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:smarthrm_flutter/screens/home/models/native_response_data.dart';

class NativeResponse extends Equatable {
  final bool isSucceed;
  final String message;
  final String? errorMessage;
  final NativeResponseData data;
  const NativeResponse({
    required this.isSucceed,
    required this.message,
    this.errorMessage,
    required this.data,
  });

  NativeResponse copyWith({
    bool? isSucceed,
    String? message,
    String? errorMessage,
    NativeResponseData? data,
  }) {
    return NativeResponse(
      isSucceed: isSucceed ?? this.isSucceed,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isSucceed': isSucceed,
      'message': message,
      'errorMessage': errorMessage,
      'data': data.toMap(),
    };
  }

  factory NativeResponse.fromMap(Map<String?, Object?> map) {
    return NativeResponse(
      isSucceed: (map['isSucceed'] ?? false) as bool,
      message: (map['message'] ?? '') as String,
      errorMessage:
          map['errorMessage'] != null ? map['errorMessage'] as String : null,
      data: NativeResponseData.fromMap(map['data'] as Map<Object?, Object?>),
    );
  }

  String toJson() => json.encode(toMap());

  factory NativeResponse.fromJson(String source) =>
      NativeResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        isSucceed,
        message,
        errorMessage ?? "",
        data,
      ];
}
