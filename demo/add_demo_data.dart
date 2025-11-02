// Demo data script - Run this to see test data instructions
// Run: dart demo/add_demo_data.dart

void main() {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║          DEMO DATA FOR TESTING                             ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');
  print('Add these farmers and milk collections manually in your app.');
  print('');
  
  print('═══════════════════════════════════════════════════════════');
  print('STEP 1: ADD 10 DEMO FARMERS');
  print('═══════════════════════════════════════════════════════════');
  print('Go to: Home > Add Farmer button');
  print('');
  
  final farmers = [
    ['Rajesh Kumar', 'Rampur', '9876543210', 'Cow'],
    ['Suresh Patel', 'Shivpur', '9876543211', 'Buffalo'],
    ['Mahesh Singh', 'Ganeshpur', '9876543212', 'Both'],
    ['Dinesh Verma', 'Haripur', '9876543213', 'Cow'],
    ['Ganesh Sharma', 'Govindpur', '9876543214', 'Buffalo'],
    ['Vijay Yadav', 'Mohanpur', '9876543215', 'Both'],
    ['Ajay Reddy', 'Krishna Nagar', '9876543216', 'Cow'],
    ['Sanjay Nair', 'Ram Nagar', '9876543217', 'Buffalo'],
    ['Manoj Desai', 'Laxmi Nagar', '9876543218', 'Both'],
    ['Anil Joshi', 'Durga Nagar', '9876543219', 'Cow'],
  ];
  
  for (var i = 0; i < farmers.length; i++) {
    print('${i + 1}. Name: ${farmers[i][0]}');
    print('   Village: ${farmers[i][1]}');
    print('   Phone: ${farmers[i][2]}');
    print('   Milk Type: ${farmers[i][3]}');
    print('');
  }
  
  print('═══════════════════════════════════════════════════════════');
  print('STEP 2: ADD 10 MILK COLLECTIONS');
  print('═══════════════════════════════════════════════════════════');
  print('Go to: Home > Add Milk Collection button');
  print('');
  
  final collections = [
    ['Rajesh Kumar', 'Morning', '10.5', '4.5', '8.5'],
    ['Rajesh Kumar', 'Evening', '12.0', '4.2', '8.3'],
    ['Suresh Patel', 'Morning', '15.5', '6.5', '9.0'],
    ['Suresh Patel', 'Evening', '14.0', '6.8', '9.2'],
    ['Mahesh Singh', 'Morning', '8.0', '5.0', '8.7'],
    ['Dinesh Verma', 'Morning', '9.5', '4.3', '8.4'],
    ['Ganesh Sharma', 'Evening', '16.0', '7.0', '9.3'],
    ['Vijay Yadav', 'Morning', '11.0', '5.5', '8.8'],
    ['Ajay Reddy', 'Evening', '10.0', '4.4', '8.5'],
    ['Sanjay Nair', 'Morning', '13.5', '6.2', '8.9'],
  ];
  
  for (var i = 0; i < collections.length; i++) {
    print('${i + 1}. Farmer: ${collections[i][0]}');
    print('   Shift: ${collections[i][1]}');
    print('   Quantity: ${collections[i][2]} Liters');
    print('   FAT: ${collections[i][3]}%, SNF: ${collections[i][4]}%');
    print('');
  }
  
  print('═══════════════════════════════════════════════════════════');
  print('WHAT TO TEST');
  print('═══════════════════════════════════════════════════════════');
  print('✓ Farmer list and search functionality');
  print('✓ Milk collection list with date filters');
  print('✓ Smart placeholders (add same farmer twice)');
  print('✓ Responsive UI on mobile/tablet/desktop');
  print('✓ No duplicate headers issue');
  print('✓ Calculations and totals accuracy');
  print('');
  
  print('═══════════════════════════════════════════════════════════');
  print('TO REMOVE DEMO FOLDER');
  print('═══════════════════════════════════════════════════════════');
  print('Simply delete the folder - no errors will occur:');
  print('  rm -rf demo/');
  print('');
  print('The app will continue working perfectly!');
  print('');
}
