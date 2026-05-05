import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/features/alerts/domain/entities/app_alert.dart';

class AlertModel {
  const AlertModel({
    required this.id,
    required this.type,
    required this.message,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String message;
  final String? relatedEntityId;
  final bool isRead;
  final DateTime createdAt;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      relatedEntityId: json['relatedEntityId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'message': message,
        'relatedEntityId': relatedEntityId,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory AlertModel.fromDomain(AppAlert a) => AlertModel(
        id: a.id,
        type: a.type.name,
        message: a.message,
        relatedEntityId: a.relatedEntityId,
        isRead: a.isRead,
        createdAt: a.createdAt,
      );

  AppAlert toDomain() => AppAlert(
        id: id,
        type: AlertType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => AlertType.recurringReminder,
        ),
        message: message,
        relatedEntityId: relatedEntityId,
        isRead: isRead,
        createdAt: createdAt,
      );
}
