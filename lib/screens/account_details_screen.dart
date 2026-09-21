import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../database/database_helper.dart';
import '../models/account_model.dart';
import '../utils/encryption_helper.dart';

class AccountDetailsScreen extends StatefulWidget {
  final AccountModel account;

  const AccountDetailsScreen({super.key, required this.account});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool _isPasswordRevealed = false;
  late String _displayedPassword;

  @override
  void initState() {
    super.initState();
    
    _displayedPassword = widget.account.password;
  }

  
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordRevealed = !_isPasswordRevealed;
      if (_isPasswordRevealed) {
        
        _displayedPassword = EncryptionHelper.decryptPassword(widget.account.password);
      } else {
        
        _displayedPassword = widget.account.password;
      }
    });
  }

  
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد أنك تريد حذف بيانات حساب "${widget.account.platformName}"؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);

              await DatabaseHelper.instance.deleteAccount(widget.account.id!);

              if (!mounted) return;

              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف الحساب بنجاح'),
                  backgroundColor: Colors.redAccent,
                ),
              );

              
              Navigator.pop(context, true);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  
  void _copyToClipboard() {
    
    final realPassword = EncryptionHelper.decryptPassword(widget.account.password);
    Clipboard.setData(ClipboardData(text: realPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ كلمة المرور'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.platformName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: const Text('اسم المستخدم / البريد', style: TextStyle(color: Colors.grey, fontSize: 12)),
                subtitle: Text(widget.account.username, style: const TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 16),

            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('كلمة المرور', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _displayedPassword,
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: _isPasswordRevealed ? 1.0 : 2.0,
                              color: _isPasswordRevealed ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                        ),
                        
                        IconButton(
                          icon: Icon(_isPasswordRevealed ? Icons.visibility_off : Icons.visibility, color: Colors.deepPurple),
                          onPressed: _togglePasswordVisibility,
                        ),
                        
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.deepPurple),
                          onPressed: _copyToClipboard,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(), 

            // زر الحذف
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('حذف هذا الحساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _confirmDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}