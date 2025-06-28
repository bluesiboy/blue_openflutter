import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../controls/breath_glow_widget.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  String? _selectedAvatar;
  List<String> _avatarFiles = [];
  final TextEditingController _nameController = TextEditingController();
  late final BreathGlowController _breathGlowController;
  String? _initialAvatar;
  String? _initialName;

  @override
  void initState() {
    super.initState();
    _breathGlowController = BreathGlowController(
      breathCount: 8,
      duration: const Duration(seconds: 1),
      maxOpacity: 0.18,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      setState(() {
        _initialAvatar = provider.profile.avatar.isNotEmpty ? provider.profile.avatar : null;
        _selectedAvatar = _initialAvatar;
        _initialName = provider.profile.name.isNotEmpty ? provider.profile.name : '';
        _nameController.text = _initialName!;
      });
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
    _breathGlowController.dispose();
    super.dispose();
  }

  void _onSave() async {
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
    if (changed && mounted) Navigator.pop(context);
    if (!changed && mounted) Navigator.pop(context);
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
        title: const Text('编辑个人资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: '保存',
            onPressed: _onSave,
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
          Center(
            child: SingleChildScrollView(
              child: GlassmorphicContainer(
                width: 340,
                borderRadius: 28,
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
                height: 480,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: GlassmorphicContainer(
                                width: 320,
                                height: 320,
                                borderRadius: 24,
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
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                  ),
                                  itemCount: _avatarFiles.length,
                                  itemBuilder: (ctx, i) {
                                    final avatar = _avatarFiles[i];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedAvatar = avatar;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(avatar),
                                        radius: 32,
                                        child: _selectedAvatar == avatar
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.blueAccent, width: 3),
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: BreathGlowWidget(
                          controller: _breathGlowController,
                          glowColor: Colors.blueAccent,
                          blurRadius: 16,
                          spreadRadius: 2,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: _selectedAvatar != null ? AssetImage(_selectedAvatar!) : null,
                            backgroundColor: Colors.blueGrey.withOpacity(0.12),
                            child: _selectedAvatar == null
                                ? const Icon(Icons.person, size: 48, color: Colors.white54)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '昵称',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(isDark ? 0.08 : 0.13),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLength: 16,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('保存'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _onSave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
