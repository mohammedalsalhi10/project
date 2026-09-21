import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/account_model.dart';
import '../utils/encryption_helper.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _platformController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;

  
  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      
      final encryptedPassword = EncryptionHelper.encryptPassword(_passwordController.text);

      
      final newAccount = AccountModel(
        platformName: _platformController.text.trim(),
        username: _usernameController.text.trim(),
        password: encryptedPassword, 
      );

      
      await DatabaseHelper.instance.insertAccount(newAccount);

      if (!mounted) return;

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الحساب وتشفيره بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );

      
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة حساب جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
            
              TextFormField(
                controller: _platformController,
                decoration: InputDecoration(
                  labelText: 'اسم المنصة (مثال: Facebook)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.language),
                ),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المنصة' : null,
              ),
              const SizedBox(height: 16),

              
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم أو البريد',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المستخدم' : null,
              ),
              const SizedBox(height: 16),

              
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال كلمة المرور' : null,
              ),
              const SizedBox(height: 40),

              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveAccount,
                  child: const Text('حفظ في الخزنة', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}