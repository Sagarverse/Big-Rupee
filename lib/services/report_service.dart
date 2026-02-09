import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/transaction_entry.dart';

class ReportService {
  Future<void> shareMonthlyReport({
    required String title,
    required String currency,
    required double income,
    required double expenses,
    required Map<String, double> categoryTotals,
    required List<TransactionEntry> recent,
  }) async {
    final doc = pw.Document();
    final formatter = NumberFormat.currency(symbol: currency);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text('Income: ${formatter.format(income)}'),
              pw.Text('Expenses: ${formatter.format(expenses)}'),
              pw.Text('Remaining: ${formatter.format(income - expenses)}'),
              pw.SizedBox(height: 16),
              pw.Text('Category breakdown', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              ...categoryTotals.entries.map(
                (entry) => pw.Text('${entry.key}: ${formatter.format(entry.value)}'),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Recent activity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              ...recent.map(
                (entry) => pw.Text(
                  '${entry.title} • ${entry.category} • ${formatter.format(entry.amount)}',
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: 'finflow_report.pdf');
  }
}
