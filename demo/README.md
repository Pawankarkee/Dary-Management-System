# Demo Data for Testing

This folder contains demo/test data instructions for the Dairify app.

## Quick Start

Run the demo script to see test data:
```bash
dart demo/add_demo_data.dart
```

This will show you a list of 10 farmers and 10 milk collections to add manually.

## What's Included

### 10 Demo Farmers
- Rajesh Kumar (Rampur, Cow)
- Suresh Patel (Shivpur, Buffalo)
- Mahesh Singh (Ganeshpur, Both)
- Dinesh Verma (Haripur, Cow)
- Ganesh Sharma (Govindpur, Buffalo)
- Vijay Yadav (Mohanpur, Both)
- Ajay Reddy (Krishna Nagar, Cow)
- Sanjay Nair (Ram Nagar, Buffalo)
- Manoj Desai (Laxmi Nagar, Both)
- Anil Joshi (Durga Nagar, Cow)

### 10 Demo Milk Collections
Sample collections for morning and evening shifts with realistic FAT/SNF values.

## How to Use

1. **Run the script**:
   ```bash
   dart demo/add_demo_data.dart
   ```

2. **Follow the instructions** shown in the output

3. **Add farmers** using the app's "Add Farmer" screen

4. **Add collections** using the app's "Add Milk Collection" screen

## Testing Checklist

- [ ] Farmer list displays correctly
- [ ] Search and filter works
- [ ] Milk collection list shows data
- [ ] Date filters work
- [ ] Smart placeholders appear for repeat farmers
- [ ] Calculations are accurate
- [ ] Responsive UI works on different screens
- [ ] No duplicate headers issue

## Remove Demo Data

When you're done testing:

```bash
rm -rf demo/
```

**The app will continue working normally without any errors.**

## Note

This is a **standalone folder**. Deleting it will NOT affect your app functionality.
The demo/ folder is completely independent from the main app code.
