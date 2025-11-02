import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/farmer_model.dart';
import '../models/milk_collection_model.dart';
import '../controllers/farmer_controller.dart';
import '../controllers/milk_controller.dart';
import '../controllers/transaction_controller.dart';

class DemoDataService {
  static final Random _random = Random();

  // Indian first names
  static const List<String> _firstNames = [
    'Rajesh', 'Suresh', 'Mahesh', 'Ramesh', 'Dinesh', 'Mukesh', 'Rakesh', 'Naresh',
    'Priya', 'Pooja', 'Anita', 'Sunita', 'Kavita', 'Lalita', 'Savita', 'Geeta',
    'Amit', 'Sumit', 'Rohit', 'Mohit', 'Lalit', 'Ajit', 'Ranjit', 'Sanjit',
    'Arjun', 'Varun', 'Tarun', 'Karan', 'Vikram', 'Akash', 'Prakash', 'Subhash',
    'Sanjay', 'Vijay', 'Ajay', 'Vinay', 'Manoj', 'Anil', 'Sunil', 'Kapil',
    'Deepak', 'Ashok', 'Alok', 'Santosh', 'Manish', 'Harish', 'Girish', 'Jagdish',
    'Ravi', 'Shiv', 'Krishna', 'Ram', 'Govind', 'Mohan', 'Sohan', 'Rohan',
    'Ganesh', 'Ramesh', 'Lokesh', 'Yogesh', 'Hitesh', 'Jitesh', 'Ritesh', 'Umesh',
    'Pankaj', 'Neeraj', 'Dheeraj', 'Sameer', 'Tanveer', 'Naveen', 'Praveen', 'Javed',
    'Yash', 'Harsh', 'Aarav', 'Vivek', 'Aditya', 'Siddharth', 'Sahil', 'Nikhil',
  ];

  // Indian last names
  static const List<String> _lastNames = [
    'Kumar', 'Singh', 'Sharma', 'Verma', 'Gupta', 'Patel', 'Yadav', 'Reddy',
    'Nair', 'Pillai', 'Menon', 'Das', 'Bose', 'Roy', 'Ghosh', 'Banerjee',
    'Mishra', 'Pandey', 'Tiwari', 'Dubey', 'Tripathi', 'Joshi', 'Bhatt', 'Desai',
    'Shah', 'Mehta', 'Thakur', 'Rao', 'Iyer', 'Agarwal', 'Jain', 'Chopra',
    'Malhotra', 'Kapoor', 'Bhatia', 'Sethi', 'Arora', 'Khanna', 'Saxena', 'Sinha',
    'Chaudhary', 'Chauhan', 'Rathore', 'Rajput', 'Bisht', 'Rawat', 'Negi', 'Garg',
    'Ahluwalia', 'Anand', 'Bajaj', 'Bedi', 'Dua', 'Gill', 'Grover', 'Kohli',
    'Mallik', 'Naik', 'Pawar', 'Raman', 'Saini', 'Tandon', 'Varma', 'Zaveri',
  ];

  // Village/Town names in India
  static const List<String> _villages = [
    'Rampur', 'Shivpur', 'Ganeshpur', 'Gokulpur', 'Haripur', 'Madhavpur',
    'Kishanganj', 'Raiganj', 'Sultanpur', 'Azamgarh', 'Deoghar', 'Ghazipur',
    'Balrampur', 'Fatehpur', 'Sitapur', 'Jaunpur', 'Pratapgarh', 'Shahjahanpur',
    'Karimnagar', 'Nizamabad', 'Warangal', 'Khammam', 'Anantpur', 'Chittoor',
    'Tiruvallur', 'Vellore', 'Tirunelveli', 'Madurai', 'Coimbatore', 'Salem',
    'Belgaum', 'Gulbarga', 'Bijapur', 'Raichur', 'Shimoga', 'Davangere',
    'Ujjain', 'Ratlam', 'Mandsaur', 'Neemuch', 'Guna', 'Shivpuri',
  ];

  static String _generateName() {
    final firstName = _firstNames[_random.nextInt(_firstNames.length)];
    final lastName = _lastNames[_random.nextInt(_lastNames.length)];
    return '$firstName $lastName';
  }

  static String _generateVillage() {
    return _villages[_random.nextInt(_villages.length)];
  }

  static String _generatePhone() {
    final prefix = ['98', '97', '96', '95', '94', '93', '92', '91', '90', '89'];
    final selectedPrefix = prefix[_random.nextInt(prefix.length)];
    final number = _random.nextInt(90000000) + 10000000; // 8 digit number
    return '$selectedPrefix$number';
  }

