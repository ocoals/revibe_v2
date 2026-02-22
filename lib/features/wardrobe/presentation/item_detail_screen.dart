import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// S07: Wardrobe item detail
class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이템 상세'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Edit item
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              // TODO: Delete item with confirmation
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Item: $itemId',
          style: TextStyle(color: AppColors.textCaption),
        ),
      ),
    );
  }
}
