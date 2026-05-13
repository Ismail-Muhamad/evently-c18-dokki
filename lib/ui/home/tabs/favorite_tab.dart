import 'package:evently_c18_dokki/core/provider/app_config_provider.dart';
import 'package:evently_c18_dokki/data/firebase_event_service.dart';
import 'package:evently_c18_dokki/models/event_model.dart';
import 'package:evently_c18_dokki/ui/home/widgets/event_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<EventModel> filterEvents(List<EventModel> events) {
    final query = searchText.trim().toLowerCase();

    if (query.isEmpty) return events;

    return events.where((event) {
      return event.title.toLowerCase().contains(query) ||
          event.description.toLowerCase().contains(query) ||
          event.categoryId.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context);
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          top: 18,
        ),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: provider.isEn ? 'Search for event' : 'ابحث عن فعالية',
                suffixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: uid == null
                  ? _EmptyFavoriteView(
                title: provider.isEn
                    ? 'Please login first'
                    : 'سجل الدخول أولاً',
                subtitle: provider.isEn
                    ? 'Favorite events will appear here.'
                    : 'الفعاليات المفضلة ستظهر هنا.',
              )
                  : StreamBuilder<List<EventModel>>(
                stream: FirebaseEventService.getFavoriteEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          snapshot.error.toString(),
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final events = filterEvents(snapshot.data ?? []);

                  if (events.isEmpty) {
                    return _EmptyFavoriteView(
                      title: provider.isEn
                          ? 'No favorite events yet'
                          : 'لا توجد فعاليات مفضلة',
                      subtitle: provider.isEn
                          ? 'Tap the heart icon on any event.'
                          : 'اضغط على علامة القلب في أي فعالية.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: events.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return EventCard(event: events[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavoriteView extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyFavoriteView({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}