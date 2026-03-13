import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _phoneCtrl.text.trim());
    if (!mounted) return;
    if (ok) context.go('/home');
    else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Registration failed'), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => context.go('/login'), icon: const Icon(Icons.arrow_back_rounded))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Create account', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text('Start your premium car rental journey', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 36),
                AppTextField(controller: _nameCtrl, label: 'Full Name', hint: 'John Doe', prefixIcon: Icons.person_outlined,
                  validator: (v) => v!.length >= 2 ? null : 'Enter your full name'),
                const SizedBox(height: 16),
                AppTextField(controller: _emailCtrl, label: 'Email address', hint: 'you@example.com', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined,
                  validator: (v) => v!.contains('@') ? null : 'Enter a valid email'),
                const SizedBox(height: 16),
                AppTextField(controller: _phoneCtrl, label: 'Phone Number', hint: '+1 234 567 8900', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined,
                  validator: (v) => v!.length >= 8 ? null : 'Enter a valid phone number'),
                const SizedBox(height: 16),
                AppTextField(controller: _passCtrl, label: 'Password', hint: '••••••••', obscureText: _obscure, prefixIcon: Icons.lock_outlined,
                  suffixIcon: _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixTap: () => setState(() => _obscure = !_obscure),
                  validator: (v) => v!.length >= 6 ? null : 'Password must be 6+ characters'),
                const SizedBox(height: 16),
                AppTextField(controller: _confirmCtrl, label: 'Confirm Password', hint: '••••••••', obscureText: true, prefixIcon: Icons.lock_outlined,
                  validator: (v) => v == _passCtrl.text ? null : 'Passwords do not match'),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => AppButton(label: 'Create Account', isLoading: auth.isLoading, onTap: _register),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text('Sign In', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
