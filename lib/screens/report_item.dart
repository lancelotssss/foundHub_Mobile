import 'package:flutter/material.dart';
import '../global/activeuser.dart';
import '../global/allitems.dart';
import '../theme/foundhub_theme.dart';
import 'similar_items.dart';
class ReportItemPage extends StatefulWidget {
  final int?editId;
  final String initialReportType;

  const ReportItemPage({
    super.key,
    this.editId,
    this.initialReportType = 'Lost',
  });
  @override State<ReportItemPage> createState() => _ReportItemPageState();
}
class _ReportItemPageState extends State<ReportItemPage> {
  final formKey = GlobalKey<FormState>();
  String reportType = 'Lost';
  String category = 'Gadgets';
  final itemName = TextEditingController();
  final brand = TextEditingController();
  String? selectedLocation;
  static const List<String> locations = [
    'Ground Floor',
    '7th Floor',
    '8th Floor',
    '9th Floor',
    '10th Floor',
    '11th Floor',
    '12th Floor',
    'Outside of Campus',
  ];
  final description = TextEditingController();
  final photoUrl = TextEditingController();
  DateTime?startDate;
  DateTime?endDate;
  DateTime?dateFound;
    static const categories =[
    'Gadgets',
    'Identification Card',
    'Personal Belongings',
    'School Supplies',
    'Wearables',
    'Others'
  ];
  // Item options follow the original FoundHub React report form.
  static const Map<String, List<String>> categoryItems = {
    'Gadgets': [
      'Audio Device',
      'Calculator',
      'Charging Utilities',
      'CPU',
      'Laptop',
      'Mobile Device',
      'Power Bank',
      'Watch',
      'Others',
    ],
    'Identification Card': [
      'Driver’s License',
      'National ID',
      'Passport',
      'School ID',
      'Others',
    ],
    'Personal Belongings': [
      'Accessories',
      'Bag',
      'Cosmetic Products',
      'Handkerchief',
      'Keys',
      'Tumbler',
      'Umbrella',
      'Wallet',
      'Others',
    ],
    'School Supplies': [
      'Architecture Materials',
      'Books',
      'Medical Materials',
      'Office Supplies',
      'Pen',
      'Others',
    ],
    'Wearables': [
      'Cap',
      'Eyeglass',
      'Foot Wearables',
      'Hat',
      'Jacket',
      'Lab Gown',
      'T-shirt',
      'Trousers',
      'Uniform',
      'Others',
    ],
    'Others': ['Others'],
  };

  String? selectedItem;

  void changeCategory(String? newCategory) {
    if (newCategory == null) return;

    setState(() {
      category = newCategory;
      selectedItem = null;
      itemName.clear();
    });
  }

  void changeItem(String? newItem) {
    if (newItem == null) return;

    setState(() {
      selectedItem = newItem;
      itemName.text = newItem == 'Others' ? '' : newItem;
    });
  }

