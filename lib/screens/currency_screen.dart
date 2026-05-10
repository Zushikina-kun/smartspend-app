import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _selected = CurrencyService.currentCurrency;
  bool _loading = false;
  String _lastUpdated = '';
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLastUpdated();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLastUpdated() async {
    final ts = await CurrencyService.getLastUpdated();
    setState(() => _lastUpdated = ts);
  }

  Future<void> _select(String code) async {
    setState(() {
      _selected = code;
      _loading = true;
    });
    await CurrencyService.setCurrency(code);
    await _loadLastUpdated();
    if (!mounted) return;
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Currency set to $code"),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency & Region"),
        actions: [
          const InfoButton(
            title: "Currency & Exchange Rates",
            body:
                "Select your preferred display currency. All amounts in the app are stored in Philippine Peso (PHP) and converted for display only.\n\n"
                "• 34+ currencies supported\n"
                "• Live rates from open.er-api.com — cached for 1 hour\n"
                "• Tap the refresh icon to force-update rates\n"
                "• Changing currency affects all displayed amounts immediately\n\n"
                "Note: Changing currency does not convert your stored data — it only changes how amounts are displayed.",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh rates",
            onPressed: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    await CurrencyService.setCurrency(_selected);
                    await _loadLastUpdated();
                    setState(() => _loading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Exchange rates refreshed"),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current rate info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: cs.primaryContainer,
            child: Row(
              children: [
                Icon(Icons.currency_exchange, color: cs.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current: ${CurrencyService.currentCurrency} — ${CurrencyService.symbol}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer),
                      ),
                      if (_selected != 'PHP')
                        Text(
                          "Rate updated: $_lastUpdated",
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  cs.onPrimaryContainer.withValues(alpha: 0.7)),
                        ),
                      if (_selected != 'PHP')
                        Text(
                          "1 PHP = ${CurrencyService.convert(1).toStringAsFixed(4)} $_selected",
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  cs.onPrimaryContainer.withValues(alpha: 0.7)),
                        ),
                    ],
                  ),
                ),
                if (_loading)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Select Currency",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Search currency...",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        })
                    : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),

          Expanded(
            child: ListView(
              children: CurrencyService.supportedCurrencies.entries
                  .where((entry) =>
                      _search.isEmpty ||
                      entry.key.toLowerCase().contains(_search) ||
                      entry.value.toLowerCase().contains(_search))
                  .map((entry) {
                final isSelected = _selected == entry.key;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected ? cs.primary : cs.surfaceContainerHighest,
                    child: Text(
                      CurrencyService.currencySymbols[entry.key] ?? entry.key,
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : cs.onSurface),
                    ),
                  ),
                  title: Text(entry.key,
                      style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  subtitle: Text(entry.value.split(' ').skip(1).join(' '),
                      style: const TextStyle(fontSize: 12)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: cs.primary)
                      : null,
                  onTap: _loading ? null : () => _select(entry.key),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Exchange rates are fetched from open.er-api.com and cached for 1 hour. All amounts in the app are stored in PHP and converted for display only.",
              style: TextStyle(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