  static MilkType _generateMilkType() {
    final types = [MilkType.cow, MilkType.buffalo, MilkType.both];
    final weights = [50, 30, 20]; // Cow is most common
    final rand = _random.nextInt(100);
    int sum = 0;
    for (int i = 0; i < types.length; i++) {
      sum += weights[i];
      if (rand < sum) return types[i];
    }
    return types[0];
  }

  static double _generateLiters(MilkType milkType) {
    // Buffalo gives more milk than cow
    if (milkType == MilkType.buffalo) {
      return 8.0 + _random.nextDouble() * 12.0; // 8-20 liters
    } else if (milkType == MilkType.cow) {
      return 5.0 + _random.nextDouble() * 10.0; // 5-15 liters
    } else {
      return 6.0 + _random.nextDouble() * 11.0; // 6-17 liters
    }
  }

  static double _generateFat(MilkType milkType) {
    // Buffalo milk has higher fat content
    if (milkType == MilkType.buffalo) {
      return 6.5 + _random.nextDouble() * 1.5; // 6.5-8.0%
    } else if (milkType == MilkType.cow) {
      return 3.5 + _random.nextDouble() * 1.5; // 3.5-5.0%
    } else {
      return 4.5 + _random.nextDouble() * 2.0; // 4.5-6.5%
    }
  }

  static double _generateSnf(MilkType milkType) {
    // SNF is generally stable across types
    if (milkType == MilkType.buffalo) {
      return 8.5 + _random.nextDouble() * 1.0; // 8.5-9.5%
    } else if (milkType == MilkType.cow) {
      return 8.3 + _random.nextDouble() * 0.7; // 8.3-9.0%
    } else {
      return 8.4 + _random.nextDouble() * 0.9; // 8.4-9.3%
    }
  }

  static Future<List<FarmerModel>> generateFarmers(int count) async {
    final farmers = <FarmerModel>[];
    final usedNames = <String>{};

    for (int i = 0; i < count; i++) {
      String name;
      do {
        name = _generateName();
      } while (usedNames.contains(name));
      usedNames.add(name);

      final farmer = FarmerModel(
        id: 'demo_farmer_${i + 1}',
        name: name,
        phone: _generatePhone(),
        village: _generateVillage(),
        milkType: _generateMilkType(),
        runningBalance: 0.0,
        isActive: true,
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        updatedAt: DateTime.now(),
      );

      farmers.add(farmer);
    }

    return farmers;
  }

  static Future<List<MilkCollectionModel>> generateMilkCollections(
    List<FarmerModel> farmers,
    int daysBack,
    String collectorId,
  ) async {
    final collections = <MilkCollectionModel>[];
    final now = DateTime.now();

    for (int day = 0; day < daysBack; day++) {
      final date = now.subtract(Duration(days: day));
      
      // Random number of farmers deliver milk each day (60-90% of total)
      final deliveryCount = (farmers.length * (0.6 + _random.nextDouble() * 0.3)).toInt();
      final shuffledFarmers = List<FarmerModel>.from(farmers)..shuffle(_random);
      final deliveringFarmers = shuffledFarmers.take(deliveryCount);

      for (final farmer in deliveringFarmers) {
        // Some farmers deliver both morning and evening (40% chance)
        final shifts = _random.nextDouble() < 0.4 
            ? [Shift.morning, Shift.evening] 
            : [_random.nextBool() ? Shift.morning : Shift.evening];

        for (final shift in shifts) {
          final liters = _generateLiters(farmer.milkType);
          final fat = _generateFat(farmer.milkType);
          final snf = _generateSnf(farmer.milkType);
          final rate = _calculateRate(fat, snf);
          final amount = liters * rate;

          final collection = MilkCollectionModel(
            id: 'demo_collection_${collections.length + 1}',
            farmerId: farmer.id,
            date: DateTime(date.year, date.month, date.day),
            shift: shift,
            quantity: double.parse(liters.toStringAsFixed(1)),
            fat: double.parse(fat.toStringAsFixed(1)),
            snf: double.parse(snf.toStringAsFixed(1)),
            ratePerLiter: double.parse(rate.toStringAsFixed(2)),
            totalAmount: double.parse(amount.toStringAsFixed(2)),
            collectorId: collectorId,
            createdAt: DateTime(date.year, date.month, date.day, shift == Shift.morning ? 7 : 18),
          );

          collections.add(collection);
        }
      }
    }

    return collections;
  }

  static double _calculateRate(double fat, double snf) {
    // Simple rate calculation: base rate + (fat * fat_rate) + (snf * snf_rate)
    const baseRate = 10.0;
    const fatRate = 5.0;
    const snfRate = 2.0;
    return baseRate + (fat * fatRate) + (snf * snfRate);
  }

