import 'package:hive/hive.dart';

part 'quality_test_model.g.dart';

@HiveType(typeId: 21)
class QualityTestModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String sampleId;

  @HiveField(2)
  String farmerId;

  @HiveField(3)
  String farmerName;

  @HiveField(4)
  String? centerId;

  @HiveField(5)
  String? centerName;

  @HiveField(6)
  double fatPercentage;

  @HiveField(7)
  double snfPercentage; // Solids Not Fat

  @HiveField(8)
  double clr; // Corrected Lactometer Reading

  @HiveField(9)
  double lactometerReading;

  @HiveField(10)
  double temperature;

  @HiveField(11)
  double? waterPercentage;

  @HiveField(12)
  TestResult result;

  @HiveField(13)
  List<String> adulterations;

  @HiveField(14)
  double milkQuantity;

  @HiveField(15)
  DateTime testDate;

  @HiveField(16)
  String testedBy;

  @HiveField(17)
  String? remarks;

  @HiveField(18)
  bool certificateGenerated;

  @HiveField(19)
  DateTime createdAt;

  QualityTestModel({
    required this.id,
    required this.sampleId,
    required this.farmerId,
    required this.farmerName,
    this.centerId,
    this.centerName,
    required this.fatPercentage,
    required this.snfPercentage,
    required this.clr,
    required this.lactometerReading,
    required this.temperature,
    this.waterPercentage,
    required this.result,
    this.adulterations = const [],
    required this.milkQuantity,
    required this.testDate,
    required this.testedBy,
    this.remarks,
    this.certificateGenerated = false,
    required this.createdAt,
  });

  bool get isPassed => result == TestResult.passed;
  bool get hasAdulteration => adulterations.isNotEmpty;
  
  String get qualityGrade {
    if (fatPercentage >= 6.0 && snfPercentage >= 9.0) return 'A+';
    if (fatPercentage >= 5.0 && snfPercentage >= 8.5) return 'A';
    if (fatPercentage >= 4.0 && snfPercentage >= 8.0) return 'B';
    if (fatPercentage >= 3.0 && snfPercentage >= 7.5) return 'C';
    return 'D';
  }
}

@HiveType(typeId: 22)
enum TestResult {
  @HiveField(0)
  passed,
  
  @HiveField(1)
  failed,
  
  @HiveField(2)
  rejected,
  
  @HiveField(3)
  pending,
}

@HiveType(typeId: 23)
class QualityStandardModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double minFat;

  @HiveField(3)
  double maxFat;

  @HiveField(4)
  double minSnf;

  @HiveField(5)
  double maxSnf;

  @HiveField(6)
  double minClr;

  @HiveField(7)
  double maxClr;

  @HiveField(8)
  double minTemperature;

  @HiveField(9)
  double maxTemperature;

  @HiveField(10)
  double maxWaterContent;

  @HiveField(11)
  bool isActive;

  QualityStandardModel({
    required this.id,
    required this.name,
    required this.minFat,
    required this.maxFat,
    required this.minSnf,
    required this.maxSnf,
    required this.minClr,
    required this.maxClr,
    required this.minTemperature,
    required this.maxTemperature,
    required this.maxWaterContent,
    this.isActive = true,
  });

  bool meetsStandard(QualityTestModel test) {
    return test.fatPercentage >= minFat &&
           test.fatPercentage <= maxFat &&
           test.snfPercentage >= minSnf &&
           test.snfPercentage <= maxSnf &&
           test.clr >= minClr &&
           test.clr <= maxClr &&
           test.temperature >= minTemperature &&
           test.temperature <= maxTemperature &&
           (test.waterPercentage ?? 0) <= maxWaterContent;
  }
}
