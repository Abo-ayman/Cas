import 'package:flutter/material.dart';

import '../models/transfer.dart';
import '../theme/app_theme.dart';

class TransferInput {
  final String name;
  final double amount;

  const TransferInput(this.name, this.amount);
}

class TransferDialog {
  static Future<TransferInput?> show(
    BuildContext context, {
    required bool incoming,
    required Currency currency,
  }) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => _DialogShell(
        title: incoming ? 'اسم المرسل' : 'اسم المستلم',
        child: TextField(
          controller: nameController,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'اكتب الاسم',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        actionText: 'التالي',
        onAction: () {
          final value = nameController.text.trim();
          if (value.isNotEmpty) Navigator.pop(context, value);
        },
      ),
    );

    if (name == null) {
      nameController.dispose();
      amountController.dispose();
      return null;
    }

    final amount = await showDialog<double>(
      context: context,
      builder: (context) => _DialogShell(
        title: 'المبلغ ${currency.code}',
        child: TextField(
          controller: amountController,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: currency == Currency.syp ? '0' : '0.00',
            prefixIcon: const Icon(Icons.payments_outlined),
            suffixText: currency.symbol,
          ),
        ),
        actionText: incoming ? 'استلام' : 'إرسال',
        onAction: () {
          final value = double.tryParse(
            amountController.text.trim().replaceAll(',', '.'),
          );
          if (value != null && value > 0) {
            Navigator.pop(context, value);
          }
        },
      ),
    );

    nameController.dispose();
    amountController.dispose();

    if (amount == null) return null;
    return TransferInput(name, amount);
  }
}

class _DialogShell extends StatelessWidget {
  final String title;
  final Widget child;
  final String actionText;
  final VoidCallback onAction;

  const _DialogShell({
    required this.title,
    required this.child,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C3E8C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      content: child,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
          ),
          onPressed: onAction,
          child: Text(actionText),
        ),
      ],
    );
  }
}