  /// Load demo data into the app - ULTRA FAST VERSION
  static Future<void> loadDemoData({
    required BuildContext context,
    required String collectorId,
    int farmerCount = 50, // Reduced to 50 for instant loading
    int daysBack = 3, // Only 3 days
  }) async {
    // Get controllers BEFORE async operations
    final farmerController = context.read<FarmerController>();
    final milkController = context.read<MilkController>();
    
    final startTime = DateTime.now();
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading demo data...'),
            ],
          ),
        ),
      );

      print('⏱️ START: ${startTime.toIso8601String()}');
      print('🌱 Generating $farmerCount demo farmers...');
      final farmers = await generateFarmers(farmerCount);
      print('   ✅ Generated in ${DateTime.now().difference(startTime).inMilliseconds}ms');

      print('💾 Batch saving to database...');
      final dbStart = DateTime.now();
      
      // Use batch operation - much faster!
      final farmersBox = await Hive.openBox('farmers');
      final collectionsBox = await Hive.openBox('milk_collections');
      
      // Clear existing data
      await Future.wait([
        farmersBox.clear(),
        collectionsBox.clear(),
      ]);
      
      // Prepare farmer data
      final farmerMap = <String, dynamic>{};
      for (final farmer in farmers) {
        farmerMap[farmer.id] = farmer.toJson();
      }
      
      // Prepare collection data
      final collectionsMap = <String, dynamic>{};
      final now = DateTime.now();
      int collectionCount = 0;
      
      for (int day = 0; day < daysBack; day++) {
        final date = now.subtract(Duration(days: day));
        
        // Only 30% of farmers deliver each day for faster generation
        final deliveryCount = (farmers.length * 0.3).toInt();
        final shuffledFarmers = List<FarmerModel>.from(farmers)..shuffle(_random);
        final deliveringFarmers = shuffledFarmers.take(deliveryCount);

        for (final farmer in deliveringFarmers) {
          final shift = Shift.morning;
          final liters = _generateLiters(farmer.milkType);
          final fat = _generateFat(farmer.milkType);
          final snf = _generateSnf(farmer.milkType);
          final rate = _calculateRate(fat, snf);
          final amount = liters * rate;

          final collection = MilkCollectionModel(
            id: 'demo_${collectionCount + 1}',
            farmerId: farmer.id,
            date: DateTime(date.year, date.month, date.day),
            shift: shift,
            quantity: double.parse(liters.toStringAsFixed(1)),
            fat: double.parse(fat.toStringAsFixed(1)),
            snf: double.parse(snf.toStringAsFixed(1)),
            ratePerLiter: double.parse(rate.toStringAsFixed(2)),
            totalAmount: double.parse(amount.toStringAsFixed(2)),
            collectorId: collectorId,
            createdAt: DateTime(date.year, date.month, date.day, 7),
          );
          
          collectionsMap[collection.id] = collection.toJson();
          collectionCount++;
        }
      }
      
      // Save everything at once
      await Future.wait([
        farmersBox.putAll(farmerMap),
        collectionsBox.putAll(collectionsMap),
      ]);
      
      print('   ✅ DB saved in ${DateTime.now().difference(dbStart).inMilliseconds}ms');

      // Reload data in controllers
      final reloadStart = DateTime.now();
      await Future.wait([
        farmerController.loadFarmers(),
        milkController.loadCollections(),
      ]);
      print('   ✅ Reloaded in ${DateTime.now().difference(reloadStart).inMilliseconds}ms');

      final totalTime = DateTime.now().difference(startTime);
      print('⏱️ TOTAL TIME: ${totalTime.inMilliseconds}ms (${(totalTime.inMilliseconds / 1000).toStringAsFixed(1)}s)');

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Loaded in ${(totalTime.inMilliseconds / 1000).toStringAsFixed(1)}s: $farmerCount farmers, $collectionCount collections'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      print('✅ Demo data loaded successfully!');
      print('   - $farmerCount farmers');
      print('   - $collectionCount milk collections');
    } catch (e, stackTrace) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('❌ Error loading demo data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Clear all demo data - ULTRA FAST
  static Future<void> clearDemoData({required BuildContext context}) async {
    // Get controllers BEFORE async operations
    final farmerController = context.read<FarmerController>();
    final milkController = context.read<MilkController>();
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Clearing...'),
            ],
          ),
        ),
      );

      print('🗑️ Clearing all data...');
      
      // Clear all boxes directly
      final farmersBox = await Hive.openBox('farmers');
      final collectionsBox = await Hive.openBox('milk_collections');
      
      await Future.wait([
        farmersBox.clear(),
        collectionsBox.clear(),
      ]);
      
      print('   ✅ Cleared all data');

      // Reload controllers in parallel
      await Future.wait([
        farmerController.loadFarmers(),
        milkController.loadCollections(),
      ]);

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All Data Cleared'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
