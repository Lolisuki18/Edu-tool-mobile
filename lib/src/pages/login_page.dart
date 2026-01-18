import 'package:flutter/material.dart';
import 'package:edutool/src/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đăng nhập thành công: $_email')));
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FlutterLogo(size: 80),
                const SizedBox(height: 20),
                TextFormField(
                  key: const Key('email'),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Nhập email hợp lệ'
                      : null,
                  onSaved: (v) => _email = v ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('password'),
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mật khẩu >= 6 ký tự'
                      : null,
                  onSaved: (_) {},
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Đăng nhập'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chức năng quên mật khẩu chưa có'),
                    ),
                  ),
                  child: const Text('Quên mật khẩu?'),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Admin'),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainPage(role: 'Admin'),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.school),
                      label: const Text('Lecturer'),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainPage(role: 'Lecturer'),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.group),
                      label: const Text('Team Leader'),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainPage(role: 'Team Leader'),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person),
                      label: const Text('Member'),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainPage(role: 'Member'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
