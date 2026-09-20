import 'package:flutter/material.dart';

import 'screens/account_page.dart';
import 'screens/home_page.dart';
import 'screens/services_page.dart';
import 'screens/transfers_page.dart';
import 'services/wallet_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/app_background.dart';
import 'widgets/bottom_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final wallet = WalletController();
  await wallet.load();

  runApp(SamCashApp(wallet: wallet));
}

class SamCashApp extends StatelessWidget {
  final WalletController wallet;

  const SamCashApp({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wallet,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sam Cash',
          theme: AppTheme.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SamShell(wallet: wallet),
          ),
        );
      },
    );
  }
}

class SamShell extends StatefulWidget {
  final WalletController wallet;

  const SamShell({super.key, required this.wallet});

  @override
  State<SamShell> createState() => _SamShellState();
}

class _SamShellState extends State<SamShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        wallet: widget.wallet,
        onViewTransfers: () => setState(() => index = 1),
      ),
      TransfersPage(wallet: widget.wallet),
      const ServicesPage(),
      AccountPage(wallet: widget.wallet),
    ];

    return Scaffold(
      extendBody: true,
      body: AppBackground(
        child: SafeArea(
          child: pages[index],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQr(context),
        backgroundColor: AppColors.accent,
        elevation: 10,
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          size: 31,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SamBottomBar(
        index: index,
        onChanged: (value) => setState(() => index = value),
        onQr: () => _showQr(context),
      ),
    );
  }

  void _showQr(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF193D91),
        title: const Text(
          'رمز الاستقبال',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_2_rounded,
              size: 190,
              color: AppColors.accent,
            ),
            SizedBox(height: 12),
            Text('SAM-CASH-DEMO'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
