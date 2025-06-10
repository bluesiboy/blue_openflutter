import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerificationCodeController {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final int length;
  final Function(String)? onCodeChanged;

  VerificationCodeController({
    required this.length,
    this.onCodeChanged,
  }) {
    _controllers.addAll(List.generate(length, (_) => TextEditingController()));
    _focusNodes.addAll(List.generate(length, (_) => FocusNode()));
  }

  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    _updateCode();
  }

  void focus() {
    // 找到第一个空的输入框
    int firstEmptyIndex = 0;
    bool allFilled = true;
    for (int i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text.isEmpty) {
        firstEmptyIndex = i;
        allFilled = false;
        break;
      }
    }
    print('$allFilled $firstEmptyIndex');
    // 如果所有输入框都有数字，则焦点保持在最后一个
    if (allFilled) {
      _focusNodes[length - 1].requestFocus();
    } else {
      _focusNodes[firstEmptyIndex].requestFocus();
    }
  }

  void _updateCode() {
    String code = '';
    for (var controller in _controllers) {
      code += controller.text;
    }
    if (onCodeChanged != null) onCodeChanged!(code);
  }

  List<TextEditingController> get controllers => _controllers;
  List<FocusNode> get focusNodes => _focusNodes;
}

class VerificationCodeInput extends StatefulWidget {
  final VerificationCodeController controller;
  final double itemWidth;
  final double itemHeight;
  final double itemSpacing;
  final double borderWidth;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const VerificationCodeInput({
    super.key,
    required this.controller,
    this.itemWidth = 36,
    this.itemHeight = 48,
    this.itemSpacing = 8,
    this.borderWidth = 2,
    this.textStyle,
    this.padding,
  });

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = widget.textStyle ?? theme.textTheme.titleLarge;

    return Container(
      width: double.infinity,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.controller.length, (index) {
          return Container(
            width: widget.itemWidth,
            height: widget.itemHeight,
            margin: EdgeInsets.only(right: index < widget.controller.length - 1 ? widget.itemSpacing : 0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.controller.controllers[index].text.isEmpty
                      ? theme.colorScheme.outline.withAlpha(51)
                      : theme.colorScheme.primary,
                  width: widget.borderWidth,
                ),
              ),
            ),
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    widget.controller.controllers[index].text.isEmpty &&
                    index > 0) {
                  widget.controller.focusNodes[index - 1].requestFocus();
                  widget.controller.controllers[index - 1].clear();
                  widget.controller._updateCode();
                  setState(() {});
                }
              },
              child: TextField(
                enableInteractiveSelection: false,
                controller: widget.controller.controllers[index],
                focusNode: widget.controller.focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: textStyle,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  widget.controller.focus();
                },
                onChanged: (value) {
                  if (value.isNotEmpty && index < widget.controller.length - 1) {
                    widget.controller.focusNodes[index + 1].requestFocus();
                  }
                  widget.controller._updateCode();
                  setState(() {});
                },
                onEditingComplete: () {
                  if (index < widget.controller.length - 1) {
                    widget.controller.focusNodes[index + 1].requestFocus();
                  }
                },
                onSubmitted: (value) {
                  if (index < widget.controller.length - 1) {
                    widget.controller.focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
