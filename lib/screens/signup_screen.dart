import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isObscure = true;
  bool _isConfirmObscure = true;

  double _passwordStrength = 0.0;
  Color _strengthColor = Colors.grey;
  String _strengthText = 'أدخل كلمة المرور';

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25; // الطول
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25; // حروف كبيرة
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25; // أرقام
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25; // رموز خاصة

    setState(() {
      _passwordStrength = strength;
      if (strength == 0) {
        _strengthColor = Colors.grey;
        _strengthText = 'أدخل كلمة المرور';
      } else if (strength <= 0.25) {
        _strengthColor = Colors.red;
        _strengthText = 'ضعيفة جداً';
      } else if (strength == 0.5) {
        _strengthColor = Colors.orange;
        _strengthText = 'متوسطة';
      } else if (strength == 0.75) {
        _strengthColor = Colors.blue;
        _strengthText = 'جيدة';
      } else {
        _strengthColor = Colors.green;
        _strengthText = 'قوية وممتازة';
      }
    });
  }

  
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      Random rnd = Random();
      String recoveryKey = String.fromCharCodes(
        Iterable.generate(
          16,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
        ),
      );

      recoveryKey =
          '${recoveryKey.substring(0, 4)}-${recoveryKey.substring(4, 8)}-${recoveryKey.substring(8, 12)}-${recoveryKey.substring(12, 16)}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', _usernameController.text);
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setString('recovery_key', recoveryKey); // حفظ المفتاح الجديد

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (context) => AlertDialog(
          title: const Text(
            'هام جداً! مفتاح الاسترداد',
            style: TextStyle(color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تم إنشاء حسابك بنجاح. هذا هو مفتاح استرداد حسابك. إذا نسيت كلمة المرور، فهذا هو طريقك الوحيد لفتح الخزنة.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  recoveryKey, 
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'الرجاء نسخه والاحتفاظ به في مكان آمن.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              child: const Text('لقد قمت بحفظ المفتاح'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إعداد الخزنة',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سيتم تشفير جميع بياناتك محلياً على هذا الجهاز.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'البريد الالكتروني',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      if (!value.contains('@')) {
                        return 'الرجاء إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    onChanged: (value) => _checkPasswordStrength(value),
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الرئيسية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _isObscure = !_isObscure),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      if (_passwordStrength < 0.5) {
                        return 'كلمة المرور ضعيفة جداً، استخدم أرقاماً وحروفاً';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: Colors.grey[300],
                          color: _strengthColor,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _strengthText,
                        style: TextStyle(
                          color: _strengthColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmObscure,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_clock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmObscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isConfirmObscure = !_isConfirmObscure,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء تأكيد كلمة المرور';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمتا المرور غير متطابقتين';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _signUp,
                      child: const Text(
                        'إنشاء الخزنة',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
