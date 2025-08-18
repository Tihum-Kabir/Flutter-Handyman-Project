import 'package:flutter/material.dart';
import 'handyman_list.dart';

/// Page presenting a list of cleaners.
class CleanerPage extends StatelessWidget {
  const CleanerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HandymanListPage(category: 'Cleaner');
  }
}



