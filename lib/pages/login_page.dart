import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _entrando = false;
  String? _erro;

  Future<void> _login() async {
    setState(() {
      _entrando = true;
      _erro = null;
    });
    try {
      await context.read<AuthProvider>().signIn();
    } catch (e) {
      if (mounted) {
        setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.bolt, size: 54, color: Color(0xFFA78BFA)),
                ),
                const SizedBox(height: 28),
                const Text(
                  'ESCOLA JUJUTSU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Acesso restrito para feiticeiros',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _entrando ? null : _login,
                    icon: _entrando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(_entrando ? 'Conectando...' : 'ENTRAR COM GOOGLE'),
                  ),
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 16),
                  Text(_erro!, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
