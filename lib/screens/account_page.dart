import 'package:flutter/material.dart';

import '../services/wallet_controller.dart';
import '../theme/app_theme.dart';

class AccountPage extends StatefulWidget {
  final WalletController wallet;

  const AccountPage({super.key, required this.wallet});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.wallet.accountName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 28),
        const CircleAvatar(
          radius: 47,
          backgroundColor: AppColors.accent,
          child: Icon(Icons.person_rounded, size: 55),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'حسابي',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'اسم صاحب الحساب',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            filled: true,
            fillColor: Colors.white.withOpacity(.09),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 55,
          child: FilledButton(
            onPressed: () async {
              final value = nameController.text.trim();
              widget.wallet.accountName =
                  value.isEmpty ? 'محمد علي العباس' : value;
              await widget.wallet.saveAccountName();

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ بيانات الحساب')),
              );
            },
            child: const Text(
              'حفظ التغييرات',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'بيانات النسخة التجريبية',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'الأرصدة والحوالات في هذه المرحلة تجريبية ومحلية فقط.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 15),
        OutlinedButton.icon(
          onPressed: () {
            widget.wallet.resetDemoBalances();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت إعادة الأرصدة التجريبية')),
            );
          },
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('إعادة الأرصدة الافتراضية'),
        ),
      ],
    );
  }
}
