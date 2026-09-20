import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SamBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onQr;

  const SamBottomBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.onQr,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 80,
      color: const Color(0xDD203B7E),
      shape: const CircularNotchedRectangle(),
      notchMargin: 9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.home_rounded, 'الرئيسية', 0),
          _item(Icons.currency_exchange_rounded, 'التحويلات', 1),
          const SizedBox(width: 48),
          _item(Icons.account_balance_wallet_outlined, 'الخدمات', 2),
          _item(Icons.person_outline_rounded, 'حسابي', 3),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, int i) {
    final active = index == i;
    return InkWell(
      onTap: () => onChanged(i),
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 25,
              color: active ? AppColors.accent : Colors.white70,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: active ? AppColors.accent : Colors.white,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
