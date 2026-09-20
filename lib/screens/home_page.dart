import 'package:flutter/material.dart';

import '../services/wallet_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import '../widgets/currency_selector.dart';
import '../widgets/transfer_tile.dart';
import '../services/receipt_service.dart';
import '../models/transfer.dart';
import 'transfer_dialog.dart';

class HomePage extends StatelessWidget {
  final WalletController wallet;
  final VoidCallback? onViewTransfers;

  const HomePage({super.key, required this.wallet, this.onViewTransfers});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        _header(),
        const SizedBox(height: 18),
        _balanceSection(),
        const SizedBox(height: 12),
        CurrencySelector(wallet: wallet),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _mainButton(
                'استقبال',
                Icons.south_west_rounded,
                AppColors.receive,
                () => _receive(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mainButton(
                'إرسال',
                Icons.north_east_rounded,
                AppColors.send,
                () => _send(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _quickPanel(),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'آخر التحويلات',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewTransfers,
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        if (wallet.transfers.isEmpty)
          _empty()
        else
          ...wallet.transfers.take(5).map(
            (transfer) => TransferTile(
              transfer: transfer,
              onLongPress: () => _showReceiptHint(context, transfer),
            ),
          ),
      ],
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 32),
            Positioned(
              right: -4,
              top: -5,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '1',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const BrandMark(),
      ],
    );
  }

  Widget _balanceSection() {
    return Column(
      children: [
        Row(
          children: [
            InkWell(
              onTap: wallet.toggleHidden,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 66,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  wallet.hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 27,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الرصيد المتاح',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    wallet.selectedCurrency.arabicName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            wallet.hidden
                ? '••••••'
                : TransferTile.money(
                    wallet.selectedBalance,
                    wallet.selectedCurrency,
                  ),
            style: const TextStyle(
              fontSize: 39,
              fontWeight: FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback action,
  ) {
    return SizedBox(
      height: 103,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Row(
        children: const [
          Expanded(child: _Quick(icon: Icons.layers_rounded, title: 'مدفوعات')),
          Expanded(child: _Quick(icon: Icons.bookmark_rounded, title: 'خدماتي')),
          Expanded(child: _Quick(icon: Icons.receipt_long_rounded, title: 'فواتير')),
          Expanded(child: _Quick(icon: Icons.more_horiz_rounded, title: 'المزيد')),
        ],
      ),
    );
  }

  Widget _empty() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: Text('لا توجد حوالات بعد')),
    );
  }

  Future<void> _send(BuildContext context) async {
    final result = await TransferDialog.show(
      context,
      incoming: false,
      currency: wallet.selectedCurrency,
    );
    if (result == null) return;

    final ok = wallet.send(result.name, result.amount);
    if (!ok) {
      _message(context, 'المبلغ أكبر من الرصيد المتاح', AppColors.negative);
      return;
    }

    _message(context, 'تم التحويل بنجاح', AppColors.positive);
  }

  Future<void> _receive(BuildContext context) async {
    final result = await TransferDialog.show(
      context,
      incoming: true,
      currency: wallet.selectedCurrency,
    );
    if (result == null) return;

    wallet.receive(result.name, result.amount);
    _message(context, 'تم استلام الحوالة بنجاح', AppColors.positive);
  }

  Future<void> _showReceiptHint(BuildContext context, Transfer transfer) async {
    await ReceiptService.open(context, wallet, transfer);
  }

  void _message(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Quick({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 53,
          height: 53,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 27),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
