import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently_c18_dokki/core/constants/event_categories.dart';
import 'package:evently_c18_dokki/models/event_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseEventService {
  FirebaseEventService._();

  static final CollectionReference<Map<String, dynamic>> _eventsCollection =
  FirebaseFirestore.instance.collection('events');

  static String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  static Future<void> createEvent(EventModel event) async {
    final data = event.toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();

    await _eventsCollection.add(data);
  }

  static Stream<EventModel?> getEventById(String eventId) {
    return _eventsCollection.doc(eventId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return EventModel.fromFirestore(doc);
    });
  }

  static Future<void> updateEvent(EventModel event) async {
    final data = event.toFirestore();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _eventsCollection.doc(event.id).update(data);
  }

  static Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }

  static Stream<List<EventModel>> getEvents({
    String selectedCategoryId = EventCategories.allId,
  }) {
    Query<Map<String, dynamic>> query = _eventsCollection;

    if (selectedCategoryId != EventCategories.allId) {
      query = query.where('categoryId', isEqualTo: selectedCategoryId);
    }

    return query.snapshots().map((snapshot) {
      final events =
      snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();

      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  static Stream<List<EventModel>> getFavoriteEvents() {
    final userId = currentUserId;

    if (userId == null) {
      return Stream.value([]);
    }

    return _eventsCollection
        .where('favoriteUserIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final events =
      snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();

      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  static Future<void> toggleFavorite(EventModel event) async {
    final userId = currentUserId;

    if (userId == null) return;

    final isFavorite = event.favoriteUserIds.contains(userId);

    await _eventsCollection.doc(event.id).update({
      'favoriteUserIds': isFavorite
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
    });
  }
}