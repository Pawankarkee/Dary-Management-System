import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../controllers/milk_controller.dart';
import '../../../controllers/farmer_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../../models/milk_collection_model.dart';
import '../../../models/farmer_model.dart';
import '../../../utils/formatters.dart';
import '../../../utils/form_helpers.dart';
import '../../../utils/responsive.dart';

class AddMilkCollectionScreen extends StatefulWidget {
  final MilkCollectionModel? collection;
  
  const AddMilkCollectionScreen({super.key, this.collection});
  
  @override
  State<AddMilkCollectionScreen> createState() => _AddMilkCollectionScreenState();
}

class _AddMilkCollectionScreenState extends State<AddMilkCollectionScreen>
    with FormFocusManagement {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();
  final _farmerSearchController = TextEditingController();
  final LayerLink _farmerFieldLink = LayerLink();
  final GlobalKey _farmerFieldKey = GlobalKey();
  final ScrollController _farmerDropdownScrollController = ScrollController();

  String? _selectedFarmerId;
  Shift _selectedShift = Shift.morning;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _calculatedRate = 0.0;
  double _calculatedAmount = 0.0;
  bool _isLoading = false;

  OverlayEntry? _farmerDropdownOverlay;
  Timer? _farmerSearchDebounce;
  bool _isFarmerDropdownOpen = false;
  bool _suppressFarmerSearchNotification = false;
  String _farmerSearchQuery = '';
  Size _farmerFieldSize = Size.zero;
  int _highlightedFarmerIndex = -1;
  bool _isPointerInsideDropdown = false;

  List<FarmerModel> _activeFarmers = [];
  List<FarmerModel> _filteredFarmers = [];
  FarmerModel? _selectedFarmer;

  double? _previousQuantity;
  double? _previousRate;
  double? _previousFAT;
  double? _previousSNF;
  String _quantityPlaceholder = 'Enter quantity';
  String _ratePlaceholder = 'Enter rate per liter';
  String? _fatPlaceholder;
  String? _snfPlaceholder;

  @override
  void initState() {
    super.initState();
    initializeFocusNodes(5);
    _loadFarmers(notifyListeners: false);

  getFocusNode(0).addListener(_handleFarmerFocusChange);
  HardwareKeyboard.instance.addHandler(_handleHardwareKeyEvent);

    _quantityController.addListener(_calculateAmount);
    _rateController.addListener(_calculateAmount);
    _fatController.addListener(_calculateAmount);
    _snfController.addListener(_calculateAmount);

    if (widget.collection != null) {
      final collection = widget.collection!;
      _selectedFarmerId = collection.farmerId;
      _quantityController.text = collection.quantity.toString();
      _rateController.text = collection.ratePerLiter.toString();
      _fatController.text = collection.fat.toString();
      _snfController.text = collection.snf.toString();
      _selectedShift = collection.shift;
      _selectedDate = collection.date;
      _selectedTime = TimeOfDay.fromDateTime(collection.date);
      _calculatedRate = collection.ratePerLiter;
      _calculatedAmount = collection.totalAmount;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadPreviousEntry(collection.farmerId);
        }
      });
    } else {
      _selectedShift = _detectShift();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
  getFocusNode(0).removeListener(_handleFarmerFocusChange);
  HardwareKeyboard.instance.removeHandler(_handleHardwareKeyEvent);
    _farmerSearchDebounce?.cancel();
    _hideFarmerDropdown(triggerSetState: false);

    _quantityController.removeListener(_calculateAmount);
    _rateController.removeListener(_calculateAmount);
    _fatController.removeListener(_calculateAmount);
    _snfController.removeListener(_calculateAmount);

    _quantityController.dispose();
    _rateController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _farmerSearchController.dispose();
    _farmerDropdownScrollController.dispose();

    super.dispose();
  }

  Shift _detectShift() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return Shift.morning;
    }
    return Shift.evening;
  }

  void _loadFarmers({bool notifyListeners = true}) {
    final farmerController = Provider.of<FarmerController>(context, listen: false);
    final farmers = farmerController
        .getAllFarmers()
        .where((farmer) => farmer.isActive)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    void assign() {
      _activeFarmers = farmers;
      _filteredFarmers = List<FarmerModel>.from(farmers);

      if (widget.collection != null) {
        FarmerModel? match;
        try {
          match = farmers.firstWhere((farmer) => farmer.id == widget.collection!.farmerId);
        } catch (_) {
          match = null;
        }

        _selectedFarmer = match;
        if (_selectedFarmer != null) {
          _selectedFarmerId = _selectedFarmer!.id;
          _suppressFarmerSearchNotification = true;
          _farmerSearchController.text = '${_selectedFarmer!.name} (${_selectedFarmer!.id})';
          _farmerSearchQuery = _farmerSearchController.text;
        }
      }

      if (_farmerSearchQuery.isEmpty) {
        _highlightedFarmerIndex = _filteredFarmers.isEmpty ? -1 : 0;
      }
    }

    if (!notifyListeners) {
      assign();
      _updateFilteredFarmers(notifyListeners: false);
    } else if (mounted) {
      setState(() {
        assign();
        _updateFilteredFarmers(notifyListeners: false);
      });
    }
  }

  void _handleFarmerFocusChange() {
    if (!mounted) return;

    if (getFocusNode(0).hasFocus) {
      _showFarmerDropdown(forceOpen: true);
      if (_farmerSearchQuery.isNotEmpty) {
        _updateFilteredFarmers(notifyListeners: false);
      }
    } else if (!_isPointerInsideDropdown) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        if (!getFocusNode(0).hasFocus && !_isPointerInsideDropdown) {
          _hideFarmerDropdown();
        }
      });
    }
  }

  bool _handleHardwareKeyEvent(KeyEvent event) {
    if (!mounted || !_isFarmerDropdownOpen) return false;
    if (event is! KeyDownEvent) return false;
    if (!getFocusNode(0).hasFocus) return false;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _highlightNextFarmer();
      return true;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _highlightPreviousFarmer();
      return true;
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      _commitHighlightedFarmer();
      return true;
    } else if (key == LogicalKeyboardKey.escape) {
      _hideFarmerDropdown();
      return true;
    }

    return false;
  }

  void _handleFarmerSearchChanged(String value, {bool fromUserInput = true}) {
    if (!mounted) return;
    if (_suppressFarmerSearchNotification) {
      _suppressFarmerSearchNotification = false;
      return;
    }

    _farmerSearchQuery = value.trim();

    _farmerSearchDebounce?.cancel();
    _farmerSearchDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _updateFilteredFarmers();

      if (fromUserInput || !_isFarmerDropdownOpen) {
        _showFarmerDropdown();
      } else {
        _farmerDropdownOverlay?.markNeedsBuild();
      }
    });
  }

  void _updateFilteredFarmers({bool notifyListeners = true}) {
    final query = _farmerSearchQuery.toLowerCase();

    List<FarmerModel> results;
    if (query.isEmpty) {
      results = List<FarmerModel>.from(_activeFarmers);
    } else {
      results = _activeFarmers.where((farmer) {
        final name = farmer.name.toLowerCase();
        final id = farmer.id.toLowerCase();
        final phone = farmer.phone?.toLowerCase() ?? '';
        return name.contains(query) || id.contains(query) || phone.contains(query);
      }).toList();
    }

    void assign() {
      _filteredFarmers = results;
      _highlightedFarmerIndex = results.isEmpty ? -1 : 0;
    }

    if (!notifyListeners) {
      assign();
    } else if (mounted) {
      setState(assign);
    }

    _farmerDropdownOverlay?.markNeedsBuild();
  }

  void _showFarmerDropdown({bool forceOpen = false}) {
    if (!mounted || widget.collection != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
  final overlay = Overlay.of(context, rootOverlay: true);

      final renderBox = _farmerFieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _farmerFieldSize = renderBox.size;
      }

      if (_farmerDropdownOverlay == null) {
        _farmerDropdownOverlay = OverlayEntry(
          builder: (context) => _buildFarmerDropdownOverlay(context),
        );
        overlay.insert(_farmerDropdownOverlay!);
      } else {
        _farmerDropdownOverlay!.markNeedsBuild();
      }

      if (!_isFarmerDropdownOpen || forceOpen) {
        setState(() {
          _isFarmerDropdownOpen = true;
        });
      }
    });
  }

  void _hideFarmerDropdown({bool triggerSetState = true}) {
    _farmerSearchDebounce?.cancel();

    final overlayEntry = _farmerDropdownOverlay;
    if (overlayEntry != null) {
      overlayEntry.remove();
      _farmerDropdownOverlay = null;
    }
    _isPointerInsideDropdown = false;

    if (triggerSetState && mounted && _isFarmerDropdownOpen) {
      setState(() {
        _isFarmerDropdownOpen = false;
        _highlightedFarmerIndex = _filteredFarmers.isEmpty ? -1 : 0;
      });
    } else {
      _isFarmerDropdownOpen = false;
      _highlightedFarmerIndex = _filteredFarmers.isEmpty ? -1 : 0;
    }
  }

  Widget _buildFarmerDropdownOverlay(BuildContext overlayContext) {
    final theme = Theme.of(overlayContext);
    final mediaSize = MediaQuery.of(overlayContext).size;

    final renderBox = _farmerFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final fieldSize = renderBox?.size ?? _farmerFieldSize;
    final fieldOffset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    final availableHeight = math.max(
      160.0,
      mediaSize.height - fieldOffset.dy - fieldSize.height - 24.0,
    );
    final dropdownMaxHeight = math.min(availableHeight, 360.0);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _hideFarmerDropdown,
            onPanDown: (_) => _hideFarmerDropdown(),
          ),
        ),
        CompositedTransformFollower(
          link: _farmerFieldLink,
          showWhenUnlinked: false,
          offset: Offset(0, fieldSize.height + 6),
          child: MouseRegion(
            onEnter: (_) => _isPointerInsideDropdown = true,
            onExit: (_) {
              _isPointerInsideDropdown = false;
              if (!getFocusNode(0).hasFocus) {
                Future.delayed(const Duration(milliseconds: 120), () {
                  if (!mounted) return;
                  if (!_isPointerInsideDropdown && !getFocusNode(0).hasFocus) {
                    _hideFarmerDropdown();
                  }
                });
              }
            },
            child: SizedBox(
              width: fieldSize.width == 0 ? 360 : fieldSize.width,
              child: _buildFarmerDropdownBody(theme, dropdownMaxHeight),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildFarmerDropdownBody(ThemeData theme, double maxHeight) {
    final hasFarmers = _filteredFarmers.isNotEmpty;
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 12,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surface,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            minHeight: hasFarmers ? 120 : 140,
          ),
          child: hasFarmers
              ? _buildFarmerResultsList(theme)
              : _buildFarmerEmptyState(theme),
        ),
      ),
    );
  }

  Widget _buildFarmerResultsList(ThemeData theme) {
    final dividerColor = theme.dividerColor.withOpacity(
      theme.brightness == Brightness.dark ? 0.25 : 0.12,
    );

    return ListView.separated(
      controller: _farmerDropdownScrollController,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _filteredFarmers.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
      itemBuilder: (context, index) {
        final farmer = _filteredFarmers[index];
        final isHighlighted = index == _highlightedFarmerIndex;
        return InkWell(
          onTap: () => _selectFarmer(farmer),
          child: Container(
            color: isHighlighted
                ? theme.colorScheme.primary.withOpacity(
                    theme.brightness == Brightness.dark ? 0.18 : 0.12,
                  )
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: _buildFarmerOptionRow(theme, farmer, isHighlighted),
          ),
        );
      },
    );
  }

  Widget _buildFarmerOptionRow(ThemeData theme, FarmerModel farmer, bool isHighlighted) {
    final query = _farmerSearchQuery;
    final highlightStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w700,
    );
    final defaultStyle = theme.textTheme.bodyMedium;
    final secondaryStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
    );

    final subtitleParts = <String>[
      'ID: ${farmer.id}',
      if (farmer.phone != null && farmer.phone!.trim().isNotEmpty) farmer.phone!.trim(),
      if (farmer.village != null && farmer.village!.trim().isNotEmpty)
        farmer.village!.trim(),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
          child: Text(
            farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: _buildHighlightedTextSpan(
                  farmer.name,
                  query,
                  defaultStyle,
                  highlightStyle,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              RichText(
                text: _buildHighlightedTextSpan(
                  subtitleParts.join(' • '),
                  query,
                  secondaryStyle,
                  highlightStyle,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.keyboard_arrow_right,
          color: isHighlighted
              ? theme.colorScheme.primary
              : theme.iconTheme.color?.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildFarmerEmptyState(ThemeData theme) {
    final message = _farmerSearchQuery.isEmpty
        ? 'Start typing to search farmers'
        : 'No farmer found. Add new?';
    final color = theme.textTheme.bodySmall?.color?.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _farmerSearchQuery.isEmpty ? Icons.search : Icons.person_add_alt,
            size: 48,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (_farmerSearchQuery.isNotEmpty)
            FilledButton.icon(
              onPressed: _navigateToAddFarmer,
              icon: const Icon(Icons.add),
              label: const Text('Add Farmer'),
            ),
        ],
      ),
    );
  }

  TextSpan _buildHighlightedTextSpan(
    String source,
    String query,
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  ) {
    if (query.isEmpty) {
      return TextSpan(text: source, style: normalStyle);
    }

    final lowerSource = source.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerSource.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: source.substring(start), style: normalStyle));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: source.substring(start, index),
          style: normalStyle,
        ));
      }

      spans.add(TextSpan(
        text: source.substring(index, index + query.length),
        style: highlightStyle,
      ));
      start = index + query.length;
    }

    return TextSpan(children: spans);
  }

  void _highlightNextFarmer() {
    if (_filteredFarmers.isEmpty) return;
    setState(() {
      if (_highlightedFarmerIndex >= _filteredFarmers.length - 1) {
        _highlightedFarmerIndex = 0;
      } else {
        _highlightedFarmerIndex += 1;
      }
    });
    _scrollHighlightedFarmerIntoView();
  }

  void _highlightPreviousFarmer() {
    if (_filteredFarmers.isEmpty) return;
    setState(() {
      if (_highlightedFarmerIndex <= 0) {
        _highlightedFarmerIndex = _filteredFarmers.length - 1;
      } else {
        _highlightedFarmerIndex -= 1;
      }
    });
    _scrollHighlightedFarmerIntoView();
  }

  void _scrollHighlightedFarmerIntoView() {
    if (_highlightedFarmerIndex < 0) return;
    if (!_farmerDropdownScrollController.hasClients) return;
    const itemExtent = 64.0;
    final targetOffset = _highlightedFarmerIndex * itemExtent;
    final maxOffset = _farmerDropdownScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxOffset).toDouble();
    _farmerDropdownScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
    );
  }

  void _commitHighlightedFarmer() {
    if (_highlightedFarmerIndex < 0 || _highlightedFarmerIndex >= _filteredFarmers.length) {
      return;
    }
    _selectFarmer(_filteredFarmers[_highlightedFarmerIndex]);
  }

  void _resetFarmerSelection() {
    setState(() {
      _selectedFarmer = null;
      _selectedFarmerId = null;
      _suppressFarmerSearchNotification = true;
      _farmerSearchController.clear();
      _farmerSearchQuery = '';
      _filteredFarmers = List<FarmerModel>.from(_activeFarmers);
      _highlightedFarmerIndex = _filteredFarmers.isEmpty ? -1 : 0;
      _resetPreviousEntryPlaceholders();
    });
    _hideFarmerDropdown();
    getFocusNode(0).requestFocus();
  }

  void _resetPreviousEntryPlaceholders() {
    _previousQuantity = null;
    _previousRate = null;
    _previousFAT = null;
    _previousSNF = null;
    _quantityPlaceholder = 'Enter quantity';
    _ratePlaceholder = 'Enter rate per liter';
    _fatPlaceholder = null;
    _snfPlaceholder = null;
  }

  Future<void> _navigateToAddFarmer() async {
    _hideFarmerDropdown();
    await Navigator.pushNamed(context, AppRouter.addFarmer);
    if (!mounted) return;
    _loadFarmers();
    getFocusNode(0).requestFocus();
    _showFarmerDropdown(forceOpen: true);
  }

  void _selectFarmer(FarmerModel farmer) async {
    _hideFarmerDropdown();
    setState(() {
      _selectedFarmer = farmer;
      _selectedFarmerId = farmer.id;
      _suppressFarmerSearchNotification = true;
      _farmerSearchController.text = '${farmer.name} (${farmer.id})';
      _farmerSearchQuery = _farmerSearchController.text;
      _filteredFarmers = _activeFarmers;
      _highlightedFarmerIndex = _filteredFarmers.isEmpty ? -1 : 0;
    });
    // Move focus to quantity field for faster entry
    FormFieldHelper.moveToNextField(context, getNextFocusNode(0));
    
    await _loadPreviousEntry(farmer.id);
  }
  
  // Load the last milk entry for this farmer to populate placeholders
  Future<void> _loadPreviousEntry(String farmerId) async {
    final milkController = Provider.of<MilkController>(context, listen: false);
    final collections = milkController.collections;
    
    // Find last entry for this farmer
    final previousEntries = collections
        .where((c) => c.farmerId == farmerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    
    if (previousEntries.isNotEmpty) {
      final lastEntry = previousEntries.first;
      setState(() {
        _previousQuantity = lastEntry.quantity;
        _previousRate = lastEntry.ratePerLiter;
        _previousFAT = lastEntry.fat;
        _previousSNF = lastEntry.snf;
        
        // Set placeholders with previous values
        _quantityPlaceholder = 'Last: ${lastEntry.quantity.toStringAsFixed(1)} L';
        _ratePlaceholder = 'Last: रु ${lastEntry.ratePerLiter.toStringAsFixed(1)}/L';
        _fatPlaceholder = lastEntry.fat > 0 ? 'Last: ${lastEntry.fat.toStringAsFixed(1)}%' : null;
        _snfPlaceholder = lastEntry.snf > 0 ? 'Last: ${lastEntry.snf.toStringAsFixed(1)}%' : null;
      });
    } else {
      // First time entry for this farmer
      setState(() {
        _previousQuantity = null;
        _previousRate = null;
        _previousFAT = null;
        _previousSNF = null;
        _quantityPlaceholder = 'Enter quantity';
        _ratePlaceholder = 'Enter rate per liter';
        _fatPlaceholder = null;
        _snfPlaceholder = null;
      });
    }
  }

  void _calculateAmount() {
    // Use manual rate from rate field, or use placeholder if empty
    final quantity = double.tryParse(_quantityController.text) ?? 
                    _previousQuantity ?? 
                    0.0;
    final rate = double.tryParse(_rateController.text) ?? 
                _previousRate ?? 
                0.0;

    if (quantity > 0 && rate > 0) {
      _calculatedAmount = quantity * rate;
      setState(() {});
    }
  }

  Future<void> _saveCollection({bool confirmDuplicate = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFarmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farmer')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final milkController = Provider.of<MilkController>(context, listen: false);
      final authController = Provider.of<AuthController>(context, listen: false);
      final farmerController = Provider.of<FarmerController>(context, listen: false);
      final transactionController = Provider.of<TransactionController>(context, listen: false);
      
      final collectionDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Parse FAT and SNF with defaults if empty (since they're now optional)
      // Use placeholder values if field is empty
      final fat = _fatController.text.trim().isEmpty 
          ? (_previousFAT ?? 0.0)  // Use placeholder if available
          : double.parse(_fatController.text);
      final snf = _snfController.text.trim().isEmpty 
          ? (_previousSNF ?? 0.0)  // Use placeholder if available
          : double.parse(_snfController.text);
      
      // Parse Quantity - use placeholder if empty
      final quantity = _quantityController.text.trim().isEmpty
          ? _previousQuantity  // Use placeholder value
          : double.tryParse(_quantityController.text);
      
      if (quantity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter quantity')),
        );
        setState(() => _isLoading = false);
        return;
      }
      
      // Parse Rate - use placeholder if empty
      final rate = _rateController.text.trim().isEmpty
          ? _previousRate  // Use placeholder value
          : double.tryParse(_rateController.text);
      
      if (rate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter rate')),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (widget.collection != null) {
        // TODO: Implement update collection
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update feature coming soon!')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Check for duplicate entry BEFORE adding (only if not already confirmed)
      if (!confirmDuplicate) {
        final isDuplicate = await milkController.isDuplicateEntry(
          farmerId: _selectedFarmerId!,
          date: collectionDateTime,
          shift: _selectedShift,
        );

        if (isDuplicate && mounted) {
          setState(() => _isLoading = false);
          
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Text('Duplicate Entry Detected'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Milk entry for this farmer already exists:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farmer: ${_selectedFarmer?.name ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('Farmer ID: $_selectedFarmerId'),
                        Text('Date: ${AppFormatters.date(collectionDateTime)}'),
                        Text('Shift: ${_selectedShift == Shift.morning ? 'Morning' : 'Evening'}'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'Do you want to add another entry for this farmer?',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Yes, Add Anyway'),
                ),
              ],
            ),
          );

          if (confirmed != true) {
            // User cancelled, don't save
            return;
          }
          
          // User confirmed, proceed with saving (recursive call with confirmation flag)
          setState(() => _isLoading = true);
          await _saveCollection(confirmDuplicate: true);
          return;
        }
      }

      // Add new collection with RATE field
      final success = await milkController.addMilkCollection(
        farmerId: _selectedFarmerId!,
        date: collectionDateTime,
        shift: _selectedShift,
        quantity: quantity,  // Use parsed or placeholder value
        fat: fat,
        snf: snf,
        collectorId: authController.currentUser?.id ?? 'unknown',
        farmerController: farmerController,
        transactionController: transactionController,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save collection. Please try again.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  widget.collection != null
                      ? 'Collection updated successfully!'
                      : 'Saved Successfully!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Reset form for next entry (if adding new)
        if (widget.collection == null) {
          _resetFarmerSelection();
          setState(() {
            // Clear all fields
            _quantityController.clear();
            _rateController.clear(); // Clear rate - no autofill
            _fatController.clear();
            _snfController.clear();
            
            // Re-detect shift and update time for next entry
            _selectedShift = _detectShift();
            _selectedDate = DateTime.now();
            _selectedTime = TimeOfDay.now();
            
            // Reset calculations
            _calculatedRate = 0.0;
            _calculatedAmount = 0.0;
          });
          _showFarmerDropdown(forceOpen: true);
          
          // Focus back to first field for quick next entry
          getFocusNode(0).requestFocus();
        } else {
          // If editing, go back to previous screen
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving collection: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.collection != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = MobileSizes.isMobile(screenWidth);
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive padding using MobileSizes
    final horizontalPadding = isMobile ? MobileSizes.spaceXL : (isTablet ? 24.0 : 32.0);
    final verticalPadding = isMobile ? MobileSizes.spaceL : (isTablet ? 20.0 : 24.0);
    final fieldSpacing = isMobile ? MobileSizes.spaceM : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Collection' : 'Add Collection',
          style: TextStyle(
            fontSize: isMobile ? MobileSizes.screenTitle : 20.0,
          ),
        ),
        iconTheme: IconThemeData(
          size: isMobile ? MobileSizes.iconAppBar : 24.0,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : double.infinity,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              children: [
            // Farmer Search Field with smart navigation (Field 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompositedTransformTarget(
                  key: _farmerFieldKey,
                  link: _farmerFieldLink,
                  child: FocusScope(
                    child: FormFieldHelper.buildTextField(
                      controller: _farmerSearchController,
                      focusNode: getFocusNode(0),
                      nextFocusNode: getNextFocusNode(0),
                      readOnly: isEdit,
                      autofocus: !isEdit,
                      onChanged: (value) => _handleFarmerSearchChanged(value, fromUserInput: true),
                      decoration: InputDecoration(
                        labelText: 'Search Farmer *',
                        labelStyle: TextStyle(
                          fontSize: isMobile ? MobileSizes.label : 14.0,
                        ),
                        hintText: 'Start typing farmer name, ID, or phone',
                        hintStyle: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodySmall : 14.0,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: isMobile ? MobileSizes.iconMedium : 24.0,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? MobileSizes.fieldPaddingH : 16.0,
                          vertical: isMobile ? MobileSizes.fieldPaddingV : 12.0,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectedFarmer != null)
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: isMobile ? MobileSizes.iconSmall : 20.0,
                                ),
                                tooltip: 'Clear selection',
                                onPressed: isEdit
                                    ? null
                                    : () {
                                        _resetFarmerSelection();
                                      },
                              ),
                            IconButton(
                              icon: Icon(
                                _isFarmerDropdownOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: isMobile ? MobileSizes.iconMedium : 24.0,
                              ),
                              tooltip: 'Show farmer suggestions',
                              onPressed: isEdit
                                  ? null
                                  : () {
                                      if (_isFarmerDropdownOpen) {
                                        _hideFarmerDropdown();
                                      } else {
                                        _showFarmerDropdown(forceOpen: true);
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                      validator: (value) {
                        if (_selectedFarmer == null) {
                          return 'Please select a farmer';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                
                if (_selectedFarmer != null)
                  Container(
                    margin: EdgeInsets.only(top: isMobile ? MobileSizes.spaceS : 8),
                    padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        isMobile ? MobileSizes.borderRadius : AppTheme.radiusSmall,
                      ),
                      border: Border.all(
                        color: AppTheme.successColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                          size: isMobile ? MobileSizes.iconMedium : 20.0,
                        ),
                        SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFarmer!.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                                ),
                              ),
                              Text(
                                '${_selectedFarmer!.id} • ${_selectedFarmer!.phone ?? "No phone"}',
                                style: TextStyle(
                                  fontSize: isMobile ? MobileSizes.caption : 12.0,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            SizedBox(height: fieldSpacing),

            // Shift Selection (Morning/Evening)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift *',
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.label : 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: isMobile ? MobileSizes.spaceXS : 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<Shift>(
                        dense: isMobile,
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny,
                              size: isMobile ? MobileSizes.iconMedium : 20.0,
                              color: _selectedShift == Shift.morning 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey,
                            ),
                            SizedBox(width: isMobile ? MobileSizes.spaceXS : 6),
                            Text(
                              'Morning',
                              style: TextStyle(
                                fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                              ),
                            ),
                          ],
                        ),
                        value: Shift.morning,
                        groupValue: _selectedShift,
                        onChanged: (value) {
                          setState(() => _selectedShift = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<Shift>(
                        dense: isMobile,
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.nightlight_round,
                              size: isMobile ? MobileSizes.iconMedium : 20.0,
                              color: _selectedShift == Shift.evening 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey,
                            ),
                            SizedBox(width: isMobile ? MobileSizes.spaceXS : 6),
                            Text(
                              'Evening',
                              style: TextStyle(
                                fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                              ),
                            ),
                          ],
                        ),
                        value: Shift.evening,
                        groupValue: _selectedShift,
                        onChanged: (value) {
                          setState(() => _selectedShift = value!);
                        },
                      ),
                    ),
                  ],
                ),
                // Auto-detected helper text
                Padding(
                  padding: EdgeInsets.only(
                    left: isMobile ? MobileSizes.spaceM : 12.0,
                    top: isMobile ? MobileSizes.spaceXS : 4.0,
                  ),
                  child: Text(
                    'Auto-detected based on current time',
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.caption : 11.0,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: fieldSpacing),

            // SECTION: Quantity & Rate Fields
            // Milk Details Section Title
            Row(
              children: [
                Icon(
                  Icons.water_drop,
                  color: AppTheme.primaryColor,
                  size: isMobile ? MobileSizes.iconMedium : 20.0,
                ),
                SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                Text(
                  'Milk Details',
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.sectionTitle : 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: fieldSpacing),

            // Quantity Field (with smart placeholder)
            TextField(
              controller: _quantityController,
              focusNode: getFocusNode(1),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
              ),
              decoration: InputDecoration(
                labelText: 'Quantity (Liters) *',
                labelStyle: TextStyle(
                  fontSize: isMobile ? MobileSizes.label : 14.0,
                ),
                hintText: _quantityPlaceholder,  // Smart placeholder: "Last: 18.5 L"
                hintStyle: TextStyle(
                  color: _previousQuantity != null ? Colors.blue.shade600 : Colors.grey,
                  fontStyle: _previousQuantity != null ? FontStyle.italic : FontStyle.normal,
                  fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                ),
                prefixIcon: Icon(
                  Icons.water_drop_outlined,
                  size: isMobile ? MobileSizes.iconMedium : 22.0,
                ),
                suffixIcon: _previousQuantity != null && _quantityController.text.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Auto',
                            style: TextStyle(
                              fontSize: isMobile ? 9 : 10,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? MobileSizes.fieldPaddingH : 16.0,
                  vertical: isMobile ? MobileSizes.fieldPaddingV : 12.0,
                ),
              ),
              onSubmitted: (_) {
                // Auto-fill if empty
                if (_quantityController.text.isEmpty && _previousQuantity != null) {
                  _quantityController.text = _previousQuantity.toString();
                }
                FocusScope.of(context).requestFocus(getFocusNode(2));
              },
            ),

            SizedBox(height: fieldSpacing),

            // Rate Field (with smart placeholder)
            TextField(
              controller: _rateController,
              focusNode: getFocusNode(2),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
              ),
              decoration: InputDecoration(
                labelText: 'Rate (रु/Liter) *',
                labelStyle: TextStyle(
                  fontSize: isMobile ? MobileSizes.label : 14.0,
                ),
                hintText: _ratePlaceholder,  // Smart placeholder: "Last: रु 65/L"
                hintStyle: TextStyle(
                  color: _previousRate != null ? Colors.blue.shade600 : Colors.grey,
                  fontStyle: _previousRate != null ? FontStyle.italic : FontStyle.normal,
                  fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                ),
                prefix: Text(
                  'रु ',
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.currency_rupee,
                  size: isMobile ? MobileSizes.iconMedium : 22.0,
                ),
                suffixIcon: _previousRate != null && _rateController.text.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Auto',
                            style: TextStyle(
                              fontSize: isMobile ? 9 : 10,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? MobileSizes.fieldPaddingH : 16.0,
                  vertical: isMobile ? MobileSizes.fieldPaddingV : 12.0,
                ),
              ),
              onSubmitted: (_) {
                // Auto-fill if empty
                if (_rateController.text.isEmpty && _previousRate != null) {
                  _rateController.text = _previousRate.toString();
                }
                // Move focus to next section or save
                FocusScope.of(context).unfocus();
              },
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // COLLAPSIBLE SECTION: Date & Time
            Card(
              elevation: isMobile ? MobileSizes.cardElevation : 1,
              margin: EdgeInsets.zero,
              child: ExpansionTile(
                tilePadding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 12),
                childrenPadding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 12),
                initiallyExpanded: false,  // Collapsed by default
                title: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: isMobile ? MobileSizes.iconMedium : 20.0,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                    Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(top: isMobile ? MobileSizes.spaceXS : 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: isMobile ? 10 : 12,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Auto-captured from device',
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.caption : 11.0,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
                children: [
                  // Date Picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                          ),
                          hintText: AppFormatters.date(_selectedDate),
                          hintStyle: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                          ),
                          prefixIcon: Icon(
                            Icons.today,
                            size: isMobile ? MobileSizes.iconMedium : 20.0,
                          ),
                          suffixIcon: Icon(
                            Icons.edit,
                            size: isMobile ? MobileSizes.iconSmall : 16.0,
                            color: Colors.grey.shade600,
                          ),
                          helperText: 'Tap to change if needed',
                          helperStyle: TextStyle(
                            fontSize: isMobile ? MobileSizes.caption : 10.0,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? MobileSizes.fieldPaddingH : 16.0,
                            vertical: isMobile ? MobileSizes.fieldPaddingV : 12.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
                  // Time Picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Time',
                          labelStyle: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                          ),
                          hintText: _selectedTime.format(context),
                          hintStyle: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                          ),
                          prefixIcon: Icon(
                            Icons.access_time,
                            size: isMobile ? MobileSizes.iconMedium : 20.0,
                          ),
                          suffixIcon: Icon(
                            Icons.edit,
                            size: isMobile ? MobileSizes.iconSmall : 16.0,
                            color: Colors.grey.shade600,
                          ),
                          helperText: 'Tap to change',
                          helperStyle: TextStyle(
                            fontSize: isMobile ? MobileSizes.caption : 10.0,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? MobileSizes.fieldPaddingH : 16.0,
                            vertical: isMobile ? MobileSizes.fieldPaddingV : 12.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: fieldSpacing),

            // COLLAPSIBLE SECTION: Quality Parameters (FAT & SNF)
            Card(
              elevation: isMobile ? MobileSizes.cardElevation : 1,
              margin: EdgeInsets.zero,
              child: ExpansionTile(
                tilePadding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 12),
                childrenPadding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 12),
                initiallyExpanded: false,  // Collapsed by default
                title: Row(
                  children: [
                    Icon(
                      Icons.science,
                      size: isMobile ? MobileSizes.iconMedium : 20.0,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                    Text(
                      'Quality Parameters',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(top: isMobile ? MobileSizes.spaceXS : 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Optional - for quality tracking',
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.caption : 11.0,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                children: [
                  // FAT Field
                  TextField(
                    controller: _fatController,
                    focusNode: getFocusNode(3),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                    ),
                    decoration: InputDecoration(
                      labelText: 'FAT (%)',
                      labelStyle: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                      ),
                      hintText: _fatPlaceholder ?? 'Enter FAT value',
                      hintStyle: TextStyle(
                        color: _previousFAT != null ? Colors.blue.shade600 : Colors.grey,
                        fontStyle: _previousFAT != null ? FontStyle.italic : FontStyle.normal,
                        fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                      ),
                      prefixIcon: Icon(
                        Icons.water,
                        size: isMobile ? MobileSizes.iconMedium : 20.0,
                      ),
                      suffixText: '%',
                      suffixStyle: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                      ),
                      helperText: 'Fat content (optional)',
                      helperStyle: TextStyle(
                        fontSize: isMobile ? MobileSizes.caption : 10.0,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? MobileSizes.fieldPaddingH : 16.0,
                        vertical: isMobile ? MobileSizes.fieldPaddingV : 12.0,
                      ),
                    ),
                    onSubmitted: (_) {
                      // Auto-fill if empty
                      if (_fatController.text.isEmpty && _previousFAT != null) {
                        _fatController.text = _previousFAT.toString();
                      }
                      FocusScope.of(context).requestFocus(getFocusNode(4));
                    },
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
                  // SNF Field
                  TextField(
                    controller: _snfController,
                    focusNode: getFocusNode(4),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.bodyMedium : 14.0,
                    ),
                    decoration: InputDecoration(
                      labelText: 'SNF (%)',
                      labelStyle: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                      ),
                      hintText: _snfPlaceholder ?? 'Enter SNF value',
                      hintStyle: TextStyle(
                        color: _previousSNF != null ? Colors.blue.shade600 : Colors.grey,
                        fontStyle: _previousSNF != null ? FontStyle.italic : FontStyle.normal,
                        fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                      ),
                      prefixIcon: Icon(
                        Icons.opacity,
                        size: isMobile ? MobileSizes.iconMedium : 20.0,
                      ),
                      suffixText: '%',
                      suffixStyle: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 13.0,
                      ),
                      helperText: 'Solids-not-fat content (optional)',
                      helperStyle: TextStyle(
                        fontSize: isMobile ? MobileSizes.caption : 10.0,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? MobileSizes.fieldPaddingH : 16.0,
                        vertical: isMobile ? MobileSizes.fieldPaddingV : 12.0,
                      ),
                    ),
                    onSubmitted: (_) {
                      // Auto-fill if empty
                      if (_snfController.text.isEmpty && _previousSNF != null) {
                        _snfController.text = _previousSNF.toString();
                      }
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Calculation Summary Card
            if (_calculatedRate > 0)
              Card(
                color: AppTheme.successColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate, color: AppTheme.successColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Calculation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rate per Liter:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            AppFormatters.currency(_calculatedRate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppFormatters.currency(_calculatedAmount),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Save Button - Responsive width
            SizedBox(
              width: isDesktop ? 400 : double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCollection,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 18 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEdit ? 'Update Collection' : 'Add Collection',
                        style: TextStyle(fontSize: isTablet ? 18 : 16),
                      ),
              ),
            ),

            SizedBox(height: isTablet ? 24 : 16),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
