import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/shared/widgets/academic_button.dart';
import 'package:edutool/shared/widgets/academic_input.dart';
import 'package:edutool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:edutool/features/auth/presentation/bloc/auth_event.dart';
import 'package:edutool/features/auth/presentation/bloc/auth_state.dart';

/// Registration screen — fullName, email, username, password.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    if (state is AuthRegisterSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: _onStateChanged,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tạo tài khoản',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đăng ký để bắt đầu sử dụng EduTool',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),

                    AcademicInput(
                      controller: _fullNameCtrl,
                      label: 'Họ và tên',
                      hintText: 'Nguyễn Văn A',
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    AcademicInput(
                      controller: _emailCtrl,
                      label: 'Email',
                      hintText: 'example@fpt.edu.vn',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+$',
                        ).hasMatch(value.trim())) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    AcademicInput(
                      controller: _usernameCtrl,
                      label: 'Tên đăng nhập',
                      hintText: 'username',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newUsername],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên đăng nhập';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    AcademicInput(
                      controller: _passwordCtrl,
                      label: 'Mật khẩu',
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu tối thiểu 6 ký tự';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AcademicButton(
                          text: 'Đăng ký',
                          type: ButtonType.primary,
                          isLoading: state is AuthLoading,
                          onPressed: _submit,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Đăng nhập',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
