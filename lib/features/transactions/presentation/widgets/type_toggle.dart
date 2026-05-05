import 'package:flutter/material.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';

class TypeToggle extends StatelessWidget {
  const TypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Expense'),
          icon: Icon(Icons.arrow_downward_rounded),
        ),
        ButtonSegment(
          value: TransactionType.income,
          label: Text('Income'),
          icon: Icon(Icons.arrow_upward_rounded),
        ),
        ButtonSegment(
          value: TransactionType.transfer,
          label: Text('Transfer'),
          icon: Icon(Icons.swap_horiz_rounded),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (set) {
        if (set.isNotEmpty) onChanged(set.first);
      },
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
