import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordLogin = false;
  int _countdown = 0;
  Timer? _timer;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final List<FocusNode> _verificationFocusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _verificationControllers = List.generate(6, (_) => TextEditingController());
  String _selectedCountryCode = '+86';
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _isPhoneValid = phone.length == 11;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    for (var node in _verificationFocusNodes) {
      node.dispose();
    }
    for (var controller in _verificationControllers) {
      controller.dispose();
    }
    super.dispose();
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
                  _buildVerificationCodeInput(theme),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _countdown > 0
                            ? null
                            : () {
                                // TODO: 实现发送验证码功能
                                _startCountdown();
                              },
                        child: Text(
                          _countdown > 0 ? '${_countdown}秒后重试' : '获取验证码',
                          style: TextStyle(
                            color:
                                _countdown > 0 ? theme.colorScheme.onSurface.withAlpha(153) : theme.colorScheme.primary,
                          ),
                        ),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.2,
                  ),
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

  Widget _buildVerificationCodeInput(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return Container(
            width: 36,
            height: 48,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _verificationControllers[index].text.isEmpty
                      ? theme.colorScheme.outline.withAlpha(51)
                      : theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    _verificationControllers[index].text.isEmpty &&
                    index > 0) {
                  _verificationFocusNodes[index - 1].requestFocus();
                  _verificationControllers[index - 1].clear();
                  // 更新验证码
                  String code = '';
                  for (var controller in _verificationControllers) {
                    code += controller.text;
                  }
                  _verificationCodeController.text = code;
                  setState(() {});
                }
              },
              child: TextField(
                controller: _verificationControllers[index],
                focusNode: _verificationFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: theme.textTheme.titleLarge,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  // 找到第一个空的输入框
                  int firstEmptyIndex = 0;
                  for (int i = 0; i < _verificationControllers.length; i++) {
                    if (_verificationControllers[i].text.isEmpty) {
                      firstEmptyIndex = i;
                      break;
                    }
                  }
                  _verificationFocusNodes[firstEmptyIndex].requestFocus();
                },
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _verificationFocusNodes[index + 1].requestFocus();
                  }
                  // 更新验证码
                  String code = '';
                  for (var controller in _verificationControllers) {
                    code += controller.text;
                  }
                  _verificationCodeController.text = code;
                  setState(() {}); // 触发重绘以更新下划线颜色
                },
                onEditingComplete: () {
                  if (index < 5) {
                    _verificationFocusNodes[index + 1].requestFocus();
                  }
                },
                onSubmitted: (value) {
                  if (index < 5) {
                    _verificationFocusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 实现登录功能
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '登录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
