import 'package:evently_c18_dokki/core/constants/event_categories.dart';
import 'package:evently_c18_dokki/core/provider/app_config_provider.dart';
import 'package:evently_c18_dokki/data/firebase_event_service.dart';
import 'package:evently_c18_dokki/models/event_model.dart';
import 'package:evently_c18_dokki/ui/event_details/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context);
    final theme = Theme.of(context);
    final category = EventCategories.byId(event.categoryId);
    final imagePath = category.imagePath(provider.isDark);
    final currentUserId = FirebaseEventService.currentUserId ?? '';
    final isFavorite = event.isFavorite(currentUserId);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          EventDetailsScreen.routeName,
          arguments: event.id,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: provider.isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: provider.isDark
                ? theme.colorScheme.primary
                : const Color(0xffE5E7EB),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imagePath == null
                          ? _ImageFallback(
                              categoryName: category.name(provider.isEn),
                            )
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _ImageFallback(
                                  categoryName: category.name(provider.isEn),
                                );
                              },
                            ),
                    ),
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: provider.isDark
                              ? theme.colorScheme.surface
                              : const Color(0xffF2F4FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: provider.isDark
                                ? theme.colorScheme.primary
                                : const Color(0xffE5E7EB),
                          ),
                        ),
                        child: Text(
                          DateFormat('d MMM').format(event.date),
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: provider.isDark
                      ? theme.colorScheme.surface
                      : const Color(0xffF2F4FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: provider.isDark
                        ? theme.colorScheme.primary
                        : const Color(0xffE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => FirebaseEventService.toggleFavorite(event),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final String categoryName;

  const _ImageFallback({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        categoryName,
        style: theme.textTheme.headlineMedium!.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
