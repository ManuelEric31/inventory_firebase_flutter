import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:inventory_firebase/widgets/dialogs/custom_video_dialog.dart';
import 'package:inventory_firebase/screens/item/add_item/add_item_screen.dart';
import 'package:inventory_firebase/screens/supplier/add_supplier/add_supplier_screen.dart';
import 'package:inventory_firebase/screens/home_screen.dart';

class MainScreeen extends StatefulWidget {
  const MainScreeen({super.key});

  @override
  State<MainScreeen> createState() => _MainScreeenState();
}

class _MainScreeenState extends State<MainScreeen> {
  int _selectedNavbarIndex = 0;

  void _onTabChange(int index) {
    if (index == 3) {
      showCustomLottieDialog(context);
    }
    setState(() {
      _selectedNavbarIndex = index;
    });
  }

  Widget _getSelectedView() {
    switch (_selectedNavbarIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const AddItemScreen();
      case 2:
        return const AddSupplierScreen();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedView(),
      bottomNavigationBar: GNav(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        backgroundColor: Colors.white,
        activeColor: const Color.fromARGB(255, 0, 28, 53),
        tabBackgroundColor: const Color.fromARGB(52, 3, 44, 149),
        gap: 4,
        selectedIndex: _selectedNavbarIndex,
        onTabChange: _onTabChange,
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.add,
            text: 'Add Item',
          ),
          GButton(
            icon: Icons.person,
            text: 'Add Supplier',
          ),
          GButton(
            icon: Icons.settings,
            text: 'Profile',
          ),
        ],
      ),
    );
  }
}
