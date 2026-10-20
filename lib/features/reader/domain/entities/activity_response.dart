import 'package:flutter/foundation.dart';

/// Lo que el estudiante creó en una dinámica.
///
/// Privado por defecto: [isShared] existe para el futuro muro de creaciones,
/// pero nada sale de su dispositivo sin que lo decida.
@immutable
class ActivityResponse {
  const ActivityResponse({
    required this.activityId,
    required this.content,
    required this.createdAt,
    this.isShared = false,
  });

  final String activityId;
  final String content;
  final DateTime createdAt;
  final bool isShared;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityResponse &&
          other.activityId == activityId &&
          other.content == content &&
          other.createdAt == createdAt &&
          other.isShared == isShared;

  @override
  int get hashCode => Object.hash(activityId, content, createdAt, isShared);
}
