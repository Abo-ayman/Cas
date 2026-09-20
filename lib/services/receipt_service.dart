import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import '../models/transfer.dart';
import '../services/wallet_controller.dart';
import '../theme/app_theme.dart';

class ReceiptService {
  static Future<Uint8List> buildPdf(
    WalletController wallet,
    Transfer transfer,
  ) async {
    final regular = pw.Font.ttf(
      (await rootBundle.load(
        'assets/fonts/NotoSansArabic-Regular.ttf',
      )).buffer.asByteData(),
    );
    final bold = pw.Font.ttf(
      (await rootBundle.load(
        'assets/fonts/NotoSansArabic-Bold.ttf',
      )).buffer.asByteData(),
    );

    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: bold,
      ),
    );

    final type = transfer.incoming ? 'استقبال' : 'إرسال';
    final sender = transfer.incoming ? transfer.name : wallet.accountName;
    final receiver = transfer.incoming ? wallet.accountName : transfer.name;

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 32, 38, 32),
        build: (_) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                height: 6,
                color: PdfColor.fromInt(0xFF4B86DD),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'العملية $type - رقم ${transfer.id}',
                style: pw.TextStyle(font: bold, fontSize: 19),
              ),
              pw.SizedBox(height: 22),
              _row(
                'تاريخ العملية',
                DateFormat('yyyy-MM-dd - HH:mm:ss').format(transfer.date),
                regular,
                bold,
              ),
              _row('اسم المرسل', sender, regular, bold),
              _row('حساب المرسل', '0214********', regular, bold),
              _row('اسم المستلم', receiver, regular, bold),
              _row('حساب المستلم', '2670********', regular, bold),
              _row(
                'المبلغ',
                '${transfer.amount.toStringAsFixed(transfer.currency == Currency.syp ? 0 : 2)} ${transfer.currency.symbol}',
                regular,
                bold,
              ),
              _row('الملاحظة', '', regular, bold),
              _row('صاحب الحساب', wallet.accountName, regular, bold),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Text(
                'Sam Cash',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: bold, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );

    return document.save();
  }

  static pw.Widget _row(
    String label,
    String value,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(font: bold, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: regular, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> open(
    BuildContext context,
    WalletController wallet,
    Transfer transfer,
  ) async {
    final bytes = await buildPdf(wallet, transfer);
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF183A88),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إيصال الحوالة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Printing.layoutPdf(
                      onLayout: (_) async => bytes,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('معاينة الإيصال PDF'),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final file = XFile.fromData(
                      bytes,
                      name: 'sam_cash_${transfer.id}.pdf',
                      mimeType: 'application/pdf',
                    );
                    await Share.shareXFiles(
                      [file],
                      text: 'إيصال حوالة Sam Cash',
                    );
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('مشاركة الإيصال'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
