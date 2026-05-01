import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/module_core.dart';
import 'package:module_core/widget/logo/voc_logo.dart';
import 'package:module_core/widget/snackbar.dart';
import '../bloc/auth_bloc.dart';

class AuthSignup extends StatefulWidget {
  const AuthSignup({super.key});

  @override
  State<AuthSignup> createState() => _AuthSignupState();
}

class _AuthSignupState extends State<AuthSignup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthBloc>().state is Authenticated) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Validation ───────────────────────────────────────────────
  String? _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'Semua field harus diisi';
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }

    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus mengandung minimal 1 huruf kapital';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password harus mengandung minimal 1 angka';
    }

    if (password != confirmPassword) {
      return 'Password dan konfirmasi password tidak cocok';
    }

    return null; // valid
  }

  void _onSignUp() {
    final error = _validateInputs();
    if (error != null) {
      AppSnackbar.onInfo(context, error);
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    context.read<AuthBloc>().add(AuthRegisterEvent(email, password));
  }

  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.mark_email_unread_outlined,
          size: 48,
          color: Colors.black87,
        ),
        title: Text(
          context.tr('Verifikasi Email', 'Email Verification'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('Email verifikasi telah dikirim ke:', 'Verification email has been sent to:'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('Silakan cek inbox atau folder spam Gmail Anda, lalu klik link verifikasi sebelum login.', 'Please check your inbox or Gmail spam folder, then click the verification link before login.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/sign-in');
              },
              child: Text(context.tr('Mengerti, Ke Halaman Login', 'OK, Go to Login Page')),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: InkWell(
          onTap: () => context.go('/'),
          child: const VocLogo(imageWidth: 28, imageHeight: 28, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.onFailure(context, state.message);
          } else if (state is EmailVerificationSent) {
            _showVerificationDialog(state.email);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                return _buildDesktopLayout(isLoading);
              } else {
                return _buildMobileLayout(isLoading);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(bool isLoading) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 48.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VocLogo(imageWidth: 80, imageHeight: 80, fontSize: 24),
                const SizedBox(height: 16),
                Text(
                  context.tr('Buat akun untuk mulai berbelanja', 'Create account to start shopping'),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildTextFields(isLoading),
                const SizedBox(height: 32),
                _buildSignupButton(isLoading),
                const SizedBox(height: 16),
                _buildLoginText(centered: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(bool isLoading) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTextFields(isLoading),
            const SizedBox(height: 12),
            _buildLoginText(centered: false),
            const SizedBox(height: 32),
            _buildSignupButton(isLoading),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFields(bool isLoading) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black),
    );
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: context.tr('Email', 'Email'),
            hintStyle: const TextStyle(color: Colors.black54),
            suffixIcon: const Icon(
              Icons.alternate_email,
              color: Colors.black87,
              size: 22,
            ),
            contentPadding: padding,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: focusedBorder,
          ),
        ),
        const SizedBox(height: 16.0),
        // Password
        TextField(
          controller: _passwordController,
          obscureText: _isPasswordHidden,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: context.tr('Password (min. 8 karakter, huruf kapital & angka)', 'Password (min. 8 characters, uppercase & number)'),
            hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordHidden ? Icons.remove_red_eye : Icons.visibility_off,
                color: Colors.black87,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordHidden = !_isPasswordHidden;
                });
              },
            ),
            contentPadding: padding,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: focusedBorder,
          ),
        ),
        const SizedBox(height: 16.0),
        // Confirm Password
        TextField(
          controller: _confirmPasswordController,
          obscureText: _isConfirmPasswordHidden,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: context.tr('Konfirmasi Password', 'Confirm Password'),
            hintStyle: const TextStyle(color: Colors.black54),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordHidden
                    ? Icons.remove_red_eye
                    : Icons.visibility_off,
                color: Colors.black87,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                });
              },
            ),
            contentPadding: padding,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: focusedBorder,
          ),
        ),
        const SizedBox(height: 8),
        // Password hint
        Text(
          context.tr('• Min. 8 karakter  • 1 huruf kapital  • 1 angka', '• Min. 8 characters  • 1 uppercase letter  • 1 number'),
          style: const TextStyle(fontSize: 11, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _buildLoginText({required bool centered}) {
    return Align(
      alignment: centered ? Alignment.center : Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/login');
          }
        },
        child: RichText(
          text: TextSpan(
            text: context.tr('Sudah punya akun? ', 'Already have an account? '),
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(
                text: context.tr('Login', 'Login'),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : _onSignUp,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                context.tr('Sign Up', 'Sign Up'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
}
