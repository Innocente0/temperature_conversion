import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const ConverterPage(),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});
  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isFtoC = true;
  String _output = '';
  final List<String> _history = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  bool get _inputValid => double.tryParse(_inputController.text) != null;

  void _convert() {
    final input = double.parse(_inputController.text);
    double result = _isFtoC
        ? (input - 32) * 5 / 9
        : input * 9 / 5 + 32;
    final formatted = result.toStringAsFixed(2);
    setState(() {
      _output = formatted;
    });
    final entry = _isFtoC
        ? 'F to C: $input → $formatted'
        : 'C to F: $input → $formatted';
    _history.insert(0, entry);
    _listKey.currentState?.insertItem(0);
  }

  void _clearHistory() {
    for (int i = _history.length - 1; i >= 0; i--) {
      _history.removeAt(i);
      _listKey.currentState?.removeItem(
        i,
            (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: Container(),
        ),
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Simulated status bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30 + kToolbarHeight),
        child: Column(
          children: [
            Container(
              height: 30,
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TimeOfDay.now().format(context),
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.wifi, size: 16),
                      SizedBox(width: 6),
                      Icon(Icons.signal_cellular_alt, size: 16),
                      SizedBox(width: 6),
                      Icon(Icons.battery_full, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            AppBar(
              backgroundColor: Colors.lightBlue,
              title: const Text('Converter'),
              centerTitle: true,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.thermostat),
                      title: const Text('°F → °C'),
                      trailing: Radio<bool>(
                        value: true,
                        groupValue: _isFtoC,
                        onChanged: (v) => setState(() => _isFtoC = v!),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.ac_unit),
                      title: const Text('°C → °F'),
                      trailing: Radio<bool>(
                        value: false,
                        groupValue: _isFtoC,
                        onChanged: (v) => setState(() => _isFtoC = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _inputController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter value',
                  border: const OutlineInputBorder(),
                  errorText: _inputController.text.isEmpty || _inputValid
                      ? null
                      : 'Invalid number',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Text(
                _output.isEmpty ? '=' : '= $_output',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _inputValid ? _convert : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('CONVERT'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _history.isNotEmpty ? _clearHistory : null,
                child: const Text('CLEAR HISTORY'),
              ),
              const SizedBox(height: 16),
              const Text('History:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  initialItemCount: _history.length,
                  itemBuilder: (context, index, animation) {
                    final item = _history[index];
                    return SizeTransition(
                      sizeFactor: animation,
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
