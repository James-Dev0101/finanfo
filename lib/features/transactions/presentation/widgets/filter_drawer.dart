import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';
import 'package:finanfo/features/transactions/presentation/providers/transaction_filter_provider.dart';
import 'package:intl/intl.dart';

class FilterDrawer extends ConsumerStatefulWidget {
  const FilterDrawer({super.key});

  @override
  ConsumerState<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends ConsumerState<FilterDrawer> {
  late TransactionFilter _localFilter;
  final _dateFmt = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _localFilter = ref.read(transactionFilterNotifierProvider);
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = (isFrom ? _localFilter.from : _localFilter.to) ??
        DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _localFilter = isFrom
            ? _localFilter.copyWith(from: picked)
            : _localFilter.copyWith(to: picked);
      });
    }
  }

  void _apply() {
    final notifier = ref.read(transactionFilterNotifierProvider.notifier);
    notifier.setType(_localFilter.type);
    notifier.setCategory(_localFilter.category);
    notifier.setDateRange(_localFilter.from, _localFilter.to);
    notifier.setSearchQuery(_localFilter.searchQuery);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() => _localFilter = const TransactionFilter());
    ref.read(transactionFilterNotifierProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg.h),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl.h),
              // Type filter
              Text(
                'Type',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Wrap(
                spacing: AppSpacing.sm.w,
                children: [
                  _TypeChip(
                    label: 'All',
                    selected: _localFilter.type == null,
                    onTap: () =>
                        setState(() => _localFilter = _localFilter.copyWith(
                              clearType: true,
                            )),
                  ),
                  ...TransactionType.values.map((t) => _TypeChip(
                        label: t.name[0].toUpperCase() + t.name.substring(1),
                        selected: _localFilter.type == t,
                        onTap: () => setState(
                            () => _localFilter = _localFilter.copyWith(type: t)),
                      )),
                ],
              ),
              SizedBox(height: AppSpacing.xl.h),
              // Category filter
              Text(
                'Category',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Wrap(
                spacing: AppSpacing.sm.w,
                runSpacing: AppSpacing.xs.h,
                children: TransactionCategory.values.map((c) {
                  final isSelected = _localFilter.category == c;
                  return FilterChip(
                    label: Text('${c.icon} ${c.label}'),
                    selected: isSelected,
                    onSelected: (_) => setState(() {
                      _localFilter = isSelected
                          ? _localFilter.copyWith(clearCategory: true)
                          : _localFilter.copyWith(category: c);
                    }),
                    visualDensity: VisualDensity.compact,
                    labelStyle: TextStyle(fontSize: 12.sp),
                  );
                }).toList(),
              ),
              SizedBox(height: AppSpacing.xl.h),
              // Date range
              Text(
                'Date Range',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'From',
                      value: _localFilter.from != null
                          ? _dateFmt.format(_localFilter.from!)
                          : null,
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: _DateField(
                      label: 'To',
                      value: _localFilter.to != null
                          ? _dateFmt.format(_localFilter.to!)
                          : null,
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Apply button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _apply,
                  child: const Text('Apply'),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      labelStyle: TextStyle(fontSize: 12.sp),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value ?? 'Select',
              style: TextStyle(
                fontSize: 12.sp,
                color: value != null
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
