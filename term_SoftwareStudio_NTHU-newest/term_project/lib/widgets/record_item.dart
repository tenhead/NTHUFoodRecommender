

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:term_project/models/my_record.dart';

class RecordItem extends StatelessWidget {
  final MyRecord record;

  const RecordItem({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/record/${record.foodImage}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Image.asset(record.foodImage),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.calories,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(record.protein),
                  Text(record.fat),
                  Text(record.carbs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}