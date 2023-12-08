import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?>? onChanged;
  final String hintText;

  const CustomDropdown({
    Key? key,
    required this.items,
    this.selectedItem,
    this.onChanged,
    this.hintText = "Select an item",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          value: selectedItem,
          hint: Text(
            hintText,
            style: TextStyle(color: Colors.blueAccent),
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
        ),
      ),
    );
  }
}
