import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Step-by-step guide for setting up a local LLM server.
/// Covers Ollama (recommended), LM Studio, and Jan.
class LocalAiSetupSheet extends StatefulWidget {
  const LocalAiSetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const LocalAiSetupSheet(),
    );
  }

  @override
  State<LocalAiSetupSheet> createState() => _LocalAiSetupSheetState();
}

class _LocalAiSetupSheetState extends State<LocalAiSetupSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _ramIndex = 1; // 0 = 8GB, 1 = 16GB, 2 = 32GB+

  static const _ramLabels = ['8 GB RAM', '16 GB RAM', '32 GB+ RAM'];
  static const _modelRecs = [
    'phi4-mini',    // 8 GB
    'qwen3:7b',     // 16 GB
    'qwen3:14b',    // 32 GB+
  ];
  static const _modelDescs = [
    'Phi-4 Mini (3.8B) — 3 GB, good instruction following',
    'Qwen3 7B — 5 GB, strong multilingual + Filipino',
    'Qwen3 14B — 9 GB, near cloud quality',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Copied to clipboard'),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _codeBlock(BuildContext context, String code) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              code,
              style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 12, height: 1.4),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16),
          onPressed: () => _copy(context, code),
          tooltip: 'Copy',
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
      ]),
    );
  }

  Widget _step(BuildContext context, int n, String title, List<Widget> content) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 1, right: 12),
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$n',
                  style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                ...content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡 ',
              style: TextStyle(fontSize: 14, color: cs.primary)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.75),
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _ollamaTab(BuildContext context) {
    final model = _modelRecs[_ramIndex];
    final modelDesc = _modelDescs[_ramIndex];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Hardware picker
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("How much RAM does your PC/Mac have?",
                  style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: List.generate(
                    3,
                    (i) => ButtonSegment<int>(
                        value: i, label: Text(_ramLabels[i]))),
                selected: {_ramIndex},
                onSelectionChanged: (s) =>
                    setState(() => _ramIndex = s.first),
                style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                        const TextStyle(fontSize: 11))),
              ),
              const SizedBox(height: 8),
              Text("Recommended: $modelDesc",
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _step(context, 1, "Install Ollama on your computer", [
          _tip(context,
              "Ollama is free and works on Windows, Mac, and Linux."),
          _codeBlock(context,
              "Download from: https://ollama.com/download"),
          const Text(
            "Install it — no configuration needed. Takes ~2 minutes.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ]),

        _step(context, 2, "Download the recommended model", [
          _tip(context,
              "Run this in your terminal / PowerShell / Command Prompt:"),
          _codeBlock(context, "ollama pull $model"),
          Text(
            "Downloads $modelDesc. May take a few minutes depending on your internet.",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ]),

        _step(context, 3, "Start Ollama and allow WiFi access", [
          _tip(context,
              "By default Ollama only listens on localhost. Run this so your phone can reach it:"),
          const Text("Windows (PowerShell as Admin):",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          _codeBlock(context,
              r'$env:OLLAMA_HOST = "0.0.0.0:11434"' '\nollama serve'),
          const Text("Mac/Linux (Terminal):",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          _codeBlock(
              context, "OLLAMA_HOST=0.0.0.0:11434 ollama serve"),
        ]),

        _step(context, 4, "Find your computer's IP address", [
          const Text("Windows:",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          _codeBlock(context,
              "Open CMD → type: ipconfig\nLook for: IPv4 Address e.g. 192.168.1.5"),
          const Text("Mac:",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          _codeBlock(context,
              "System Settings → Wi-Fi → Details → IP Address"),
          _tip(context,
              "Your phone and PC must be on the same WiFi network."),
        ]),

        _step(context, 5, "Enter in SmartSpend", [
          _codeBlock(context,
              "Base URL:  http://192.168.1.5:11434/v1\n(replace with your IP)\n\nModel:  $model\n\nAPI Key:  (leave blank)"),
          _tip(context,
              "Go back → scroll up → enter the URL and model → tap Test Connection."),
        ]),
      ],
    );
  }

  Widget _lmStudioTab(BuildContext context) {
    final model = _modelRecs[_ramIndex];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tip(context,
            "LM Studio has a user-friendly GUI. Good if you prefer not using the terminal."),

        _step(context, 1, "Install LM Studio", [
          _codeBlock(context, "Download from: https://lmstudio.ai"),
          const Text("Available for Windows and Mac.",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),

        _step(context, 2, "Download a model inside LM Studio", [
          const Text(
            "Open LM Studio → click the search bar at top → search for:",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _codeBlock(context, _modelRecs[_ramIndex]),
          const Text(
            "Click a GGUF file → Download. Choose Q4_K_M for best balance of quality and speed.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ]),

        _step(context, 3, "Start the local server", [
          const Text(
            "In LM Studio → click \"Local Server\" tab (left sidebar) → select your downloaded model → click Start Server.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _tip(context,
              "Make sure 'Enable CORS' is ON so SmartSpend can reach it."),
        ]),

        _step(context, 4, "Find your IP and enter in SmartSpend", [
          _codeBlock(context,
              "Base URL:  http://192.168.1.5:1234/v1\n(replace with your PC's IP)\n\nModel:  $model\n\nAPI Key:  (leave blank)"),
          _tip(context,
              "LM Studio uses port 1234 by default (vs Ollama's 11434)."),
        ]),

        const SizedBox(height: 8),
        _tip(context,
            "LM Studio also has LM Link — lets you expose your server to your phone over internet without port forwarding. Settings → LM Link → Create Link."),
      ],
    );
  }

  Widget _janTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tip(context,
            "Jan is a fully open-source alternative to LM Studio. Same idea — download models via GUI, start a local server."),

        _step(context, 1, "Install Jan", [
          _codeBlock(context, "Download from: https://jan.ai"),
          const Text("Available for Windows, Mac, and Linux.",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),

        _step(context, 2, "Download a model in Jan", [
          const Text(
            "Open Jan → Hub tab → search for Qwen or Phi → Download.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ]),

        _step(context, 3, "Start the API server", [
          const Text(
            "In Jan → Local API Server tab → select model → Start Server.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _tip(context, "Jan uses port 1337 by default."),
        ]),

        _step(context, 4, "Enter in SmartSpend", [
          _codeBlock(context,
              "Base URL:  http://192.168.1.5:1337/v1\n(replace with your PC's IP)\n\nModel:  (whatever model you loaded)\n\nAPI Key:  (leave blank)"),
        ]),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: const Text(
            "⚠️  Ollama is generally the most stable option for SmartSpend's JSON-structured ACTION responses. Use LM Studio or Jan only if you prefer a GUI and have tested that the model outputs valid JSON reliably.",
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Column(children: [
        const SizedBox(height: 12),
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text("🏠 ", style: TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Local AI Setup Guide",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                      "Run an LLM on your PC — your data stays on your network",
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: "Ollama"),
            Tab(text: "LM Studio"),
            Tab(text: "Jan"),
          ],
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _ollamaTab(context),
              _lmStudioTab(context),
              _janTab(context),
            ],
          ),
        ),
      ]),
    );
  }
}
