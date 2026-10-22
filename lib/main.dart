import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محاسبه درصد محصول',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const DiscountPage(),
    );
  }
}

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});
  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final _controller = TextEditingController(text: '56000000');
  List<_Row> _rows = [];
  double? _base;

  static const _steps = [
    _Step('تخفیف نماینده', 10, 0.90, 'مجموعا 10 درصد'),
    _Step('تخفیف خرید نقدی نماینده', 5, 0.95, 'مجموعا 15 درصد'),
    _Step('تخفیف خرید عمده نماینده', 5, 0.95, 'مجموعا 20 درصد'),
    _Step('تخفیف پروژه‌ای نماینده', 5, 0.95, 'مجموعا 25 درصد'),
  ];

  void _calc() {
    final v = double.tryParse(_controller.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      setState(() {
        _rows = [];
        _base = null;
      });
      return;
    }
    final rows = <_Row>[];
    double prev = v;
    for (final s in _steps) {
      final after = prev * s.factor;
      rows.add(_Row(
        title: s.title,
        percent: s.percent,
        factor: s.factor,
        note: s.note,
        after: after,
        totalDiff: v - after,
      ));
      prev = after;
    }
    setState(() {
      _base = v;
      _rows = rows;
    });
  }

  String _fmt(double x) => x
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('محاسبه فرمول درصد تخفیف فروش')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'قیمت فروش مصرف‌کننده (ریال)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                ),
                onSubmitted: (_) => _calc(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calc,
                  icon: const Icon(Icons.calculate),
                  label: const Text('محاسبه'),
                ),
              ),
              const SizedBox(height: 12),
              if (_base != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('قیمت پایه: ${_fmt(_base!)} ریال',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: _rows.isEmpty
                    ? const Center(
                        child: Text('عدد را وارد کرده و «محاسبه» را بزنید'),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildTable(context),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const cellStyle = TextStyle(fontSize: 12);

    TableRow headerRow = TableRow(
      decoration: BoxDecoration(color: cs.primary),
      children: const [
        _Header('تخفیف پله‌ای نمایندگان'),
        _Header('درصد'),
        _Header('ضریب'),
        _Header('توضیح'),
        _Header('قیمت با تخفیف'),
        _Header('مبلغ ریالی تخفیف'),
      ],
    );

    final dataRows = <TableRow>[];
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      dataRows.add(TableRow(
        decoration: BoxDecoration(
          color: i.isEven ? Colors.white : Colors.grey.shade100,
        ),
        children: [
          _Cell(r.title, style: cellStyle),
          _Cell('${r.percent}٪', style: cellStyle),
          _Cell(r.factor.toStringAsFixed(2), style: cellStyle),
          _Cell(r.note, style: cellStyle),
          _Cell(_fmt(r.after), style: cellStyle),
          _Cell(_fmt(r.totalDiff), style: cellStyle),
        ],
      ));
    }

    return Table(
      border: TableBorder.all(color: Colors.grey.shade400, width: 0.8),
      columnWidths: const {
        0: FixedColumnWidth(180),
        1: FixedColumnWidth(55),
        2: FixedColumnWidth(55),
        3: FixedColumnWidth(120),
        4: FixedColumnWidth(120),
        5: FixedColumnWidth(130),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [headerRow, ...dataRows],
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white)),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _Cell(this.text, {required this.style});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text, textAlign: TextAlign.center, style: style),
    );
  }
}

class _Step {
  final String title;
  final int percent;
  final double factor;
  final String note;
  const _Step(this.title, this.percent, this.factor, this.note);
}

class _Row {
  final String title;
  final int percent;
  final double factor;
  final String note;
  final double after;
  final double totalDiff;
  _Row({
    required this.title,
    required this.percent,
    required this.factor,
    required this.note,
    required this.after,
    required this.totalDiff,
  });
}
