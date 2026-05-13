import 'package:evently_c18_dokki/core/constants/event_categories.dart';
import 'package:evently_c18_dokki/core/provider/app_config_provider.dart';
import 'package:evently_c18_dokki/data/firebase_event_service.dart';
import 'package:evently_c18_dokki/models/event_model.dart';
import 'package:evently_c18_dokki/ui/home/widgets/category_item.dart';
import 'package:evently_c18_dokki/ui/home/widgets/event_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String selectedCategoryId = EventCategories.allId;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first ?? 'Guest';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          top: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.isEn ? 'Welcome Back ✨' : 'مرحباً بعودتك ✨',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayName,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    provider.changeTheme(
                      provider.isDark ? ThemeMode.light : ThemeMode.dark,
                    );
                  },
                  icon: Icon(
                    provider.isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                InkWell(
                  onTap: () {
                    provider.changeLocal(provider.isEn ? 'ar' : 'en');
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      provider.isEn ? 'EN' : 'AR',
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: EventCategories.filterCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = EventCategories.filterCategories[index];

                  return CategoryItem(
                    title: category.name(provider.isEn),
                    icon: category.icon,
                    isSelected: selectedCategoryId == category.id,
                    onTap: () {
                      setState(() {
                        selectedCategoryId = category.id;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: StreamBuilder<List<EventModel>>(
                stream: FirebaseEventService.getEvents(
                  selectedCategoryId: selectedCategoryId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _ErrorView(error: snapshot.error.toString());
                  }

                  final events = snapshot.data ?? [];

                  if (events.isEmpty) {
                    return _EmptyView(
                      title: provider.isEn ? 'No events yet' : 'لا توجد فعاليات',
                      subtitle: provider.isEn
                          ? 'Events added in Firebase will appear here.'
                          : 'الفعاليات المضافة في Firebase ستظهر هنا.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
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

class _EmptyView extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyView({
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
              Icons.event_busy_outlined,
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

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}