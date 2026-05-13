import 'package:evently_c18_dokki/core/provider/app_config_provider.dart';
import 'package:evently_c18_dokki/core/utils/shared_prefernces_keys.dart';
import 'package:evently_c18_dokki/ui/login/login_screen.dart';
import 'package:evently_c18_dokki/ui/onboarding/onboarding_model.dart';
import 'package:evently_c18_dokki/ui/onboarding/widgets/onboarding_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int currentIndex = 0;

  bool get isLastPage => currentIndex == onboardingItems.length - 1;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> finishOnboarding() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(SharedPreferencesKeys.hasSeenOnboarding.name, true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  void nextPage() {
    if (isLastPage) {
      finishOnboarding();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    if (currentIndex == 0) return;

    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, provider),
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: onboardingItems.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = onboardingItems[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: Image.asset(
                              item.imagePath(provider.isDark),
                              width: size.width * 0.78,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_outlined,
                                  size: size.width * 0.45,
                                  color: theme.colorScheme.primary,
                                );
                              },
                            ),
                          ),
                        ),
                        OnboardingIndicator(
                          currentIndex: currentIndex,
                          itemCount: onboardingItems.length,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          item.title(provider.isEn),
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description(provider.isEn),
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.colorScheme.secondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: nextPage,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(isLastPage ? 'Get started' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppConfigProvider provider) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: currentIndex == 0
                ? const SizedBox(width: 40, height: 40)
                : _buildIconButton(
                    context: context,
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: previousPage,
                  ),
          ),
          Image.asset(
            'assets/images/logo_${provider.assetSuffix}.png',
            width: MediaQuery.sizeOf(context).width * 0.36,
          ),
          if (!isLastPage)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: finishOnboarding,
                style: TextButton.styleFrom(
                  backgroundColor: provider.isDark
                      ? theme.colorScheme.primary.withAlpha(20)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: provider.isDark
                          ? theme.colorScheme.primary.withAlpha(90)
                          : theme.colorScheme.primary.withAlpha(18),
                    ),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppConfigProvider>(context, listen: false);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: provider.isDark
              ? theme.colorScheme.primary.withAlpha(20)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: provider.isDark
                ? theme.colorScheme.primary.withAlpha(90)
                : theme.colorScheme.primary.withAlpha(18),
          ),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 18,
        ),
      ),
    );
  }
}
