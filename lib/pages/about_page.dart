import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于我们'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.flutter_dash,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Blue OpenFlutter',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '版本 $_version ($_buildNumber)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 255 * 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            title: '应用信息',
            children: [
              _buildInfoItem(
                context,
                title: '官方网站',
                value: 'https://example.com',
                onTap: () => _launchUrl('https://example.com'),
              ),
              _buildInfoItem(
                context,
                title: '联系我们',
                value: 'support@example.com',
                onTap: () => _launchUrl('mailto:support@example.com'),
              ),
              _buildInfoItem(
                context,
                title: '微信公众号',
                value: 'BlueOpenFlutter',
              ),
            ],
          ),
          _buildSection(
            context,
            title: '开发信息',
            children: [
              _buildInfoItem(
                context,
                title: '开发者',
                value: 'Blue OpenFlutter Team',
              ),
              _buildInfoItem(
                context,
                title: '开源协议',
                value: 'MIT License',
                onTap: () => _launchUrl('https://opensource.org/licenses/MIT'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2024 Blue OpenFlutter Team',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 255 * 0.6),
              ),
            ),
          ),
          const SizedBox(height: 32),
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

  Widget _buildInfoItem(
    BuildContext context, {
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 255 * 0.6),
                ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 255 * 0.6),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
