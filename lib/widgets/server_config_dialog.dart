import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentUrl = context.read<ApiConfig>().baseUrl;
    _controller = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings_ethernet, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text('Configura Server Backend'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indirizzo IP e porta dove è in esecuzione il backend locale:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'URL Server',
                hintText: 'es. http://192.168.1.50:8000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            const Text(
              '• Emulatore Android: http://10.0.2.2:8000\n'
              '• Simulatore iOS / Mac: http://localhost:8000\n'
              '• Smartphone Wi-Fi reale: http://<IP_MAC>:8000',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () async {
            final newUrl = _controller.text.trim();
            if (newUrl.isNotEmpty) {
              await context.read<ApiConfig>().setBaseUrl(newUrl);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server impostato su: $newUrl')),
                );
              }
            }
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
