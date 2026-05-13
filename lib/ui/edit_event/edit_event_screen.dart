import 'package:evently_c18_dokki/core/constants/event_categories.dart';
import 'package:evently_c18_dokki/core/provider/app_config_provider.dart';
import 'package:evently_c18_dokki/data/firebase_event_service.dart';
import 'package:evently_c18_dokki/models/event_model.dart';
import 'package:evently_c18_dokki/ui/home/widgets/category_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditEventScreen extends StatefulWidget {
  static const String routeName = '/edit-event';

  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late EventModel event;
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late String selectedCategoryId;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  bool isInitialized = false;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (isInitialized) return;

    event = ModalRoute.of(context)!.settings.arguments as EventModel;

    titleController = TextEditingController(text: event.title);
    descriptionController = TextEditingController(text: event.description);

    selectedCategoryId = event.categoryId;
    selectedDate = event.date;
    selectedTime = TimeOfDay.fromDateTime(event.date);

    isInitialized = true;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (date == null) return;

    setState(() {
      selectedDate = date;
    });
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time == null) return;

    setState(() {
      selectedTime = time;
    });
  }

  DateTime get selectedEventDateTime {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> updateEvent() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final updatedEvent = EventModel(
        id: event.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        categoryId: selectedCategoryId,
        date: selectedEventDateTime,
        ownerId: event.ownerId,
        favoriteUserIds: event.favoriteUserIds,
      );

      await FirebaseEventService.updateEvent(updatedEvent);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String formatDate(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context, listen: false);
    return DateFormat(
      'MMM d, yyyy',
      provider.isEn ? 'en' : 'ar',
    ).format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context);
    final theme = Theme.of(context);
    final selectedCategory = EventCategories.byId(selectedCategoryId);
    final imagePath = selectedCategory.imagePath(provider.isDark);

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
                title: provider.isEn ? 'Edit event' : 'تعديل الفعالية',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryImage(
                          imagePath: imagePath,
                          title: selectedCategory.name(provider.isEn),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: EventCategories.addEventCategories.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final category =
                              EventCategories.addEventCategories[index];

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
                        const SizedBox(height: 18),
                        _FieldLabel(text: provider.isEn ? 'Title' : 'العنوان'),
                        const SizedBox(height: 8),
                        _EventTextField(
                          controller: titleController,
                          hintText:
                          provider.isEn ? 'Event Title' : 'عنوان الفعالية',
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return provider.isEn
                                  ? 'Please enter event title'
                                  : 'من فضلك أدخل عنوان الفعالية';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(
                          text: provider.isEn ? 'Description' : 'الوصف',
                        ),
                        const SizedBox(height: 8),
                        _EventTextField(
                          controller: descriptionController,
                          hintText: provider.isEn
                              ? 'Event Description...'
                              : 'وصف الفعالية...',
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return provider.isEn
                                  ? 'Please enter event description'
                                  : 'من فضلك أدخل وصف الفعالية';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _PickerRow(
                          icon: Icons.calendar_month_outlined,
                          title: provider.isEn ? 'Event Date' : 'تاريخ الفعالية',
                          value: formatDate(context),
                          onTap: pickDate,
                        ),
                        const SizedBox(height: 14),
                        _PickerRow(
                          icon: Icons.access_time_rounded,
                          title: provider.isEn ? 'Event Time' : 'وقت الفعالية',
                          value: selectedTime.format(context),
                          onTap: pickTime,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: isLoading ? null : updateEvent,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  provider.isEn ? 'Update event' : 'تحديث الفعالية',
                  style: theme.textTheme.titleSmall!.copyWith(
                    color: Colors.white,
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

  const _Header({
    required this.title,
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
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(80),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: theme.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final String? imagePath;
  final String title;

  const _CategoryImage({
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppConfigProvider>(context);

    return Container(
      height: 190,
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _EventTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final String? Function(String?) validator;

  const _EventTextField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppConfigProvider>(context);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: provider.isDark ? Colors.transparent : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: provider.isDark
                ? theme.colorScheme.primary
                : const Color(0xffE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PickerRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(value),
        ),
      ],
    );
  }
}