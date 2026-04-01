import 'package:flutter/material.dart';
import 'package:kantankanri/app/home_page.dart';
import 'package:kantankanri/providers/app_language_provider.dart';
import 'package:kantankanri/providers/app_lock_provider.dart';
import 'package:provider/provider.dart';

class AppLockGateScreen extends StatefulWidget {
  const AppLockGateScreen({super.key});

  @override
  State<AppLockGateScreen> createState() => _AppLockGateScreenState();
}

class _AppLockGateScreenState extends State<AppLockGateScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final lockProvider = Provider.of<AppLockProvider>(context, listen: false);
      final lang = Provider.of<AppLanguageProvider>(context, listen: false);
      final ok = await lockProvider.unlock(text);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.tr('wrong_lock_password'))),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline, size: 56),
                const SizedBox(height: 12),
                Text(
                  lang.tr('unlock_app'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: lang.tr('enter_lock_password'),
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(lang.tr('unlock_app')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

