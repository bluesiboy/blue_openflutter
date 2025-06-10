import 'package:blue_openflutter/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:blue_openflutter/controls/verification_code_input.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isPasswordLogin = false;
  int _countdown = 0;
  Timer? _timer;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late final VerificationCodeController _verificationCodeController;
  String _selectedCountryCode = '+86';
  bool _isPhoneValid = false;
  bool _isCodeValid = false;
  bool _showGlow = false;
  int _breathCount = 0;

  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _verificationCodeController = VerificationCodeController(
      length: 6,
      onCodeChanged: _validateCode,
    );

    _breathController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _breathAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathCount++;
        if (_breathCount > 2) {
          _breathController.stop();
          _breathCount = 0;
          setState(() => _showGlow = false);
        } else {
          _breathController.reverse();
        }
      } else if (status == AnimationStatus.dismissed && _breathCount < 2) {
        _breathController.forward();
      }
    });

    _phoneController.addListener(() {
      if (_isPhoneValid && _countdown == 0) {
        if (!_breathController.isAnimating) {
          _breathCount = 0;
          setState(() => _showGlow = true);
          _breathController.forward();
        }
      } else {
        _breathController.stop();
        _breathCount = 0;
        setState(() => _showGlow = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    setState(() => _isPhoneValid = phone.length == 11);
  }

  void _validateCode(String code) {
    setState(() => _isCodeValid = code.length == _verificationCodeController.length);
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height - MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildThemeAction(context),
                const SizedBox(height: 48),
                Text(
                  '欢迎回来',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请选择登录方式',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 48),
                _buildPhoneInput(theme),
                const SizedBox(height: 24),
                if (_isPasswordLogin) ...[
                  _buildPasswordInput(theme),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: 实现忘记密码功能
                      },
                      child: Text(
                        '忘记密码？',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  VerificationCodeInput(controller: _verificationCodeController),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedBuilder(
                        animation: _breathAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _showGlow && _isPhoneValid && _countdown == 0
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(_breathAnimation.value),
                                        blurRadius: _breathAnimation.value * 6,
                                        spreadRadius: _breathAnimation.value * 0.5,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: TextButton(
                              onPressed: _countdown > 0 ? null : _startCountdown,
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: Text(
                                _countdown > 0 ? '${_countdown}秒后重试' : '获取验证码',
                                style: TextStyle(
                                  color: _countdown > 0
                                      ? theme.colorScheme.onSurface.withAlpha(153)
                                      : _isPhoneValid
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.primary.withOpacity(0.5),
                                  fontWeight: _isPhoneValid ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                _buildLoginButton(theme),
                const SizedBox(height: 24),
                _buildLoginModeSwitch(theme),
                const Spacer(),
                _buildRegisterSection(theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildThemeAction(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<AdaptiveThemeMode>(
        icon: Icon(
          AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
              ? Icons.light_mode
              : AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.brightness_auto,
        ),
        onSelected: (AdaptiveThemeMode mode) {
          switch (mode) {
            case AdaptiveThemeMode.light:
              AdaptiveTheme.of(context).setLight();
              break;
            case AdaptiveThemeMode.dark:
              AdaptiveTheme.of(context).setDark();
              break;
            case AdaptiveThemeMode.system:
              AdaptiveTheme.of(context).setSystem();
              break;
          }
        },
        itemBuilder: (BuildContext context) => const [
          PopupMenuItem<AdaptiveThemeMode>(
            value: AdaptiveThemeMode.light,
            child: Row(
              children: [
                Icon(Icons.light_mode, size: 20),
                SizedBox(width: 8),
                Text('浅色模式'),
              ],
            ),
          ),
          PopupMenuItem<AdaptiveThemeMode>(
            value: AdaptiveThemeMode.dark,
            child: Row(
              children: [
                Icon(Icons.dark_mode, size: 20),
                SizedBox(width: 8),
                Text('深色模式'),
              ],
            ),
          ),
          PopupMenuItem<AdaptiveThemeMode>(
            value: AdaptiveThemeMode.system,
            child: Row(
              children: [
                Icon(Icons.brightness_auto, size: 20),
                SizedBox(width: 8),
                Text('跟随系统'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isPhoneValid ? theme.colorScheme.primary : theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withAlpha(51),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      ListTile(
                        leading: const Text('🇨🇳', style: TextStyle(fontSize: 20)),
                        title: const Text('中国', style: TextStyle(fontSize: 16)),
                        trailing: const Text('+86', style: TextStyle(fontSize: 16)),
                        selected: _selectedCountryCode == '+86',
                        onTap: () {
                          setState(() => _selectedCountryCode = '+86');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Text('🇭🇰', style: TextStyle(fontSize: 20)),
                        title: const Text('香港', style: TextStyle(fontSize: 16)),
                        trailing: const Text('+852', style: TextStyle(fontSize: 16)),
                        selected: _selectedCountryCode == '+852',
                        onTap: () {
                          setState(() => _selectedCountryCode = '+852');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Text('🇲🇴', style: TextStyle(fontSize: 20)),
                        title: const Text('澳门', style: TextStyle(fontSize: 16)),
                        trailing: const Text('+853', style: TextStyle(fontSize: 16)),
                        selected: _selectedCountryCode == '+853',
                        onTap: () {
                          setState(() => _selectedCountryCode = '+853');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outline.withAlpha(51),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCountryCode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 1.2, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: '请输入手机号',
                    hintStyle: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                      letterSpacing: 1.2,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;
                      final text = newValue.text;
                      final buffer = StringBuffer();
                      for (int i = 0; i < text.length; i++) {
                        if (i == 3 || i == 7) {
                          buffer.write(' ');
                        }
                        buffer.write(text[i]);
                      }
                      return TextEditingValue(
                        text: buffer.toString(),
                        selection: TextSelection.collapsed(offset: buffer.length),
                      );
                    }),
                  ],
                ),
                if (_phoneController.text.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _phoneController.clear();
                        },
                        child: Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.clear,
                            color: theme.colorScheme.onSurface.withAlpha(153),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        style: theme.textTheme.titleMedium,
        decoration: InputDecoration(
          hintText: '请输入密码',
          hintStyle: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginModeSwitch(ThemeData theme) {
    return TextButton(
      onPressed: () {
        setState(() {
          _isPasswordLogin = !_isPasswordLogin;
        });
      },
      child: Text(
        _isPasswordLogin ? '使用验证码登录' : '使用密码登录',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  bool _islogin = false;
  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: RoundedLoadingButton(
        color: theme.colorScheme.primary,
        controller: _btnController,
        onPressed: _isCodeValid || _isPhoneValid
            ? () async {
                setState(() {
                  _islogin = true;
                });
                await Future.delayed(Durations.long4);
                setState(() {
                  _islogin = true;
                });
                _btnController.success();
                await Future.delayed(Durations.medium4);
                if (mounted) Navigator.pushReplacementNamed(context, AppRouter.home);
              }
            : null,
        child: Text(
          '登录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterSection(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: 实现注册功能
          },
          child: Text(
            '立即注册',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
