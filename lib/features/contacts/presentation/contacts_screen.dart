import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/avatar_view.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mockContacts = [
      {
        'name': 'Alice Walker',
        'username': 'alice',
        'phone': '+1 555-0101',
        'isOnline': true
      },
      {
        'name': 'Bob Anderson',
        'username': 'bob_a',
        'phone': '+1 555-0102',
        'isOnline': false
      },
      {
        'name': 'Charlie Smith',
        'username': 'charlie_s',
        'phone': '+1 555-0103',
        'isOnline': true
      },
      {
        'name': 'Diana Prince',
        'username': 'diana_p',
        'phone': '+1 555-0104',
        'isOnline': false
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.globalSearch),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => context.push(AppRoutes.qrProfile),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSecondarySurface
                    : AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_outlined,
                  color: AppColors.primaryGreen),
            ),
            title: const Text('Invite Friends to Grevia',
                style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Invite link copied: grevia.app/join')),
              );
            },
          ),
          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Contacts on Grevia',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
              ),
            ),
          ),
          ...mockContacts.map((contact) {
            return ListTile(
              leading: AvatarView(
                name: contact['name'] as String,
                size: 44,
                isOnline: contact['isOnline'] as bool,
                showOnlineIndicator: true,
              ),
              title: Text(contact['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('@${contact['username']}'),
              onTap: () {
                context.push(
                  '/user/${contact['username']}',
                  extra: contact,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
