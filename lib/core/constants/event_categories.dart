import 'package:flutter/material.dart';

class EventCategory {
  final String id;
  final String enName;
  final String arName;
  final IconData icon;
  final String? lightImage;
  final String? darkImage;

  const EventCategory({
    required this.id,
    required this.enName,
    required this.arName,
    required this.icon,
    this.lightImage,
    this.darkImage,
  });

  String name(bool isEn) => isEn ? enName : arName;

  String? imagePath(bool isDark) {
    if (lightImage == null || darkImage == null) return null;
    return isDark ? darkImage : lightImage;
  }
}

class EventCategories {
  static const String allId = 'all';

  static const EventCategory all = EventCategory(
    id: allId,
    enName: 'All',
    arName: 'الكل',
    icon: Icons.grid_view_rounded,
  );

  static const EventCategory sport = EventCategory(
    id: 'sport',
    enName: 'Sport',
    arName: 'رياضة',
    icon: Icons.directions_bike_rounded,
    lightImage: 'assets/images/event_category/sport_light.png',
    darkImage: 'assets/images/event_category/sport_dark.png',
  );

  static const EventCategory birthday = EventCategory(
    id: 'birthday',
    enName: 'Birthday',
    arName: 'عيد ميلاد',
    icon: Icons.cake_outlined,
    lightImage: 'assets/images/event_category/birthday_light.png',
    darkImage: 'assets/images/event_category/birthday_dark.png',
  );

  static const EventCategory meeting = EventCategory(
    id: 'meeting',
    enName: 'Meeting',
    arName: 'اجتماع',
    icon: Icons.groups_2_outlined,
    lightImage: 'assets/images/event_category/meeting_light.png',
    darkImage: 'assets/images/event_category/meeting_dark.png',
  );

  static const EventCategory exhibition = EventCategory(
    id: 'exhibition',
    enName: 'Exhibition',
    arName: 'معرض',
    icon: Icons.museum_outlined,
    lightImage: 'assets/images/event_category/exhibition_light.png',
    darkImage: 'assets/images/event_category/exhibition_dark.png',
  );

  static const EventCategory bookClub = EventCategory(
    id: 'book_club',
    enName: 'Book club',
    arName: 'نادي الكتاب',
    icon: Icons.menu_book_outlined,
    lightImage: 'assets/images/event_category/book_club_light.png',
    darkImage: 'assets/images/event_category/book_club_dark.png',
  );

  static const List<EventCategory> filterCategories = [
    all,
    sport,
    birthday,
    meeting,
    exhibition,
    bookClub,
  ];

  static const List<EventCategory> addEventCategories = [
    bookClub,
    sport,
    birthday,
    meeting,
    exhibition,
  ];

  static EventCategory byId(String id) {
    return filterCategories.firstWhere(
          (category) => category.id == id,
      orElse: () => all,
    );
  }
}