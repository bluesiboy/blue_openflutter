import 'dart:io';

import 'package:blue_openflutter/models/theme_style_config.dart';
import 'package:blue_openflutter/providers/theme_style_provider.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const String themeTitle = "个性化";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: '通用设置',
            children: [
              _buildThemeSetting(context),
              _buildLanguageSetting(context),
              _buildNotificationSetting(context),
            ],
          ),
          _buildSection(
            context,
            title: '账号与安全',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.lock_outline,
                title: '修改密码',
                onTap: () {
                  // TODO: 实现修改密码功能
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.phone_android_outlined,
                title: '绑定手机',
                onTap: () {
                  // TODO: 实现绑定手机功能
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: '关于',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.info_outline,
                title: '关于我们',
                onTap: () {
                  // TODO: 实现关于我们页面
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.description_outlined,
                title: '用户协议',
                onTap: () {
                  // TODO: 实现用户协议页面
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: () {
                  // TODO: 实现隐私政策页面
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                // TODO: 实现退出登录功能
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('退出登录'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
    var lightWidget = const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.light_mode, size: 20),
        SizedBox(width: 8),
        Text('浅色模式'),
      ],
    );
    var darkWidget = const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.dark_mode, size: 20),
        SizedBox(width: 8),
        Text('深色模式'),
      ],
    );
    var systemWidget = const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.brightness_auto, size: 20),
        SizedBox(width: 8),
        Text('跟随系统'),
      ],
    );

    Widget getCurrentThemeWidget() {
      final currentMode = AdaptiveTheme.of(context).mode;
      if (currentMode == AdaptiveThemeMode.light) {
        return lightWidget;
      } else if (currentMode == AdaptiveThemeMode.dark) {
        return darkWidget;
      } else {
        return systemWidget;
      }
    }

    return _buildSettingItem(
      context,
      icon: Icons.palette_outlined,
      title: '主题设置',
      trailing: getCurrentThemeWidget(),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('选择主题'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: lightWidget,
                    onTap: () {
                      AdaptiveTheme.of(context).setLight();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: darkWidget,
                    onTap: () {
                      AdaptiveTheme.of(context).setDark();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: systemWidget,
                    onTap: () {
                      AdaptiveTheme.of(context).setSystem();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
    return _buildSettingItem(
      context,
      icon: Icons.language_outlined,
      title: '语言设置',
      trailing: const Text('简体中文'),
      onTap: () {
        // TODO: 实现语言设置功能
      },
    );
  }

  final mc = const MethodChannel('notification_settings');
  Widget _buildNotificationSetting(BuildContext context) {
    return _buildSettingItem(
      context,
      icon: Icons.notifications_outlined,
      title: '通知设置',
      onTap: () async {
        // 跳转到系统通知设置界面
        try {
          await mc.invokeMethod('openNotificationSettings');
        } catch (e) {
          SmartDialog.showToast('打开失败$e');
        }
      },
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildColorPicker(
    BuildContext context, {
    required String title,
    required Color? color,
    required ValueChanged<Color> onColorChanged,
  }) {
    Color? tempColor = color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color ?? Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.color_lens,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    String? subTitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
      ),
      subtitle: subTitle == null
          ? null
          : Text(
              subTitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
      value: value,
      onChanged: onChanged,
    );
  }

  Padding _buildSubTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  /// Material 主题
  Widget _buildMaterialThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMaterialThemeCard(
            context,
            title: '跟随系统',
            icon: Icons.brightness_auto,
            value: AdaptiveThemeMode.system,
            groupValue: currentTheme,
            onChanged: (value) {
              AdaptiveTheme.of(context).setSystem();
            },
          ),
          _buildMaterialThemeCard(
            context,
            title: '浅色',
            icon: Icons.brightness_7,
            value: AdaptiveThemeMode.light,
            groupValue: currentTheme,
            onChanged: (value) {
              AdaptiveTheme.of(context).setLight();
            },
          ),
          _buildMaterialThemeCard(
            context,
            title: '深色',
            icon: Icons.brightness_4,
            value: AdaptiveThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (value) {
              AdaptiveTheme.of(context).setDark();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialThemeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AdaptiveThemeMode value,
    required AdaptiveThemeMode? groupValue,
    required ValueChanged<AdaptiveThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///iOS 主题
  Widget _buildIOSThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;

    return Column(
      children: [
        _buildIOSThemeOption(
          context,
          title: '跟随系统',
          value: AdaptiveThemeMode.system,
          groupValue: currentTheme,
          onChanged: (value) {
            AdaptiveTheme.of(context).setSystem();
          },
        ),
        _buildDivider(context),
        _buildIOSThemeOption(
          context,
          title: '浅色',
          value: AdaptiveThemeMode.light,
          groupValue: currentTheme,
          onChanged: (value) {
            AdaptiveTheme.of(context).setLight();
          },
        ),
        _buildDivider(context),
        _buildIOSThemeOption(
          context,
          title: '深色',
          value: AdaptiveThemeMode.dark,
          groupValue: currentTheme,
          onChanged: (value) {
            AdaptiveTheme.of(context).setDark();
          },
        ),
      ],
    );
  }

  Widget _buildIOSThemeOption(
    BuildContext context, {
    required String title,
    required AdaptiveThemeMode value,
    required AdaptiveThemeMode? groupValue,
    required ValueChanged<AdaptiveThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const Spacer(),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).dividerColor.withOpacity(0.08),
    );
  }

  ///开关式主题
  Widget _buildSwitchThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;
    final isDarkMode = currentTheme == AdaptiveThemeMode.dark;
    final isSystemMode = currentTheme == AdaptiveThemeMode.system;

    return Column(
      children: [
        _buildSwitchOption(
          context,
          title: '深色模式',
          value: isDarkMode,
          onChanged: (value) {
            if (value) {
              AdaptiveTheme.of(context).setDark();
            } else {
              AdaptiveTheme.of(context).setLight();
            }
          },
        ),
        _buildDivider(context),
        _buildSwitchOption(
          context,
          title: '跟随系统',
          value: isSystemMode,
          onChanged: (value) {
            if (value) {
              AdaptiveTheme.of(context).setSystem();
            } else {
              AdaptiveTheme.of(context).setLight();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSwitchOption(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const Spacer(),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///分段式主题
  Widget _buildSegmentedThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;
    int selectedIndex = 0;

    if (currentTheme == AdaptiveThemeMode.light) {
      selectedIndex = 1;
    } else if (currentTheme == AdaptiveThemeMode.dark) {
      selectedIndex = 2;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildSegmentedOption(
              context,
              title: '系统',
              isSelected: selectedIndex == 0,
              onTap: () {
                AdaptiveTheme.of(context).setSystem();
              },
            ),
            _buildSegmentedOption(
              context,
              title: '浅色',
              isSelected: selectedIndex == 1,
              onTap: () {
                AdaptiveTheme.of(context).setLight();
              },
            ),
            _buildSegmentedOption(
              context,
              title: '深色',
              isSelected: selectedIndex == 2,
              onTap: () {
                AdaptiveTheme.of(context).setDark();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///滑块式主题
  Widget _buildSliderThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;
    double value = 0.0;

    if (currentTheme == AdaptiveThemeMode.light) {
      value = 0.5;
    } else if (currentTheme == AdaptiveThemeMode.dark) {
      value = 1.0;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildThemeLabel(context, '系统', value == 0.0),
              _buildThemeLabel(context, '浅色', value == 0.5),
              _buildThemeLabel(context, '深色', value == 1.0),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
                elevation: 0,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16,
              ),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              divisions: 2,
              label: value == 0.0 ? '系统' : (value == 0.5 ? '浅色' : '深色'),
              onChanged: (newValue) {
                if (newValue == 0.0) {
                  AdaptiveTheme.of(context).setSystem();
                } else if (newValue == 0.5) {
                  AdaptiveTheme.of(context).setLight();
                } else {
                  AdaptiveTheme.of(context).setDark();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeLabel(BuildContext context, String label, bool isSelected) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
    );
  }

  ///动态预览主题
  Widget _buildPreviewThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;

    return Column(
      children: [
        Container(
          height: 120,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Stack(
            children: [
              // 预览内容
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 120,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 主题切换按钮
              Positioned(
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    _buildPreviewThemeButton(
                      context,
                      icon: Icons.brightness_auto,
                      isSelected: currentTheme == AdaptiveThemeMode.system,
                      onTap: () => AdaptiveTheme.of(context).setSystem(),
                    ),
                    const SizedBox(width: 8),
                    _buildPreviewThemeButton(
                      context,
                      icon: Icons.brightness_7,
                      isSelected: currentTheme == AdaptiveThemeMode.light,
                      onTap: () => AdaptiveTheme.of(context).setLight(),
                    ),
                    const SizedBox(width: 8),
                    _buildPreviewThemeButton(
                      context,
                      icon: Icons.brightness_4,
                      isSelected: currentTheme == AdaptiveThemeMode.dark,
                      onTap: () => AdaptiveTheme.of(context).setDark(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewThemeButton(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  ///3D卡片主题
  Widget _build3DThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _build3DThemeCard(
            context,
            title: '跟随系统',
            icon: Icons.brightness_auto,
            value: AdaptiveThemeMode.system,
            groupValue: currentTheme,
            onChanged: (value) {
              AdaptiveTheme.of(context).setSystem();
            },
          ),
          const SizedBox(width: 16),
          _build3DThemeCard(
            context,
            title: '浅色',
            icon: Icons.brightness_7,
            value: AdaptiveThemeMode.light,
            groupValue: currentTheme,
            onChanged: (value) {
              AdaptiveTheme.of(context).setLight();
            },
          ),
          const SizedBox(width: 16),
          _build3DThemeCard(
            context,
            title: '深色',
            icon: Icons.brightness_4,
            value: AdaptiveThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (value) {
              AdaptiveTheme.of(context).setDark();
            },
          ),
        ],
      ),
    );
  }

  Widget _build3DThemeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AdaptiveThemeMode value,
    required AdaptiveThemeMode? groupValue,
    required ValueChanged<AdaptiveThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    final cardColor = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface;
    final textColor = isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24,
                color: textColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///动画切换主题
  Widget _buildAnimatedThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;

    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          // 背景动画
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // 主题选项
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedThemeOption(
                  context,
                  title: '跟随系统',
                  icon: Icons.brightness_auto,
                  value: AdaptiveThemeMode.system,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setSystem();
                  },
                ),
                const SizedBox(width: 24),
                _buildAnimatedThemeOption(
                  context,
                  title: '浅色',
                  icon: Icons.brightness_7,
                  value: AdaptiveThemeMode.light,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setLight();
                  },
                ),
                const SizedBox(width: 24),
                _buildAnimatedThemeOption(
                  context,
                  title: '深色',
                  icon: Icons.brightness_4,
                  value: AdaptiveThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setDark();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AdaptiveThemeMode value,
    required AdaptiveThemeMode? groupValue,
    required ValueChanged<AdaptiveThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.2 : 1.0,
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color:
                        isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
              child: Text(title),
            ),
          ],
        ),
      ),
    );
  }

  ///玻璃态主题
  Widget _buildGlassThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;

    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGlassThemeOption(
                  context,
                  title: '跟随系统',
                  icon: Icons.brightness_auto,
                  value: AdaptiveThemeMode.system,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setSystem();
                  },
                ),
                _buildGlassThemeOption(
                  context,
                  title: '浅色',
                  icon: Icons.brightness_7,
                  value: AdaptiveThemeMode.light,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setLight();
                  },
                ),
                _buildGlassThemeOption(
                  context,
                  title: '深色',
                  icon: Icons.brightness_4,
                  value: AdaptiveThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setDark();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AdaptiveThemeMode value,
    required AdaptiveThemeMode? groupValue,
    required ValueChanged<AdaptiveThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          height: 90,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///霓虹主题
  Widget _buildNeonThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;

    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景动画效果
          Positioned.fill(
            child: CustomPaint(
              painter: NeonBackgroundPainter(
                color: Theme.of(context).colorScheme.primary,
                isDark: currentTheme == AdaptiveThemeMode.dark,
              ),
            ),
          ),
          // 主题选项
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNeonThemeOption(
                  context,
                  title: '跟随系统',
                  icon: Icons.brightness_auto,
                  value: AdaptiveThemeMode.system,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setSystem();
                  },
                ),
                const SizedBox(width: 24),
                _buildNeonThemeOption(
                  context,
                  title: '浅色',
                  icon: Icons.brightness_7,
                  value: AdaptiveThemeMode.light,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setLight();
                  },
                ),
                const SizedBox(width: 24),
                _buildNeonThemeOption(
                  context,
                  title: '深色',
                  icon: Icons.brightness_4,
                  value: AdaptiveThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setDark();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AdaptiveThemeMode value,
    required AdaptiveThemeMode? groupValue,
    required ValueChanged<AdaptiveThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // 霓虹光效果
            if (isSelected)
              Positioned.fill(
                child: CustomPaint(
                  painter: NeonGlowPainter(
                    color: primaryColor,
                  ),
                ),
              ),
            // 内容
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected ? primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///液态主题
  Widget _buildLiquidThemeSelector(BuildContext context) {
    final currentTheme = AdaptiveTheme.of(context).mode;

    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // 液态背景
          Positioned.fill(
            child: CustomPaint(
              painter: LiquidBackgroundPainter(
                color: Theme.of(context).colorScheme.primary,
                isDark: currentTheme == AdaptiveThemeMode.dark,
              ),
            ),
          ),
          // 主题选项
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLiquidThemeOption(
                  context,
                  title: '跟随系统',
                  icon: Icons.brightness_auto,
                  value: AdaptiveThemeMode.system,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setSystem();
                  },
                ),
                const SizedBox(width: 24),
                _buildLiquidThemeOption(
                  context,
                  title: '浅色',
                  icon: Icons.brightness_7,
                  value: AdaptiveThemeMode.light,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setLight();
                  },
                ),
                const SizedBox(width: 24),
                _buildLiquidThemeOption(
                  context,
                  title: '深色',
                  icon: Icons.brightness_4,
                  value: AdaptiveThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    AdaptiveTheme.of(context).setDark();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AdaptiveThemeMode value,
    required AdaptiveThemeMode? groupValue,
    required ValueChanged<AdaptiveThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.2),
                    primaryColor.withOpacity(0.1),
                  ],
                )
              : null,
        ),
        child: Stack(
          children: [
            // 液态效果
            if (isSelected)
              Positioned.fill(
                child: CustomPaint(
                  painter: LiquidOptionPainter(
                    color: primaryColor,
                  ),
                ),
              ),
            // 内容
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected ? primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeonBackgroundPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  NeonBackgroundPainter({
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.8,
        size.width,
        size.height * 0.5,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NeonGlowPainter extends CustomPainter {
  final Color color;

  NeonGlowPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LiquidBackgroundPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  LiquidBackgroundPainter({
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();

    // 创建波浪效果
    path.moveTo(0, size.height * 0.5);
    for (double i = 0; i <= size.width; i += 10) {
      path.quadraticBezierTo(
        i + 5,
        size.height * 0.5 + (isDark ? 20 : -20),
        i + 10,
        size.height * 0.5,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LiquidOptionPainter extends CustomPainter {
  final Color color;

  LiquidOptionPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();

    // 创建液态效果
    path.moveTo(0, 0);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      0,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      -size.height * 0.1,
      size.width,
      0,
    );
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 1.1,
      size.width * 0.5,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      0,
      size.height,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
