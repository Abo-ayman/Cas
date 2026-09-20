import 'package:flutter/material.dart';

import '../models/transfer.dart';
import '../services/receipt_service.dart';
import '../services/wallet_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/transfer_tile.dart';

class TransfersPage extends StatefulWidget {
  final WalletController wallet;

  const TransfersPage({super.key, required this.wallet});

  @override
  State<TransfersPage> createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  Currency? filter;

  @override
  Widget build(BuildContext context) {
    final list = filter == null
        ? widget.wallet.transfers
        : widget.wallet.transfers
            .where((transfer) => transfer.currency == filter)
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'آخر التحويلات',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ),
            if (widget.wallet.transfers.isNotEmpty)
              IconButton(
                tooltip: 'مسح السجل',
                onPressed: () => _clearHistory(context),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
        const Text(
          'اضغط مطولاً على أي حوالة لفتح إيصال PDF ومشاركته',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        _filters(),
        const SizedBox(height: 15),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(child: Text('لا توجد حوالات بهذا الفلتر')),
          )
        else
          ...list.map(
            (transfer) => TransferTile(
              transfer: transfer,
              onLongPress: () =>
                  ReceiptService.open(context, widget.wallet, transfer),
            ),
          ),
      ],
    );
  }

  Widget _filters() {
    final values = <Currency?>[null, ...Currency.values];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final value = values[index];
          final active = filter == value;
          final label = value?.code ?? 'الكل';
          return ChoiceChip(
            selected: active,
            label: Text(label),
            onSelected: (_) => setState(() => filter = value),
            selectedColor: AppColors.accent,
            backgroundColor: Colors.white.withOpacity(.08),
            labelStyle: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w800,
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Future<void> _clearHistory(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مسح سجل الحوالات؟'),
        content: const Text('سيتم حذف سجل العمليات التجريبية من الجهاز.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
    if (yes == true) await widget.wallet.clearHistory();
  }
}
