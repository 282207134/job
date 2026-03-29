import 'package:flutter/material.dart';

import '../controllers/signup_controller.dart';

/// 新規登録（白ベース・カード型レイアウト）
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _name = TextEditingController();

  bool _isLoading = false;

  void _revalidateConfirmPassword() {
    if (_confirmPassword.text.isEmpty) return;
    _confirmPasswordFieldKey.currentState?.validate();
  }

  static const _radius = 14.0;

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 22),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  void initState() {
    super.initState();
    _password.addListener(_revalidateConfirmPassword);
  }

  @override
  void dispose() {
    _password.removeListener(_revalidateConfirmPassword);
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await SignupController.createAccount(
        context: context,
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'アカウント作成',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'メールとパスワードで登録してください',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Material(
                  color: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: _fieldDecoration(
                            label: 'メールアドレス',
                            icon: Icons.mail_outline_rounded,
                            hint: 'example@email.com',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'メールアドレスを入力してください';
                            if (!v.contains('@')) return '有効なメール形式で入力してください';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: _fieldDecoration(
                            label: 'パスワード',
                            icon: Icons.lock_outline_rounded,
                            hint: '6文字以上を推奨',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを入力してください';
                            }
                            if (value.length < 6) {
                              return '6文字以上にしてください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          key: _confirmPasswordFieldKey,
                          controller: _confirmPassword,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: _fieldDecoration(
                            label: 'パスワード（確認）',
                            icon: Icons.lock_person_outlined,
                            hint: 'もう一度入力',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '確認用パスワードを入力してください';
                            }
                            if (value != _password.text) {
                              return 'パスワードが一致しません';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _name,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.words,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: _fieldDecoration(
                            label: 'お名前',
                            icon: Icons.person_outline_rounded,
                          ),
                          onFieldSubmitted: (_) => _submit(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'お名前を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF5C6BC0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_radius),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'ユーザ登録',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
