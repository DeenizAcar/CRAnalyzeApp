import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tagController = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _analyze() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) {
      setState(() => _status = 'Bir oyuncu tag\'i gir (#ile başlamalı).');
      return;
    }
    setState(() => _status = 'TODO: $tag analiz edilecek.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CR Analyze — Anti-Deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rakip oyuncu tag\'ini gir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagController,
              decoration: const InputDecoration(
                hintText: '#XXXXXXXX',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _analyze(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _analyze,
              child: const Text('Analiz Et'),
            ),
            const SizedBox(height: 24),
            if (_status != null)
              Text(_status!, style: const TextStyle(color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}
