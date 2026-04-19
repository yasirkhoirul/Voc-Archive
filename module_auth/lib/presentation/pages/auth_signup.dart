import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: InkWell(
          onTap: () => context.go('/'),
          child: const VocLogo(
            imageWidth: 28,
            imageHeight: 28,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.onFailure(context, state.message);
          } else if (state is Authenticated) {
            AppSnackbar.onSuccess(context, 'Registrasi berhasil!');
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
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
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VocLogo(
                  imageWidth: 80,
                  imageHeight: 80,
                  fontSize: 24,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please enter your email and password to sign up',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
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
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTextFields(isLoading),
                  const SizedBox(height: 12),
                  _buildLoginText(centered: false),
                  const Spacer(),
                  _buildSignupButton(isLoading),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFields(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            hintStyle: const TextStyle(color: Colors.black54),
            suffixIcon: const Icon(Icons.alternate_email, color: Colors.black87, size: 22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: const TextStyle(color: Colors.black54),
            suffixIcon: const Icon(Icons.remove_red_eye, color: Colors.black87, size: 22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          enabled: !isLoading,
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
            // Sesuaikan route jika ada route /login terpisah
            context.go('/login');
          }
        },
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(
                text: 'Login',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
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
        onPressed: isLoading
            ? null
            : () {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  AppSnackbar.onInfo(
                    context,
                    'Email dan Password tidak boleh kosong',
                  );
                  return;
                }

                context.read<AuthBloc>().add(
                  AuthRegisterEvent(email, password),
                );
              },
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
}

