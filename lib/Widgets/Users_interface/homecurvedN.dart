import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mouvi_map_application/Services/ModuleOffres/addOffres.dart';
import 'package:mouvi_map_application/Widgets/SignIn/Authentify.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/Step1.dart';

class HomePageN extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageN> {
  int _selectedIndex = 0;

  // Define a list of widgets that corresponds to each tab
  final List<Widget> _widgetOptions = [
    homePge1(
      isLogedIn: false,
    ),
    Authentify(),
    Authentify(),
  ];

  // Function to handle the change in selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        letIndexChange: (i) {
          return true; // Allow index change
        },
        color: Color.fromARGB(255, 31, 24, 1),
        backgroundColor: Colors.grey,
        buttonBackgroundColor: Color.fromARGB(255, 110, 66, 0),
        height: 60,
        index: 0, // Set the selected index
        onTap: (index) {
          setState(() {
            _selectedIndex = index;

            if (_selectedIndex == 1) {} // Update the selected index
          });
        },
        items: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.add, 1),
          _buildNavItem(Icons.person, 2),
        ],
      ),
    );
  }
}

int _selectedIndex = 0; // To track the selected item
// Helper to build navigation items with dynamic colors
Widget _buildNavItem(IconData icon, int index) {
  final isSelected = _selectedIndex == index;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: isSelected
            ? Colors.white
            : Colors.white, // Amber for selected, white for unselected
        size: index == 1 ? 48 : 30, // Fixed size for center icon
      ),
      if (isSelected && index != 1) // Add an optional indicator
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
    ],
  );
}

// Home Widget (First Tab)
class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Home Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Add Widget (Second Tab)
class AddWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Add Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Profile Widget (Third Tab)
class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
