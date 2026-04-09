import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/finance_repository.dart';

class CsvExportService {
  static List<List<String>> _incomeRows(List<Income> items) {
    return [
      ['incomes', 'id', 'amount', 'source', 'date', 'account_type', 'note'],
      ...items.map(
        (i) => [
          'income',
          i.id,
          i.amount.toString(),
          i.source,
          i.date.toIso8601String(),
          i.accountType,
          i.note ?? '',
        ],
      ),
    ];
  }

  static List<List<String>> _expenseRows(List<Expense> items) {
    return [
      ['expenses', 'id', 'amount', 'category', 'date', 'account_type', 'note'],
      ...items.map(
        (e) => [
          'expense',
          e.id,
          e.amount.toString(),
          e.category,
          e.date.toIso8601String(),
          e.accountType,
          e.note ?? '',
        ],
      ),
    ];
  }

  static List<List<String>> _wishRows(List<WishlistItem> items) {
    return [
      [
        'wishlist',
        'id',
        'name',
        'estimated_price',
        'priority',
        'purchased',
        'purchased_at',
      ],
      ...items.map(
        (w) => [
          'wish',
          w.id,
          w.name,
          w.estimatedPrice.toString(),
          w.priority.name,
          w.purchased.toString(),
          w.purchasedAt?.toIso8601String() ?? '',
        ],
      ),
    ];
  }

  static String buildCsv(ExportBundle bundle) {
    final converter = const ListToCsvConverter();
    final chunks = <List<List<String>>>[];
    chunks.add(_incomeRows(bundle.incomes));
    chunks.add([[]]);
    chunks.add(_expenseRows(bundle.expenses));
    chunks.add([[]]);
    chunks.add(_wishRows(bundle.wishlist));
    return chunks.map(converter.convert).join('\n');
  }

  static Future<void> shareCsv(
    String csv, {
    String filename = 'catat_uang_export.csv',
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], subject: 'Finance export');
  }
}
