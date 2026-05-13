import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final DateTime date;
  final String ownerId;
  final List<String> favoriteUserIds;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.date,
    required this.ownerId,
    required this.favoriteUserIds,
  });

  factory EventModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? data['category'] ?? '',
      date: _readDate(data['date']),
      ownerId: data['ownerId'] ?? '',
      favoriteUserIds: List<String>.from(data['favoriteUserIds'] ?? []),
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'ownerId': ownerId,
      'favoriteUserIds': favoriteUserIds,
    };
  }

  bool isFavorite(String userId) {
    return favoriteUserIds.contains(userId);
  }
}