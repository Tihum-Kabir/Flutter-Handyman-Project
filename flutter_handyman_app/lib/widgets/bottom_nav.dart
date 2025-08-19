import 'package:flutter/material.dart';

/// A reusable bottom navigation bar with four buttons: Profile, Dashboard,
/// Orders and Search.  The [currentIndex] indicates which page is active
/// and is used to style the active icon.  Tapping a button calls
/// [onTap] with the selected index.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, -1),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(context, 0, Icons.person, 'Profile'),
          _buildItem(context, 1, Icons.dashboard, 'Dashboard'),
          _buildItem(context, 2, Icons.list_alt, 'My Order'),
          _buildItem(context, 3, Icons.search, 'Search'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData icon, String label) {
    final bool isActive = index == currentIndex;
    final color = isActive ? Colors.teal : Colors.white70;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}