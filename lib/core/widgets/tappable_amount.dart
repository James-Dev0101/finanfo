import 'package:flutter/material.dart';
import 'package:finanfo/core/utils/currency_utils.dart';

/// Compact amount that expands to the full number on tap, collapses on tap again.
/// When expanded, uses FittedBox so very large numbers scale down to fit.
class TappableAmount extends StatefulWidget {
  const TappableAmount({
    super.key,
    required this.amount,
    required this.currency,
    this.prefix = '',
    this.style,
  });

  final double amount;
  final String currency;
  final String prefix;
  final TextStyle? style;

  @override
  State<TappableAmount> createState() => _TappableAmountState();
}

class _TappableAmountState extends State<TappableAmount> {
  bool _showFull = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.prefix +
        CurrencyUtils.format(widget.amount, widget.currency,
            compact: !_showFull);
    return GestureDetector(
      onTap: () => setState(() => _showFull = !_showFull),
      child: _showFull
          ? FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(text, style: widget.style),
            )
          : Text(text, style: widget.style, maxLines: 1,
              overflow: TextOverflow.ellipsis),
    );
  }
}

/// Two amounts with a shared toggle. Compact: "amount1 / amount2" on one line.
/// Expanded: two separate lines, each scaled down with FittedBox.
class TappableAmountPair extends StatefulWidget {
  const TappableAmountPair({
    super.key,
    required this.amount1,
    required this.amount2,
    required this.currency,
    this.separator = ' / ',
    this.style,
  });

  final double amount1;
  final double amount2;
  final String currency;
  final String separator;
  final TextStyle? style;

  @override
  State<TappableAmountPair> createState() => _TappableAmountPairState();
}

class _TappableAmountPairState extends State<TappableAmountPair> {
  bool _showFull = false;

  @override
  Widget build(BuildContext context) {
    final f1 = CurrencyUtils.format(widget.amount1, widget.currency,
        compact: !_showFull);
    final f2 = CurrencyUtils.format(widget.amount2, widget.currency,
        compact: !_showFull);
    return GestureDetector(
      onTap: () => setState(() => _showFull = !_showFull),
      child: _showFull
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(f1, style: widget.style),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(f2, style: widget.style),
                ),
              ],
            )
          : Text('$f1${widget.separator}$f2', style: widget.style,
              maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
