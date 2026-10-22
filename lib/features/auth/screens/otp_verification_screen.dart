import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/farmer_model.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/widgets/khedut_button.dart';
import 'reset_password_screen.dart';

enum OtpFlow { registration, login, forgotPassword }

class OtpScreenArgs {
  final String phoneNumber;
  final OtpFlow flow;
  final FarmerModel? pendingFarmer;

  const OtpScreenArgs({
    required this.phoneNumber,
    this.flow = OtpFlow.registration,
    this.pendingFarmer,
  });
}

class OtpVerificationScreen extends StatefulWidget {
  final OtpScreenArgs? args;

  const OtpVerificationScreen({super.key, this.args});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<String> _otpDigits = ['', '', '', ''];
  int _resendSeconds = 45;
  Timer? _timer;
  String? _errorMessage;
  late String _phoneNumber;
  late OtpFlow _flow;
  FarmerModel? _pendingFarmer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalArgs = ModalRoute.of(context)?.settings.arguments;
    if (widget.args != null) {
      _phoneNumber = widget.args!.phoneNumber;
      _flow = widget.args!.flow;
      _pendingFarmer = widget.args!.pendingFarmer;
    } else if (modalArgs is OtpScreenArgs) {
      _phoneNumber = modalArgs.phoneNumber;
      _flow = modalArgs.flow;
      _pendingFarmer = modalArgs.pendingFarmer;
    } else if (modalArgs is Map<String, dynamic>) {
      _phoneNumber = modalArgs['phone'] ?? '+91 98765 43210';
      _flow = modalArgs['flow'] ?? OtpFlow.registration;
      _pendingFarmer = modalArgs['farmer'];
    } else {
      _phoneNumber = '+91 98765 43210';
      _flow = OtpFlow.registration;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _resendSeconds = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      _errorMessage = null;
    });

    if (key == 'backspace') {
      for (int i = 3; i >= 0; i--) {
        if (_otpDigits[i].isNotEmpty) {
          setState(() {
            _otpDigits[i] = '';
          });
          break;
        }
      }
    } else if (key == '*') {
      // no-op
    } else {
      for (int i = 0; i < 4; i++) {
        if (_otpDigits[i].isEmpty) {
          setState(() {
            _otpDigits[i] = key;
          });
          break;
        }
      }
    }
  }

  void _onResendOtp() {
    if (_resendSeconds > 0) return;
    setState(() {
      for (int i = 0; i < 4; i++) {
        _otpDigits[i] = '';
      }
      _errorMessage = null;
    });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A fresh 4-digit OTP has been sent to $_phoneNumber'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onVerify() {
    final enteredOtp = _otpDigits.join();

    if (enteredOtp.length < 4) {
      setState(() {
        _errorMessage = 'Please enter all 4 digits of the OTP';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    if (_flow == OtpFlow.forgotPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(phoneNumber: _phoneNumber),
        ),
      );
    } else {
      // Registration or Login flow
      if (_pendingFarmer != null) {
        FarmerService.instance.register(_pendingFarmer!);
      } else if (!FarmerService.instance.isAuthenticated) {
        FarmerService.instance.login(_phoneNumber, '1234');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification successful! Welcome to KhedutRise.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = ((screenWidth - 48 - (3 * 12)) / 4).clamp(48.0, 60.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('OTP Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Green Card Icon
              Container(
                width: 60,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryDark, width: 2.5),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Icon(
                        Icons.check,
                        color: AppColors.primaryDark,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Enter Verification Code',
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'We have sent a 4-digit OTP to',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _phoneNumber,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),

              // 4 OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final digit = _otpDigits[index];
                  final isFocused =
                      _otpDigits.indexWhere((d) => d.isEmpty) == index;
                  return Container(
                    width: boxSize,
                    height: boxSize,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: digit.isNotEmpty
                            ? AppColors.primaryDark
                            : (isFocused
                                  ? AppColors.primary
                                  : AppColors.borderInput),
                        width: digit.isNotEmpty ? 2 : 1.5,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      digit,
                      style: AppTypography.display.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Resend prompt
              Text(
                "Didn't receive OTP?",
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _resendSeconds == 0 ? _onResendOtp : null,
                child: Text(
                  _resendSeconds > 0
                      ? 'Resend OTP in ${_resendSeconds}s'
                      : 'Resend OTP Now',
                  style: AppTypography.bodySmall.copyWith(
                    color: _resendSeconds > 0
                        ? AppColors.textSecondary
                        : AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    decoration: _resendSeconds == 0
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Numeric keypad
              _buildKeypad(),
              const SizedBox(height: 20),

              // Button
              KhedutButton(text: 'Verify & Continue', onPressed: _onVerify),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeyRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildKeyRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildKeyRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildKeyRow(['*', '0', 'backspace']),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onKeyPress(key),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 72,
              height: 48,
              alignment: Alignment.center,
              child: key == 'backspace'
                  ? const Icon(
                      Icons.backspace_outlined,
                      color: AppColors.textPrimary,
                      size: 24,
                    )
                  : (key == '*'
                        ? const Text(
                            '•',
                            style: TextStyle(fontSize: 22, color: Colors.grey),
                          )
                        : Text(
                            key,
                            style: AppTypography.titleLarge.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          )),
            ),
          ),
        );
      }).toList(),
    );
  }
}
