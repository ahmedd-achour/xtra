import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/home.dart';
import 'package:mouvi_map_application/data/xtradata.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapboxExample(),
  ));
}

// COUNTRY SELECTION POPUP WIDGET
class CountrySelectionPopup extends StatefulWidget {
  final Function(String) onCountrySelected;
  CountrySelectionPopup({required this.onCountrySelected});

  @override
  _CountrySelectionPopupState createState() => _CountrySelectionPopupState();
}

class _CountrySelectionPopupState extends State<CountrySelectionPopup> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjust height dynamically
        children: [
          // Title and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Align to the left
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8), // Add spacing between icon and text
              const Text(
                "Sélectionner un pays",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          // Search Bar
          SizedBox(
            width: 280, // Adjust width as needed
            height: 40, // Adjust height as needed
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un pays",
                prefixIcon: const Icon(Icons.search, size: 20), // Smaller icon
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8), // Adjust padding
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Smaller radius
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // Country List
          SizedBox(
            height: 250, // Limit height
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];

                if (searchQuery.isNotEmpty &&
                    !country['name']!.toLowerCase().contains(searchQuery)) {
                  return SizedBox.shrink(); // Hide if not matching
                }

                return ListTile(
                  title: Text(
                    country['name']!,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  leading: Text(
                    country['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  onTap: () {
                    widget.onCountrySelected(country['flag']!);
                    Navigator.pop(context); // Close dialog
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
