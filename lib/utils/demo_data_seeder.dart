import 'dart:math';
import '../models/farmer_model.dart';
import '../models/milk_collection_model.dart';
import '../controllers/farmer_controller.dart';
import '../controllers/milk_controller.dart';
import '../controllers/transaction_controller.dart';

class DemoDataSeeder {
  static final Random _random = Random();

  // Indian farmer names
  static final List<String> _firstNames = [
    'Rajesh', 'Suresh', 'Mahesh', 'Ramesh', 'Dinesh', 'Ganesh', 'Mukesh', 'Rakesh',
    'Priya', 'Sunita', 'Kavita', 'Geeta', 'Anita', 'Mamta', 'Asha', 'Usha',
    'Vijay', 'Ajay', 'Sanjay', 'Manoj', 'Anil', 'Sunil', 'Ravi', 'Prakash',
    'Pooja', 'Neha', 'Ritu', 'Suman', 'Rekha', 'Meena', 'Seema', 'Nisha',
    'Amit', 'Sumit', 'Rohit', 'Mohit', 'Lalit', 'Punit', 'Kiran', 'Deepak',
    'Radha', 'Krishna', 'Shyam', 'Mohan', 'Gopal', 'Hari', 'Ganga', 'Yamuna',
    'Narendra', 'Devendra', 'Surendra', 'Jitendra', 'Nagendra', 'Mahendra',
    'Lakshmi', 'Saraswati', 'Parvati', 'Durga', 'Kali', 'Sita', 'Savitri',
    'Balram', 'Hanuman', 'Arjun', 'Bheem', 'Nakul', 'Sahdev', 'Yudhisthir',
    'Ramakant', 'Shivkumar', 'Vishnu', 'Brahma', 'Indra', 'Varuna', 'Agni'
  ];

  static final List<String> _lastNames = [
    'Kumar', 'Patel', 'Singh', 'Sharma', 'Verma', 'Gupta', 'Yadav', 'Reddy',
    'Nair', 'Iyer', 'Desai', 'Joshi', 'Mehta', 'Shah', 'Agarwal', 'Bansal',
    'Chauhan', 'Rathore', 'Solanki', 'Thakur', 'Rao', 'Naidu', 'Pillai', 'Menon',
    'Pandey', 'Mishra', 'Tiwari', 'Dubey', 'Saxena', 'Srivastava', 'Chaudhary',
    'Jain', 'Garg', 'Malhotra', 'Kapoor', 'Khanna', 'Bhatia', 'Sethi', 'Arora',
    'Chopra', 'Ahuja', 'Bajaj', 'Mittal', 'Singhal', 'Goyal', 'Jindal', 'Aggarwal'
  ];

  static final List<String> _villages = [
    'Rampur', 'Shivpur', 'Ganeshpur', 'Haripur', 'Gokulpur', 'Mathurapur',
    'Govindpur', 'Kishanpur', 'Nandpur', 'Vrindavan', 'Ayodhya', 'Kashi',
    'Shivapur', 'Ganeshapur', 'Laxmipur', 'Saraswatipur', 'Durganagar',
    'Kalyanpur', 'Mangalpur', 'Suryapur', 'Chandrapur', 'Indrapur', 'Varunapur',
    'Agnipur', 'Vayupur', 'Dharampur', 'Karmapur', 'Mokshpur', 'Anandpur',
    'Shantinagar', 'Prempur', 'Sevakpur', 'Bhaktipur', 'Gyanapur', 'Vidyapur'
  ];

  static final List<String> _districts = [
    'Rampur', 'Shivapur', 'Mathura', 'Vrindavan', 'Ayodhya', 'Varanasi',
    'Allahabad', 'Kanpur', 'Lucknow', 'Meerut', 'Agra', 'Bareilly',
    'Moradabad', 'Aligarh', 'Ghaziabad', 'Faizabad', 'Gorakhpur', 'Jhansi'
  ];

  static String _generatePhoneNumber() {
    // Indian mobile numbers: +91 followed by 10 digits (starting with 6-9)
    final firstDigit = 6 + _random.nextInt(4); // 6, 7, 8, or 9
    final remainingDigits = List.generate(9, (_) => _random.nextInt(10)).join();
    return '$firstDigit$remainingDigits';
  }

  static String _generateBankAccount() {
    // 11-16 digit bank account number
    final length = 11 + _random.nextInt(6);
    return List.generate(length, (_) => _random.nextInt(10)).join();
  }

  static String _generateIfscCode() {
    // Format: ABCD0123456 (4 letters + 7 digits)
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final bank = List.generate(4, (_) => letters[_random.nextInt(letters.length)]).join();
    final branch = _random.nextInt(10000000).toString().padLeft(7, '0');
    return '$bank$branch';
  }