  Widget itemDropdown() {
    final options = categoryItems[category] ?? ['Others'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey(category),
        value: selectedItem,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Item name',
          hintText: 'Choose the item.',
          border: OutlineInputBorder(),
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: changeItem,
        validator: (value) {
          if (value == null) return 'Please select an item';
          return null;
        },
      ),
    );
  }

  @override void initState() {
    super.initState();
    reportType = widget.initialReportType;
    if(widget.editId!= null) {
      final item = AllItems.findItem(widget.editId!);
        if(item!= null && item[
        'ownerEmail'
        ] == ActiveUser.activeUser[
        'email'
      ]) {
          reportType = item[
          'reportType'
        ];
          category = item[
          'category'
        ];
          itemName.text = item[
          'keyItem'
        ];
          final itemOptions = categoryItems[category] ?? ['Others'];
          selectedItem = itemOptions.contains(itemName.text)
              ? itemName.text
              : 'Others';
          brand.text = item[
          'itemBrand'
        ];
          final savedLocation = item['location']?.toString();
          selectedLocation = locations.contains(savedLocation)
              ? savedLocation
              : null;
          description.text = item[
          'description'
        ];
          photoUrl.text = item[
          'photoUrl'
        ] ??'';
          startDate = item[
          'startDate'
        ];
          endDate = item[
          'endDate'
        ];
          dateFound = item[
          'dateFound'
        ];
      }
    }
  }
  @override void dispose() {
      for(final c in[
      itemName,
      brand,
      description,
      photoUrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }
  Future<void> pickDate(String which) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final firstDate = DateTime(2000);

    // The original React form limits the end date to five days after
    // the start date, and never permits future dates.
    DateTime minimum = firstDate;
    DateTime maximum = today;
    DateTime initial = today;

    if (which == 'start') {
      initial = startDate ?? today;
    } else if (which == 'end') {
      if (startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select the start date first.')),
        );
        return;
      }
      minimum = DateUtils.dateOnly(startDate!);
      final latestAllowed = minimum.add(const Duration(days: 5));
      maximum = latestAllowed.isBefore(today) ? latestAllowed : today;
      initial = endDate ?? minimum;
    } else {
      initial = dateFound ?? today;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minimum,
      lastDate: maximum,
    );

    if (!mounted || selected == null) return;

    setState(() {
      if (which == 'start') {
        startDate = selected;
        // React resets the end date whenever the start date changes.
        endDate = null;
      } else if (which == 'end') {
        endDate = selected;
      } else {
        dateFound = selected;
      }
    });
  }
  Widget dateRow(String label, DateTime? date, String which) {
    String placeholder;

    if (which == 'start') {
      placeholder = 'Select start date';
    } else if (which == 'end') {
      placeholder = 'Select end date';
    } else {
      placeholder = 'Select the date the item was found';
    }

    String displayDate = placeholder;

    if (date != null) {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      displayDate = '$month/$day/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => pickDate(which),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_month),
          ).copyWith(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          child: Text(
            displayDate,
            style: TextStyle(
              fontSize: 16,
              color: date == null
                  ? FoundHubTheme.muted
                  : FoundHubTheme.navy,
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    if(!formKey.currentState!.validate()) return;
    if (itemName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter or select an item name.')),
      );
      return;
    }
    if(reportType == 'Lost' &&(startDate == null || endDate == null || startDate!.isAfter(endDate!))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a valid lost-date range.')));
      return;
    }
    if (reportType == 'Lost' &&
        endDate!.isAfter(startDate!.add(const Duration(days: 5)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The date range cannot exceed 5 days.')),
      );
      return;
    }
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location.')),
      );
      return;
    }
    if(reportType == 'Found' && dateFound == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select the date found.')));
      return;
    }
    final previous = widget.editId == null?null: AllItems.findItem(widget.editId!);
      if(previous!= null &&(previous[
      'ownerEmail'
      ]!= ActiveUser.activeUser[
      'email'
      ] || previous[
      'status'
    ]!= 'Listed')) return;
    final record = <String, dynamic> {
        'id': previous?[
        'id'
        ] ??AllItems.nextItemId++, 'ownerEmail': ActiveUser.activeUser[
        'email'
        ], 'ownerName': ActiveUser.activeUser[
        'fullname'
        ], 'ownerPhone': ActiveUser.activeUser[
        'phone'
      ], 'reportType': reportType, 'category': category, 'keyItem': itemName.text.trim(),
      'itemBrand': brand.text.trim(), 'location': selectedLocation!,
      'description': description.text.trim(), 'photoUrl': photoUrl.text.trim(),
      'startDate': reportType == 'Lost'?startDate: null, 'endDate': reportType == 'Lost'?endDate: null,
        'dateFound': reportType == 'Found'?dateFound: null, 'status': previous?[
        'status'
        ] ??'Listed', 'createdAt': previous?[
        'createdAt'
      ] ??DateTime.now(),
    };
    if(previous == null) {
      AllItems.allItemsList.add(record);
    } else {
      previous..clear()..addAll(record);
    }
    if (reportType == 'Lost') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SimilarItemsPage(lostItemId: record['id'] as int),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SimilarItemsPage(foundItemId: record['id'] as int),
        ),
      );
    }
  }
  Widget textInput(TextEditingController controller, String label,
  {
    bool required = true, int lines = 1, String? placeholder
  }) => Padding(padding: const EdgeInsets.only(bottom: 12),
  child: TextFormField(controller: controller, maxLines: lines,
  decoration: InputDecoration(
    labelText: label,
    hintText: placeholder,
    border: const OutlineInputBorder(),
  ),
  validator: (v) => required &&(v == null || v.trim().isEmpty)?'$label is required': null),
  );
  @override Widget build(BuildContext context) {
    final editing = widget.editId!= null;
    return Scaffold(appBar: AppBar(title: Text(editing?'Edit Report': 'Report an Item')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650),
    child: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(18),
      children: [
      const Center(child: FoundHubBrand(height: 46)),
      const SizedBox(height: 18),
      const Text('WHAT WOULD YOU LIKE TO REPORT?', style: TextStyle(fontSize: 19,
      color: FoundHubTheme.navy, fontWeight: FontWeight.w800)),
      const Text('Help the community find and return lost belongings.',
      style: TextStyle(fontSize: 12, color: FoundHubTheme.muted)),
      const SizedBox(height: 18),
        SegmentedButton<String>(segments: const[
        ButtonSegment(value: 'Lost', label: Text('Lost'), icon: Icon(Icons.search)),
        ButtonSegment(value: 'Found', label: Text('Found'), icon: Icon(Icons.inventory))
      ], selected: {
        reportType
      }, onSelectionChanged: (v) => setState(() => reportType = v.first)),
      const SizedBox(height: 18),
      DropdownButtonFormField<String>(
        value: category,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Category',
          hintText: 'Choose an item category',
          border: OutlineInputBorder(),
        ),
        items: categories.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: changeCategory,
      ),
      const SizedBox(height: 12),
      itemDropdown(),
      if (selectedItem == 'Others')
        textInput(
          itemName,
          'Specify item',
          placeholder: 'e.g., Bluetooth earbuds, student lanyard',
        ),
      textInput(brand, 'Brand (optional)', required: false, placeholder: 'e.g., Samsung, Casio, Hawk (leave blank if unknown)'),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          value: selectedLocation,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'Choose location.',
            border: OutlineInputBorder(),
          ),
          items: locations.map((place) {
            return DropdownMenuItem<String>(
              value: place,
              child: Text(place),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedLocation = value;
            });
          },
          validator: (value) {
            if (value == null) return 'Please select a location';
            return null;
          },
        ),
      ),
        if(reportType == 'Lost')...[
        dateRow('Start date of loss', startDate, 'start'),
        dateRow('End date of loss', endDate, 'end')
      ] else dateRow('Date found', dateFound, 'found'),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          reportType == 'Lost'
              ? 'Choose a date range.'
              : 'Choose the actual date the item was found.',
          style: const TextStyle(fontSize: 12, color: FoundHubTheme.muted),
        ),
      ),
      textInput(description, 'Description', required: false, lines: 4, placeholder: 'e.g., Black wallet with a small scratch on the front and a blue keychain'),
      textInput(photoUrl, 'Photo URL (optional)', required: false, placeholder: 'https://images.unsplash.com/photo-1678449544865-c03dc897112d?w=600'),
      const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text(
          'Paste a public, direct image link (JPG, PNG, or WebP). Example photos are for testing only.',
          style: TextStyle(fontSize: 12, color: FoundHubTheme.muted),
        ),
      ),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: submit, icon: const Icon(Icons.send),
      label: Text(editing?'Save Changes': 'Publish Report')),
      const SizedBox(height: 24),
    ])))));
  }
}
