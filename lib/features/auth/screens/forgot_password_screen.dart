import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../core/widgets/khedut_text_field.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneOrEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    super.dispose();
  }

  void _onSendCode() {
    if (_isLoading) return;

    final text = _phoneOrEmailController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your registered mobile number or email';
      });
      return;
    }

    final idErr = AppValidators.validateIdentifier(text);
    if (idErr != null) {
      setState(() {
        _errorMessage = idErr;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification OTP sent to $text'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushNamed(
      '/otp',
      arguments: OtpScreenArgs(phoneNumber: text, flow: OtpFlow.forgotPassword),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Lock Emblem Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 46,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Reset Your Password',
                  style: AppTypography.headline.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the mobile number or email linked to your account. We will send you an OTP to verify your identity.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Mobile / Email input
                KhedutTextField(
                  label: 'REGISTERED MOBILE / EMAIL',
                  controller: _phoneOrEmailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.phone_android,
                    color: AppColors.primaryDark,
                  ),
                  hintText: 'e.g. 98765 43210 or farmer@example.com',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your registered mobile number or email';
                    }
                    return null;
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                // Send Code Button
                KhedutButton(
                  text: _isLoading
                      ? 'Sending Code...'
                      : 'Send Verification Code',
                  onPressed: _onSendCode,
                ),
                const SizedBox(height: 24),

                // Back to Login
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Remember your password? ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
