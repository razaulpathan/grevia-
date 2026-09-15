import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading:
                const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
            title: const Text('Phone Number'),
            subtitle: Text(profile?.phoneNumber.isNotEmpty == true
                ? profile!.phoneNumber
                : 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Phone number cannot be changed directly.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.alternate_email,
                color: AppColors.primaryGreen),
            title: const Text('Username'),
            subtitle: Text('@${profile?.username ?? "username"}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.usernameSetup),
          ),
          ListTile(
            leading:
                const Icon(Icons.person_outline, color: AppColors.primaryGreen),
            title: const Text('Edit Profile & Bio'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined,
                color: AppColors.errorRed),
            title: const Text('Delete My Account',
                style: TextStyle(color: AppColors.errorRed)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.deleteAccount),
          ),
        ],
      ),
    );
  }
}
