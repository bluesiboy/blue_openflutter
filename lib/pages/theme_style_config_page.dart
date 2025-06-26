import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/theme_style_provider.dart';
import '../models/theme_style_config.dart';

class ThemeStyleConfigPage extends StatefulWidget {
  const ThemeStyleConfigPage({super.key});

  @override
  State<ThemeStyleConfigPage> createState() => _ThemeStyleConfigPageState();
}

class _ThemeStyleConfigPageState extends State<ThemeStyleConfigPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题样式配置'),
        scrolledUnderElevation: 0,
      ),
      body: Consumer<ThemeStyleProvider>(
        builder: (context, provider, child) {
          final config = provider.config;
          return ListView(
            children: [
              _buildSection(
                context,
                title: '主题样式',
                child: _buildStyleSelector(context, config, provider),
              ),
              _buildSection(
                context,
                title: '外观设置',
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context,
                      title: '纯黑背景',
                      subtitle: '在深色模式下使用纯黑色背景',
                      value: config.usePureBlack,
                      onChanged: (value) => provider.updatePureBlack(value),
                    ),
                    _buildSwitchTile(
                      context,
                      title: '动画效果',
                      subtitle: '启用主题切换动画',
                      value: config.enableAnimation,
                      onChanged: (value) => provider.updateAnimation(value),
                    ),
                    _buildSwitchTile(
                      context,
                      title: '自定义颜色',
                      subtitle: '使用自定义主题色',
                      value: config.enableCustomColor,
                      onChanged: (value) => provider.updateCustomColor(value),
                    ),
                    if (config.enableCustomColor) ...[
                      const SizedBox(height: 16),
                      _buildColorPicker(
                        context,
                        title: '主色调',
                        color: config.customPrimaryColor,
                        onColorChanged: (color) => provider.updateCustomColors(
                          primaryColor: color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildColorPicker(
                        context,
                        title: '辅助色',
                        color: config.customSecondaryColor,
                        onColorChanged: (color) => provider.updateCustomColors(
                          secondaryColor: color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 255 * 0.1),
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildStyleSelector(
    BuildContext context,
    ThemeStyleConfig config,
    ThemeStyleProvider provider,
  ) {
    return Column(
      children: ThemeStyleConfig.availableStyles.map((style) {
        return ListTile(
          title: Text(ThemeStyleConfig.getStyleName(style)),
          trailing: Radio<String>(
            value: style,
            groupValue: config.currentStyle,
            onChanged: (value) {
              if (value != null) {
                provider.updateStyle(value);
              }
            },
          ),
          onTap: () => provider.updateStyle(style),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 255 * 0.6),
            ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildColorPicker(
    BuildContext context, {
    required String title,
    required Color? color,
    required ValueChanged<Color> onColorChanged,
  }) {
    Color? tempColor = color;
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('选择$title'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: color ?? Theme.of(context).colorScheme.primary,
                onColorChanged: (color) {
                  tempColor = color;
                },
                enableAlpha: false,
                labelTypes: const [],
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  if (tempColor != null) {
                    onColorChanged(tempColor!);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      },
    );
  }
}
