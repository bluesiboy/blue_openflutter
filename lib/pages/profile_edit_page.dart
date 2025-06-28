import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../controls/breath_glow_widget.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/dialog_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  String? _selectedAvatar;
  List<String> _avatarFiles = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  late final BreathGlowController _breathGlowController;
  String? _initialAvatar;
  String? _initialName;
  String? _initialBio;
  String _selectedGender = '保密';
  String? _selectedBirthday;
  String? _initialGender;
  String? _initialBirthday;

  final List<String> _genderOptions = ['保密', '男', '女'];

  @override
  void initState() {
    super.initState();
    _breathGlowController = BreathGlowController(
      breathCount: 8,
      duration: const Duration(seconds: 1),
      maxOpacity: 0.18,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    setState(() {
      _initialAvatar = provider.profile.avatar.isNotEmpty ? provider.profile.avatar : null;
      _selectedAvatar = _initialAvatar;
      _initialName = provider.profile.name.isNotEmpty ? provider.profile.name : '';
      _nameController.text = _initialName!;
      _initialBio = provider.profile.bio.isNotEmpty ? provider.profile.bio : '';
      _bioController.text = _initialBio!;
      _initialGender = provider.profile.gender.isNotEmpty ? provider.profile.gender : '保密';
      _selectedGender = _initialGender!;
      _initialBirthday = provider.profile.birthday.isNotEmpty ? provider.profile.birthday : null;
      _selectedBirthday = _initialBirthday;
    });
    _loadAvatars();
  }

  Future<void> _loadAvatars() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final avatarFiles = manifestMap.keys
        .where((String key) => key.startsWith('assets/avatar/') && (key.endsWith('.jpg') || key.endsWith('.png')))
        .toList();
    setState(() {
      _avatarFiles = avatarFiles;
      _selectedAvatar ??= avatarFiles.isNotEmpty ? avatarFiles.first : null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _breathGlowController.dispose();
    super.dispose();
  }

  void _onSave() async {
    // 显示等待对话框
    DialogService.showGlassDialog(
      context: context,
      content: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              '保存中...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      height: 120,
      barrierDismissible: false,
    );

    // 等待2秒
    await Future.delayed(const Duration(seconds: 2));

    // 关闭等待对话框
    if (mounted) {
      Navigator.of(context).pop();
    }

    // 执行原有的保存逻辑
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    bool changed = false;
    if (_selectedAvatar != null && _selectedAvatar != _initialAvatar) {
      await provider.updateAvatar(_selectedAvatar!);
      changed = true;
    }
    if (_nameController.text != _initialName) {
      await provider.updateName(_nameController.text);
      changed = true;
    }
    if (_bioController.text != _initialBio) {
      await provider.updateBio(_bioController.text);
      changed = true;
    }
    if (_selectedGender != _initialGender) {
      await provider.updateGender(_selectedGender);
      changed = true;
    }
    if (_selectedBirthday != _initialBirthday) {
      await provider.updateBirthday(_selectedBirthday ?? '');
      changed = true;
    }
    if (changed && mounted) Navigator.pop(context);
    if (!changed && mounted) Navigator.pop(context);
  }

  Future<void> _selectBirthday() async {
    DateTime? initialDate;
    if (_selectedBirthday != null && _selectedBirthday!.isNotEmpty) {
      try {
        final parts = _selectedBirthday!.split('-');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (e) {
        // 如果解析失败，使用默认日期
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now().subtract(const Duration(days: 6570)), // 18岁
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white.withOpacity(0.9),
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.transparent,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final birthdayString =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _selectedBirthday = birthdayString;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('编辑个人资料', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text('保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF232526), Color(0xFF414345), Color(0xFF0f2027), Color(0xFF2c5364)]
                    : const [
                        Color(0xFFe0eafc),
                        Color(0xFFcfdef3),
                        Color(0xFFa1c4fd),
                        Color(0xFFc2e9fb),
                        Color(0xFFfbc2eb)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // 头像选择区域
                  GlassmorphicContainer(
                    width: double.infinity,
                    borderRadius: 20,
                    blur: 18,
                    border: 1.2,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.13 : 0.18),
                        Colors.white.withOpacity(isDark ? 0.05 : 0.09),
                      ],
                      stops: const [0.1, 1],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.16 : 0.25),
                        Colors.white.withOpacity(isDark ? 0.12 : 0.18),
                      ],
                    ),
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: InkWell(
                        onTap: () async {
                          final selectedAvatar = await DialogService.showAvatarSelectionDialog(
                            context: context,
                            avatarFiles: _avatarFiles,
                            selectedAvatar: _selectedAvatar,
                          );
                          if (selectedAvatar != null) {
                            setState(() {
                              _selectedAvatar = selectedAvatar;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            BreathGlowWidget(
                              controller: _breathGlowController,
                              glowColor: Colors.blueAccent,
                              blurRadius: 16,
                              spreadRadius: 2,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: _selectedAvatar != null ? AssetImage(_selectedAvatar!) : null,
                                backgroundColor: Colors.blueGrey.withOpacity(0.12),
                                child: _selectedAvatar == null
                                    ? const Icon(Icons.person, size: 40, color: Colors.white54)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '头像',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '点击更换头像',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 基本信息区域
                  GlassmorphicContainer(
                    width: double.infinity,
                    borderRadius: 20,
                    blur: 18,
                    border: 1.2,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.13 : 0.18),
                        Colors.white.withOpacity(isDark ? 0.05 : 0.09),
                      ],
                      stops: const [0.1, 1],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.16 : 0.25),
                        Colors.white.withOpacity(isDark ? 0.12 : 0.18),
                      ],
                    ),
                    height: 320,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 昵称
                          _buildSettingItem(
                            icon: Icons.person_outline,
                            title: '昵称',
                            subtitle: _nameController.text.isEmpty ? '请输入昵称' : _nameController.text,
                            onTap: () async {
                              final result = await DialogService.showGlassInputDialog(
                                context: context,
                                title: '编辑昵称',
                                controller: _nameController,
                                hintText: '请输入昵称',
                                maxLines: 1,
                                maxLength: 16,
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            },
                            isDark: isDark,
                          ),
                          const Divider(height: 1, thickness: 0.5),

                          // 性别
                          _buildSettingItem(
                            icon: Icons.wc_outlined,
                            title: '性别',
                            subtitle: _selectedGender,
                            onTap: () async {
                              await DialogService.showGlassSelectionDialog(
                                context: context,
                                title: '选择性别',
                                children: _genderOptions
                                    .map((gender) => ListTile(
                                          title: Text(gender),
                                          trailing: _selectedGender == gender
                                              ? const Icon(Icons.check, color: Colors.blue)
                                              : null,
                                          onTap: () {
                                            setState(() {
                                              _selectedGender = gender;
                                            });
                                            Navigator.pop(context);
                                          },
                                        ))
                                    .toList(),
                              );
                            },
                            isDark: isDark,
                          ),
                          const Divider(height: 1, thickness: 0.5),

                          // 生日
                          _buildSettingItem(
                            icon: Icons.cake_outlined,
                            title: '生日',
                            subtitle: _selectedBirthday != null && _selectedBirthday!.isNotEmpty
                                ? _selectedBirthday!
                                : '请选择生日',
                            onTap: _selectBirthday,
                            isDark: isDark,
                          ),
                          const Divider(height: 1, thickness: 0.5),

                          // 个性签名
                          _buildSettingItem(
                            icon: Icons.edit_outlined,
                            title: '个性签名',
                            subtitle: _bioController.text.isEmpty ? '添加个性签名' : _bioController.text,
                            onTap: () async {
                              final result = await DialogService.showGlassInputDialog(
                                context: context,
                                title: '编辑个性签名',
                                controller: _bioController,
                                hintText: '请输入个性签名',
                                maxLines: 3,
                                maxLength: 50,
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white54 : Colors.black54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
