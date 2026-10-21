import 'package:flutter/material.dart';

import '../widgets/parcels_list_view.dart';

class ParcelsPage extends StatelessWidget {
  const ParcelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ParcelsListView(showBack: true),
    );
  }
}