  static Future<void> seedDemoData({
    required int farmerCount,
    required FarmerController farmerController,
    required MilkController milkController,
    required TransactionController transactionController,
    required String collectorId,
  }) async {
    try {
      print('🌱 Starting demo data seeding...');
      print('📊 Creating $farmerCount farmers with milk collections...');

      final List<FarmerModel> farmers = [];
      
      // Generate farmers
      for (int i = 0; i < farmerCount; i++) {
        final firstName = _firstNames[_random.nextInt(_firstNames.length)];
        final lastName = _lastNames[_random.nextInt(_lastNames.length)];
        final name = '$firstName $lastName';
        final village = _villages[_random.nextInt(_villages.length)];
        final district = _districts[_random.nextInt(_districts.length)];
        
        // Milk type distribution: 40% Cow, 40% Buffalo, 20% Mixed
        final milkTypeRand = _random.nextInt(10);
        final milkTypeEnum = milkTypeRand < 4 ? MilkType.cow : (milkTypeRand < 8 ? MilkType.buffalo : MilkType.both);
        
        final success = await farmerController.addFarmer(
          name: name,
          village: village,
          phone: _generatePhoneNumber(),
          milkType: milkTypeEnum,
        );

        if (success) {
          final allFarmers = farmerController.getAllFarmers();
          if (allFarmers.isNotEmpty) {
            farmers.add(allFarmers.last);
          }
        }
        
        if ((i + 1) % 50 == 0) {
          print('✅ Created ${i + 1} farmers...');
        }
      }

      print('✅ All $farmerCount farmers created!');
      print('🥛 Creating milk collections...');

      // Generate milk collections for the last 30 days
      final now = DateTime.now();
      int collectionCount = 0;

      for (int day = 0; day < 30; day++) {
        final date = now.subtract(Duration(days: day));
        
        // Randomly select 60-80% of farmers to have collected milk that day
        final collectingFarmers = farmers.where((_) => _random.nextDouble() < 0.7).toList();
        
        for (final farmer in collectingFarmers) {
          // Each farmer has 1-2 collections (morning and/or evening)
          final hasMorning = _random.nextDouble() < 0.9; // 90% have morning
          final hasEvening = _random.nextDouble() < 0.7; // 70% have evening
          
          if (hasMorning) {
            await _createMilkCollection(
              farmer: farmer,
              date: date,
              shift: Shift.morning,
              collectorId: collectorId,
              milkController: milkController,
              farmerController: farmerController,
              transactionController: transactionController,
            );
            collectionCount++;
          }
          
          if (hasEvening) {
            await _createMilkCollection(
              farmer: farmer,
              date: date,
              shift: Shift.evening,
              collectorId: collectorId,
              milkController: milkController,
              farmerController: farmerController,
              transactionController: transactionController,
            );
            collectionCount++;
          }
        }
        
        if ((day + 1) % 10 == 0) {
          print('✅ Processed $collectionCount collections for ${day + 1} days...');
        }
      }

      print('✅ Created $collectionCount milk collections!');
      print('🎉 Demo data seeding completed successfully!');
      print('📈 Summary:');
      print('   - Farmers: ${farmers.length}');
      print('   - Milk Collections: $collectionCount');
      print('   - Date Range: Last 30 days');
      
    } catch (e) {
      print('❌ Error seeding demo data: $e');
      rethrow;
    }
  }

  static Future<void> _createMilkCollection({
    required FarmerModel farmer,
    required DateTime date,
    required Shift shift,
    required String collectorId,
    required MilkController milkController,
    required FarmerController farmerController,
    required TransactionController transactionController,
  }) async {
    // Generate realistic FAT and SNF values based on milk type
    double fat, snf;
    
    if (farmer.milkType == 'Buffalo') {
      // Buffalo milk: FAT 6.5-8.5%, SNF 8.5-9.5%
      fat = 6.5 + _random.nextDouble() * 2.0;
      snf = 8.5 + _random.nextDouble() * 1.0;
    } else if (farmer.milkType == 'Cow') {
      // Cow milk: FAT 3.5-5.5%, SNF 8.0-9.0%
      fat = 3.5 + _random.nextDouble() * 2.0;
      snf = 8.0 + _random.nextDouble() * 1.0;
    } else {
      // Mixed: FAT 4.5-7.0%, SNF 8.2-9.2%
      fat = 4.5 + _random.nextDouble() * 2.5;
      snf = 8.2 + _random.nextDouble() * 1.0;
    }

    // Quantity: 5-25 liters, more in morning typically
    final baseQuantity = shift == Shift.morning ? 12.0 : 8.0;
    final quantity = baseQuantity + (_random.nextDouble() * 10.0) - 5.0;

    await milkController.addMilkCollection(
      farmerId: farmer.id,
      date: date,
      shift: shift,
      quantity: double.parse(quantity.toStringAsFixed(1)),
      fat: double.parse(fat.toStringAsFixed(1)),
      snf: double.parse(snf.toStringAsFixed(1)),
      collectorId: collectorId,
      farmerController: farmerController,
      transactionController: transactionController,
    );
  }

  static Future<void> clearAllDemoData() async {
    try {
      print('🗑️  Clearing all demo data...');
      
      // Note: You'll need to add these methods to DatabaseService
      // For now, we can only add data, not delete
      
      print('⚠️  Manual deletion required through the app UI');
      print('   Go to Farmers screen and delete farmers manually');
      
    } catch (e) {
      print('❌ Error clearing demo data: $e');
      rethrow;
    }
  }
}
