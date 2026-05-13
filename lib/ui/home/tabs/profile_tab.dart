import 'package:evently_c18_dokki/core/provider/app_config_provider.dart';
import 'package:evently_c18_dokki/ui/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppConfigProvider>(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'Guest';
    final email = user?.email ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 76),
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'ROUTE',
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              name,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 36),
            _ProfileTile(
              title: 'Dark mode',
              trailing: Switch(
                value: provider.isDark,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  provider.changeTheme(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            _ProfileTile(
              title: 'Language',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.isEn ? 'EN' : 'AR',
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ],
              ),
              onTap: () {
                provider.changeLocal(provider.isEn ? 'ar' : 'en');
              },
            ),
            const SizedBox(height: 14),
            _ProfileTile(
              title: 'Logout',
              trailing: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.routeName,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 12,
          top: 12,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.secondary.withAlpha(25),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelLarge,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
