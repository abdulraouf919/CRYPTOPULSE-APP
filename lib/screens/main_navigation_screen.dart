import 'package:cryptopulse/screens/charts_screen.dart';
import 'package:cryptopulse/screens/home_screen.dart';
import 'package:cryptopulse/screens/login_screen.dart';
import 'package:cryptopulse/screens/wallet_screen.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  final int userId;
  const MainNavigation({super.key, required this.userId});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(userId: widget.userId),
      ChartsScreen(),
      WalletScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      // Logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'الرسوم البيانية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'المحفظة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'تسجيل الخروج',
            ),
          ],
        ),
      ),
    );
  }
} 