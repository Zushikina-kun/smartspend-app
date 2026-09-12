import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/event_bus.dart';

/// Paluwagan Tracker — Filipino rotating savings group (ROSCA).
///
/// A paluwagan is a group where each member contributes a fixed amount
/// each round. One member "wins" (receives) the pot per round, rotating
/// through all members until everyone has received once.
///
/// This screen lets users track:
///   - Group name and contribution amount
///   - Members (with payout order)
///   - Current round
///   - Auto-logs the contribution as an expense each round
class PalawaganScreen extends StatefulWidget {
  const PalawaganScreen({super.key});

  @override
  State<PalawaganScreen> createState() => _PalawaganScreenState();
}

class _PalawaganScreenState extends State<PalawaganScreen> {
  List<Map<String, dynamic>> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final groups = await DBService.getPalawaganGroups();
    if (mounted)
      setState(() {
        _groups = groups;
        _loading = false;
      });
  }

  void _showAddGroupDialog({Map<String, dynamic>? existing}) {
    final nameCtrl =
        TextEditingController(text: existing?['name'] as String? ?? '');
    final amtCtrl = TextEditingController(
        text: existing != null
            ? (existing['contribution_amount'] as num).toStringAsFixed(0)
            : '');
    final membersCtrl =
        TextEditingController(text: existing?['members'] as String? ?? '');
    int currentRound = (existing?['current_round'] as int?) ?? 1;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
                title:
                    Text(existing == null ? "New Paluwagan" : "Edit Paluwagan"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                            labelText: "Group Name (e.g. Office Paluwagan)",
                            border: OutlineInputBorder(),
                            isDense: true),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: amtCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: "Contribution per round (₱)",
                            border: OutlineInputBorder(),
                            isDense: true),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: membersCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Members (one per line, in payout order)",
                          hintText: "Brix\nCyrille\nDjaunathan",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Text("Current round: ",
                            style: TextStyle(fontSize: 13)),
                        IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: currentRound > 1
                                ? () => setS(() => currentRound--)
                                : null),
                        Text('$currentRound',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setS(() => currentRound++)),
                      ]),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel")),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final amt = double.tryParse(amtCtrl.text.trim());
                      if (name.isEmpty || amt == null || amt <= 0) return;
                      final data = {
                        'name': name,
                        'contribution_amount': amt,
                        'members': membersCtrl.text.trim(),
                        'current_round': currentRound,
                        'created_at': DateTime.now().toIso8601String(),
                      };
                      if (existing != null) {
                        await DBService.updatePalawagan(
                            {...data, 'id': existing['id']});
                      } else {
                        await DBService.insertPalawagan(data);
                      }
                      Navigator.pop(ctx);
                      _load();
                    },
                    child: Text(existing == null ? "Create" : "Save"),
                  ),
                ],
              )),
    );
  }

  Future<void> _logContribution(Map<String, dynamic> g) async {
    final name = g['name'] as String;
    final amt = (g['contribution_amount'] as num).toDouble();
    final now = DateTime.now();
    await DBService.insertExpense({
      'item_name': 'Paluwagan contribution — $name',
      'category': 'Bills',
      'amount': amt,
      'date': now.toIso8601String().substring(0, 10),
      'time': now.toIso8601String().substring(11, 16),
      'payment_method': 'Cash',
      'notes': 'Round ${g['current_round']}',
      'ai_generated': 0,
      'confidence_score': 1.0,
      'is_want': 0,
    });
    // Advance round
    await DBService.updatePalawagan(
        {...g, 'current_round': (g['current_round'] as int) + 1});
    fireEvent(AppEvent.expenseChanged);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Contribution logged ✓ (Round ${g['current_round']})"),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paluwagan Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "New group",
            onPressed: () => _showAddGroupDialog(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text("🏦", style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text("No paluwagan groups yet",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                          "Track your rotating savings group — members, payout order, and contributions.",
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.55)),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add Paluwagan Group"),
                        onPressed: () => _showAddGroupDialog(),
                      ),
                    ]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _groups.length,
                  itemBuilder: (_, i) {
                    final g = _groups[i];
                    final name = g['name'] as String;
                    final amt = (g['contribution_amount'] as num).toDouble();
                    final members = (g['members'] as String? ?? '')
                        .split('\n')
                        .where((s) => s.trim().isNotEmpty)
                        .toList();
                    final currentRound = g['current_round'] as int;
                    final totalRounds = members.length;
                    final winner =
                        currentRound <= totalRounds && members.isNotEmpty
                            ? members[currentRound - 1]
                            : null;
                    final potSize = amt * members.length;

                    return Card(
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Text("🏦",
                                    style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(name,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold))),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit')
                                      _showAddGroupDialog(existing: g);
                                    if (v == 'delete')
                                      DBService.deletePalawagan(g['id'] as int)
                                          .then((_) => _load());
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'edit', child: Text("Edit")),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ),
                              ]),
                              const SizedBox(height: 8),
                              Row(children: [
                                _statChip("₱${amt.toStringAsFixed(0)}/round",
                                    Icons.payments_outlined, cs.primary),
                                const SizedBox(width: 8),
                                _statChip("Pot: ₱${potSize.toStringAsFixed(0)}",
                                    Icons.savings_outlined, Colors.green),
                                const SizedBox(width: 8),
                                _statChip(
                                    "Round $currentRound/${members.isEmpty ? '?' : totalRounds}",
                                    Icons.loop,
                                    Colors.orange),
                              ]),
                              if (winner != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.amber
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Row(children: [
                                    const Text("🎉",
                                        style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text("This round: $winner receives the pot",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ]),
                                ),
                              ],
                              if (members.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: members.asMap().entries.map((e) {
                                    final roundNum = e.key + 1;
                                    final isCurrent = roundNum == currentRound;
                                    final isPast = roundNum < currentRound;
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? Colors.amber
                                                .withValues(alpha: 0.2)
                                            : isPast
                                                ? Colors.grey
                                                    .withValues(alpha: 0.15)
                                                : cs.primary
                                                    .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isCurrent
                                              ? Colors.amber
                                              : isPast
                                                  ? Colors.grey
                                                      .withValues(alpha: 0.3)
                                                  : cs.primary
                                                      .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isPast)
                                              const Icon(Icons.check,
                                                  size: 10,
                                                  color: Colors.green),
                                            if (isCurrent)
                                              const Text("🎉",
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                            const SizedBox(width: 3),
                                            Text("$roundNum. ${e.value}",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: isCurrent
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isPast
                                                        ? Colors.grey
                                                        : null)),
                                          ]),
                                    );
                                  }).toList(),
                                ),
                              ],
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.payments, size: 16),
                                  label: Text(
                                      "Log My Contribution (₱${amt.toStringAsFixed(0)})"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: cs.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _logContribution(g),
                                ),
                              ),
                            ]),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _statChip(String label, IconData icon, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ]),
      );
}
