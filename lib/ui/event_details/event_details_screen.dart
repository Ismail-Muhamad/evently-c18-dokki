import 'package:evently_c18_dokki/core/constants/event_categories.dart';
import 'package:evently_c18_dokki/core/provider/app_config_provider.dart';
import 'package:evently_c18_dokki/data/firebase_event_service.dart';
import 'package:evently_c18_dokki/models/event_model.dart';
import 'package:evently_c18_dokki/ui/edit_event/edit_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventDetailsScreen extends StatelessWidget {
  static const String routeName = '/event-details';

  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventId = ModalRoute.of(context)!.settings.arguments as String;

    return StreamBuilder<EventModel?>(
      stream: FirebaseEventService.getEventById(eventId),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final provider = Provider.of<AppConfigProvider>(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: Center(
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

        final event = snapshot.data;

        if (event == null) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: Center(
              child: Text(
                provider.isEn ? 'Event not found' : 'الفعالية غير موجودة',
                style: theme.textTheme.titleMedium,
              ),
            ),
          );
        }

        return _EventDetailsBody(event: event);
      },
    );
  }
}

class _EventDetailsBody extends StatelessWidget {
  final EventModel event;

  const _EventDetailsBody({
    required this.event,
  });

  Future<void> deleteEvent(BuildContext context) async {
    final provider = Provider.of<AppConfigProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(provider.isEn ? 'Delete event' : 'حذف الفعالية'),
          content: Text(
            provider.isEn
                ? 'Are you sure you want to delete this event?'
                : 'هل أنت متأكد أنك تريد حذف هذه الفعالية؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(provider.isEn ? 'Cancel' : 'إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                provider.isEn ? 'Delete' : 'حذف',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseEventService.deleteEvent(event.id);

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  String formatDate(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context, listen: false);
    return DateFormat(
      'd MMMM',
      provider.isEn ? 'en' : 'ar',
    ).format(event.date);
  }

  String formatTime(BuildContext context) {
    final time = TimeOfDay.fromDateTime(event.date);
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context);
    final theme = Theme.of(context);
    final category = EventCategories.byId(event.categoryId);
    final imagePath = category.imagePath(provider.isDark);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 14,
            bottom: 16,
          ),
          child: Column(
            children: [
              _Header(
                title: provider.isEn ? 'Event details' : 'تفاصيل الفعالية',
                actions: [
                  _HeaderIconButton(
                    icon: Icons.edit_outlined,
                    color: theme.colorScheme.primary,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        EditEventScreen.routeName,
                        arguments: event,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.red,
                    onTap: () => deleteEvent(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EventImage(
                        imagePath: imagePath,
                        title: category.name(provider.isEn),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _DateTimeCard(
                        date: formatDate(context),
                        time: formatTime(context),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        provider.isEn ? 'Description' : 'الوصف',
                        style: theme.textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DescriptionCard(description: event.description),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const _Header({
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _HeaderIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.primary,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Text(
            title,
            style: theme.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppConfigProvider>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: provider.isDark ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: provider.isDark
                ? theme.colorScheme.primary.withAlpha(100)
                : const Color(0xffE5E7EB),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}

class _EventImage extends StatelessWidget {
  final String? imagePath;
  final String title;

  const _EventImage({
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppConfigProvider>(context);

    return Container(
      height: 210,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: provider.isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: provider.isDark
              ? theme.colorScheme.primary
              : const Color(0xffE5E7EB),
        ),
      ),
      child: imagePath == null
          ? Center(
        child: Text(
          title,
          style: theme.textTheme.headlineMedium!.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : Image.asset(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              title,
              style: theme.textTheme.headlineMedium!.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  final String date;
  final String time;

  const _DateTimeCard({
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppConfigProvider>(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: provider.isDark
              ? theme.colorScheme.primary
              : const Color(0xffE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: provider.isDark
                  ? theme.colorScheme.primary.withAlpha(20)
                  : const Color(0xffF2F4FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: provider.isDark
                    ? theme.colorScheme.primary
                    : const Color(0xffE5E7EB),
              ),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppConfigProvider>(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: provider.isDark
              ? theme.colorScheme.primary
              : const Color(0xffE5E7EB),
        ),
      ),
      child: Text(
        description,
        style: theme.textTheme.bodyLarge!.copyWith(
          height: 1.45,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}