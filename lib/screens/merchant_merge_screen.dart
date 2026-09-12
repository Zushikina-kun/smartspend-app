import 'package:flutter/material.dart';
import '../services/merchant_normalization_service.dart';
import '../services/db_service.dart';
import '../services/event_bus.dart';

/// MerchantMergeScreen — find and fix duplicate merchant names.
///
/// Shows groups of shop names that look like the same merchant
/// (e.g. "Steam", "STEAM", "Steam Support") and lets the user
/// pick a canonical name, then renames all matching expenses in the DB.
class MerchantMergeScreen extends StatefulWidget {
  const MerchantMergeScreen({super.key});

  @override
  State<MerchantMergeScreen> createState() => _MerchantMergeScreenState();
}

class _MerchantMergeScreenState extends State<MerchantMergeScreen> {
  List<MerchantDuplicateGroup> _groups = [];
  bool _loading = true;
  bool _merging = false;
  final Set<int> _merged = {}; // indices of already-merged groups

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _merged.clear();
    });
    final groups = await MerchantNormalizationService.detectDuplicates();
    if (mounted)
      setState(() {
        _groups = groups;
        _loading = false;
      });
  }

  Future<void> _mergeGroup(int idx) async {
    final group = _groups[idx];
    setState(() => _merging = true);
    int total = 0;
    for (final v in group.variants) {
      if (v.name != group.suggested) {
        total += await MerchantNormalizationService.mergeShopName(
            v.name, group.suggested);
      }
    }
    fireEvent(AppEvent.expenseChanged);
    if (mounted) {
      setState(() {
        _merging = false;
        _merged.add(idx);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Merged ${group.variants.length} variants → \"${group.suggested}\" "
            "($total expenses updated)"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Merchant Cleanup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Re-scan",
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 56, color: Colors.green[400]),
                        const SizedBox(height: 16),
                        const Text(
                          "No duplicate merchants found!",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "All your shop names look consistent. "
                          "New imports are auto-normalized going forward.",
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.6)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Info banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      color: cs.primaryContainer.withValues(alpha: 0.5),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: cs.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${_groups.where((g) => !_merged.contains(_groups.indexOf(g))).length} "
                              "duplicate groups found. Tap Merge to unify them.",
                              style: TextStyle(
                                  fontSize: 12, color: cs.onPrimaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _groups.length,
                        itemBuilder: (_, i) {
                          final g = _groups[i];
                          final done = _merged.contains(i);
                          return Card(
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 10),
                            color: done
                                ? Colors.green.withValues(alpha: 0.06)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${g.variants.length} variants · "
                                              "${g.totalCount} expense${g.totalCount == 1 ? '' : 's'}",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: cs.onSurface
                                                      .withValues(alpha: 0.5)),
                                            ),
                                            const SizedBox(height: 4),
                                            // Variant chips
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: g.variants.map((v) {
                                                final isChosen =
                                                    v.name == g.suggested;
                                                return GestureDetector(
                                                  onTap: done
                                                      ? null
                                                      : () => setState(() =>
                                                          g.suggested = v.name),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: isChosen
                                                          ? cs.primary
                                                              .withValues(
                                                                  alpha: 0.15)
                                                          : cs.surfaceContainerHighest
                                                              .withValues(
                                                                  alpha: 0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: isChosen
                                                            ? cs.primary
                                                                .withValues(
                                                                    alpha: 0.4)
                                                            : cs.outline
                                                                .withValues(
                                                                    alpha: 0.2),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (isChosen)
                                                          Icon(Icons.check,
                                                              size: 12,
                                                              color:
                                                                  cs.primary),
                                                        if (isChosen)
                                                          const SizedBox(
                                                              width: 3),
                                                        Text(
                                                          v.name,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: isChosen
                                                                ? FontWeight
                                                                    .w600
                                                                : FontWeight
                                                                    .normal,
                                                            color: isChosen
                                                                ? cs.primary
                                                                : null,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          "(${v.count})",
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: cs
                                                                  .onSurface
                                                                  .withValues(
                                                                      alpha:
                                                                          0.45)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Canonical name + merge button
                                  Row(
                                    children: [
                                      Expanded(
                                        child: done
                                            ? Row(children: [
                                                Icon(Icons.check_circle,
                                                    size: 16,
                                                    color: Colors.green),
                                                const SizedBox(width: 6),
                                                Text(
                                                    "Merged as \"${g.suggested}\"",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.green[700],
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ])
                                            : Text(
                                                "Tap a variant to pick the name → all others will be renamed.",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: cs.onSurface
                                                        .withValues(
                                                            alpha: 0.5)),
                                              ),
                                      ),
                                      if (!done)
                                        ElevatedButton.icon(
                                          icon: _merging
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white))
                                              : const Icon(Icons.merge,
                                                  size: 16),
                                          label: Text(
                                              "Merge as \"${g.suggested}\"",
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cs.primary,
                                            foregroundColor: cs.onPrimary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          onPressed: _merging
                                              ? null
                                              : () => _mergeGroup(i),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
