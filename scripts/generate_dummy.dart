import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

void main() async {
  print('Loading environment variables...');
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('Error: .env file not found!');
    return;
  }

  final lines = await envFile.readAsLines();
  final env = <String, String>{};
  for (final line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length >= 2) {
      env[parts[0].trim()] = parts.sublist(1).join('=').trim();
    }
  }

  final supabaseUrl = env['SUPABASE_URL'];
  final serviceRoleKey = env['SUPABASE_SERVICE_ROLE_KEY'];

  if (supabaseUrl == null || serviceRoleKey == null) {
    print('Error: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not found in .env');
    return;
  }

  final dio = Dio(BaseOptions(
    baseUrl: '$supabaseUrl/rest/v1',
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': 'Bearer $serviceRoleKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    },
  ));

  print('Fetching existing categories to find user_id...');
  final catResponse = await dio.get('/categories?select=*');
  List categories = catResponse.data;
  
  String? userId;
  for (var c in categories) {
    if (c['user_id'] != null) {
      userId = c['user_id'];
      break;
    }
  }

  if (userId == null) {
    print('No user_id found in categories. Checking transactions...');
    final txResponse = await dio.get('/transactions?select=user_id&limit=1');
    if (txResponse.data.isNotEmpty) {
      userId = txResponse.data[0]['user_id'];
    }
  }

  if (userId == null) {
    print('Error: Could not find any user_id in database. Please create at least one transaction or category in the app first!');
    return;
  }
  print('Found User ID: $userId');

  print('Filtering categories for user...');
  final userCategories = categories.where((c) => c['user_id'] == userId || c['user_id'] == null).toList();
  
  if (userCategories.isEmpty) {
    print('No categories found. Wait, FinAI should have default categories.');
    final defaultCatResponse = await dio.get('/categories?select=*&user_id=is.null');
    userCategories.addAll(defaultCatResponse.data);
  }

  print('Fetching existing assets...');
  final assetResponse = await dio.get('/assets?select=*&user_id=eq.$userId');
  List assets = assetResponse.data;

  if (assets.isEmpty) {
    print('No assets found. Fetching defaults...');
    final defaultAssetResponse = await dio.get('/assets?select=*&user_id=is.null');
    assets.addAll(defaultAssetResponse.data);
  }

  if (userCategories.isEmpty || assets.isEmpty) {
    print('Error: Database has no categories or assets. Cannot generate data.');
    return;
  }

  String getCatId(String name, String type) {
    var c = userCategories.firstWhere((cat) => cat['name'] == name && cat['type'] == type, orElse: () => null);
    if (c != null) return c['id'];
    
    // Fallback
    c = userCategories.firstWhere((cat) => cat['type'] == type, orElse: () => userCategories.first);
    return c['id'];
  }

  final assetList = assets.map((a) => a['id'] as String).toList();
  final random = Random();

  print('Generating transactions...');
  final transactions = [];
  final uuid = Uuid();
  final now = DateTime.now();
  
  // 180 days backward
  for (int i = 180; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final isBeginningOfMonth = date.day >= 1 && date.day <= 3;
    final isEndOfMonth = date.day >= 25 && date.day <= 28;

    final baseDateStr = date.toIso8601String().split('T')[0];

    // Monthly Income
    if (date.day == 25) { // Gajian
      transactions.add({
        'id': uuid.v4(),
        'user_id': userId,
        'amount': 15000000 + (random.nextInt(5) * 500000), // 15-17.5 juta
        'type': 'income',
        'category_id': getCatId('Gaji', 'income'),
        'asset_id': assetList[random.nextInt(assetList.length)],
        'note': 'Gaji Bulan ${date.month}',
        'description': 'Pemasukan rutin bulanan dari perusahaan',
        'transaction_date': '${baseDateStr}T09:00:00Z',
      });
    }

    // Monthly Fixed Expenses
    if (date.day == 2) {
      transactions.add({
        'id': uuid.v4(),
        'user_id': userId,
        'amount': 500000 + random.nextInt(300000), 
        'type': 'expense',
        'category_id': getCatId('Tagihan', 'expense'),
        'asset_id': assetList[random.nextInt(assetList.length)],
        'note': 'Listrik & Air',
        'transaction_date': '${baseDateStr}T10:00:00Z',
      });
      transactions.add({
        'id': uuid.v4(),
        'user_id': userId,
        'amount': 350000, 
        'type': 'expense',
        'category_id': getCatId('Tagihan', 'expense'),
        'asset_id': assetList[random.nextInt(assetList.length)],
        'note': 'Internet WiFi',
        'transaction_date': '${baseDateStr}T10:05:00Z',
      });
    }

    if (date.day == 5) {
      transactions.add({
        'id': uuid.v4(),
        'user_id': userId,
        'amount': 3000000, 
        'type': 'expense',
        'category_id': getCatId('Kendaraan', 'expense'),
        'asset_id': assetList[random.nextInt(assetList.length)],
        'note': 'Cicilan Mobil',
        'transaction_date': '${baseDateStr}T11:00:00Z',
      });
    }

    // Daily Variable Expenses
    if (!isWeekend) {
      // Lunch
      transactions.add({
        'id': uuid.v4(),
        'user_id': userId,
        'amount': 30000 + random.nextInt(45000), 
        'type': 'expense',
        'category_id': getCatId('Makanan', 'expense'),
        'asset_id': assetList[random.nextInt(assetList.length)],
        'note': 'Makan Siang',
        'transaction_date': '${baseDateStr}T12:30:00Z',
      });
      
      // Transport
      if (random.nextDouble() > 0.3) {
        transactions.add({
          'id': uuid.v4(),
          'user_id': userId,
          'amount': 20000 + random.nextInt(80000), 
          'type': 'expense',
          'category_id': getCatId('Transportasi', 'expense'),
          'asset_id': assetList[random.nextInt(assetList.length)],
          'note': 'Bensin / Tol / Ojol',
          'transaction_date': '${baseDateStr}T08:30:00Z',
        });
      }

      // Coffee
      if (random.nextDouble() > 0.4) {
        transactions.add({
          'id': uuid.v4(),
          'user_id': userId,
          'amount': 25000 + random.nextInt(25000), 
          'type': 'expense',
          'category_id': getCatId('Makanan', 'expense'),
          'asset_id': assetList[random.nextInt(assetList.length)],
          'note': 'Ngopi Sore',
          'transaction_date': '${baseDateStr}T15:30:00Z',
        });
      }
    } else {
      // Weekend Expenses
      if (isBeginningOfMonth) {
        transactions.add({
          'id': uuid.v4(),
          'user_id': userId,
          'amount': 800000 + random.nextInt(700000), 
          'type': 'expense',
          'category_id': getCatId('Belanja', 'expense'),
          'asset_id': assetList[random.nextInt(assetList.length)],
          'note': 'Belanja Bulanan Supermarket',
          'transaction_date': '${baseDateStr}T16:00:00Z',
        });
      }

      transactions.add({
        'id': uuid.v4(),
        'user_id': userId,
        'amount': 150000 + random.nextInt(350000), 
        'type': 'expense',
        'category_id': getCatId('Hiburan', 'expense'),
        'asset_id': assetList[random.nextInt(assetList.length)],
        'note': 'Nonton Bioskop & Makan',
        'transaction_date': '${baseDateStr}T19:00:00Z',
      });
    }
  }

  print('Generated ${transactions.length} transactions. Standardizing keys...');
  
  // PostgREST requires all objects in an array to have the EXACT same keys.
  final allKeys = ['id', 'user_id', 'amount', 'type', 'category_id', 'asset_id', 'note', 'description', 'transaction_date'];
  final standardizedTransactions = transactions.map((tx) {
    final Map<String, dynamic> stdTx = {};
    for (final key in allKeys) {
      stdTx[key] = tx[key]; // Will be null if not present, which is correct
    }
    return stdTx;
  }).toList();

  print('Inserting in batches...');
  int batchSize = 100;
  for (int i = 0; i < standardizedTransactions.length; i += batchSize) {
    int end = (i + batchSize < standardizedTransactions.length) ? i + batchSize : standardizedTransactions.length;
    final batch = standardizedTransactions.sublist(i, end);
    try {
      await dio.post('/transactions', data: batch);
      print('Inserted batch ${i ~/ batchSize + 1}');
    } catch (e) {
      if (e is DioException) {
        print('Error inserting batch: ${e.response?.data}');
      } else {
        print('Unknown error: $e');
      }
    }
  }

  print('Done! Successfully injected 6 months of data.');
}
