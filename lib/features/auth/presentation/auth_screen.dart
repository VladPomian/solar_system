import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ar/features/auth/domain/services/auth_service.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/features/auth/presentation/auth_check_page.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {

  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Вход' : 'Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              enabled: !_isLoading,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              enabled: !_isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin
                  ? 'Нет аккаунта? Зарегистрироваться'
                  : 'Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!mounted) return;

    setState(() {
      _error = '';
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'Заполните все поля';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      if (_isLogin) {
        await _authService.signIn(email, password);
      } else {
        await _authService.signUp(email, password);
      }

      // Навигация только если виджет всё ещё жив
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AuthCheckPage(
            onThemeChanged: context.read<SettingsProvider>().setTheme,
            isDarkTheme: context.read<SettingsProvider>().isDarkTheme,
            onFontSizeChanged: context.read<SettingsProvider>().setFontSize,
            fontSize: context.read<SettingsProvider>().fontSize,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMsg;

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          errorMsg = 'Неверный email или пароль';
          break;
        case 'email-already-in-use':
          errorMsg = 'Email уже используется';
          break;
        case 'weak-password':
          errorMsg = 'Пароль слишком слабый (минимум 6 символов)';
          break;
        case 'invalid-email':
          errorMsg = 'Некорректный формат email';
          break;
        case 'too-many-requests':
          errorMsg = 'Слишком много попыток. Попробуйте позже';
          break;
        default:
          errorMsg = e.message ?? 'Ошибка авторизации';
      }

      if (mounted) {
        setState(() => _error = errorMsg);
      }
    } catch (e) {
      if (!mounted) return;

      if (mounted) {
        setState(() => _error = 'Произошла ошибка: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}