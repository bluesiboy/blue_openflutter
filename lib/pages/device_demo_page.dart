import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceDemoPage extends StatefulWidget {
  const DeviceDemoPage({super.key});

  @override
  State<DeviceDemoPage> createState() => _DeviceDemoPageState();
}

class _DeviceDemoPageState extends State<DeviceDemoPage> {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = {};
  bool _isLoading = true;
  final Map<String, bool> _expandedStates = {};

  // 添加设备信息重要性和中文释义映射
  final Map<String, Map<String, dynamic>> _deviceInfoMetadata = {
    // Android 设备信息
    'brand': {'importance': 1, 'description': '设备品牌'},
    'model': {'importance': 1, 'description': '设备型号'},
    'manufacturer': {'importance': 1, 'description': '制造商'},
    'device': {'importance': 1, 'description': '设备名称'},
    'product': {'importance': 1, 'description': '产品名称'},
    'version.release': {'importance': 1, 'description': 'Android 系统版本'},
    'version.sdkInt': {'importance': 1, 'description': 'SDK 版本'},
    'id': {'importance': 2, 'description': '设备唯一标识符'},
    'fingerprint': {'importance': 2, 'description': '设备指纹'},
    'hardware': {'importance': 2, 'description': '硬件信息'},
    'display': {'importance': 2, 'description': '显示信息'},
    'board': {'importance': 2, 'description': '主板信息'},
    'bootloader': {'importance': 2, 'description': '引导程序版本'},
    'version.securityPatch': {'importance': 2, 'description': '安全补丁版本'},
    'version.incremental': {'importance': 2, 'description': '增量版本号'},
    'version.codename': {'importance': 3, 'description': '版本代号'},
    'version.baseOS': {'importance': 3, 'description': '基础系统版本'},
    'version.previewSdkInt': {'importance': 3, 'description': '预览版 SDK 版本'},
    'host': {'importance': 3, 'description': '主机信息'},
    'name': {'importance': 3, 'description': '设备名称'},
    'supported32BitAbis': {'importance': 3, 'description': '支持的32位ABI'},
    'supported64BitAbis': {'importance': 3, 'description': '支持的64位ABI'},
    'supportedAbis': {'importance': 3, 'description': '支持的ABI列表'},
    'tags': {'importance': 3, 'description': '系统标签'},
    'type': {'importance': 3, 'description': '设备类型'},
    'isPhysicalDevice': {'importance': 3, 'description': '是否为物理设备'},
    'systemFeatures': {'importance': 3, 'description': '系统特性'},
    'serialNumber': {'importance': 3, 'description': '序列号'},
    'isLowRamDevice': {'importance': 3, 'description': '是否为低内存设备'},
    'physicalRamSize': {'importance': 2, 'description': '物理内存大小'},
    'availableRamSize': {'importance': 2, 'description': '可用内存大小'},

    // iOS 设备信息
    'name': {'importance': 1, 'description': '设备名称'},
    'model': {'importance': 1, 'description': '设备型号'},
    'systemName': {'importance': 1, 'description': '系统名称'},
    'systemVersion': {'importance': 1, 'description': '系统版本'},
    'modelName': {'importance': 1, 'description': '型号名称'},
    'localizedModel': {'importance': 2, 'description': '本地化型号'},
    'identifierForVendor': {'importance': 2, 'description': '供应商标识符'},
    'isPhysicalDevice': {'importance': 2, 'description': '是否为物理设备'},
    'isiOSAppOnMac': {'importance': 2, 'description': '是否为Mac上的iOS应用'},
    'physicalRamSize': {'importance': 2, 'description': '物理内存大小'},
    'availableRamSize': {'importance': 2, 'description': '可用内存大小'},
    'utsname.sysname': {'importance': 3, 'description': '系统名称'},
    'utsname.nodename': {'importance': 3, 'description': '节点名称'},
    'utsname.release': {'importance': 3, 'description': '发布版本'},
    'utsname.version': {'importance': 3, 'description': '版本信息'},
    'utsname.machine': {'importance': 3, 'description': '机器信息'},

    // Web 浏览器信息
    'browserName': {'importance': 1, 'description': '浏览器名称'},
    'appName': {'importance': 1, 'description': '应用名称'},
    'appVersion': {'importance': 1, 'description': '应用版本'},
    'platform': {'importance': 1, 'description': '平台信息'},
    'userAgent': {'importance': 1, 'description': '用户代理'},
    'language': {'importance': 2, 'description': '语言'},
    'languages': {'importance': 2, 'description': '支持的语言列表'},
    'deviceMemory': {'importance': 2, 'description': '设备内存'},
    'hardwareConcurrency': {'importance': 2, 'description': '硬件并发数'},
    'maxTouchPoints': {'importance': 2, 'description': '最大触摸点数'},
    'appCodeName': {'importance': 3, 'description': '应用代码名称'},
    'product': {'importance': 3, 'description': '产品名称'},
    'productSub': {'importance': 3, 'description': '产品子版本'},
    'vendor': {'importance': 3, 'description': '供应商'},
    'vendorSub': {'importance': 3, 'description': '供应商子版本'},

    // Windows 设备信息
    'computerName': {'importance': 1, 'description': '计算机名称'},
    'userName': {'importance': 1, 'description': '用户名'},
    'productName': {'importance': 1, 'description': '产品名称'},
    'displayVersion': {'importance': 1, 'description': '显示版本'},
    'majorVersion': {'importance': 1, 'description': '主版本号'},
    'minorVersion': {'importance': 1, 'description': '次版本号'},
    'buildNumber': {'importance': 1, 'description': '构建号'},
    'systemMemoryInMegabytes': {'importance': 2, 'description': '系统内存(MB)'},
    'numberOfCores': {'importance': 2, 'description': 'CPU核心数'},
    'platformId': {'importance': 2, 'description': '平台ID'},
    'productId': {'importance': 2, 'description': '产品ID'},
    'deviceId': {'importance': 2, 'description': '设备ID'},
    'registeredOwner': {'importance': 2, 'description': '注册所有者'},
    'editionId': {'importance': 2, 'description': '版本ID'},
    'releaseId': {'importance': 2, 'description': '发布ID'},
    'buildLab': {'importance': 3, 'description': '构建实验室'},
    'buildLabEx': {'importance': 3, 'description': '扩展构建实验室'},
    'csdVersion': {'importance': 3, 'description': 'CSD版本'},
    'servicePackMajor': {'importance': 3, 'description': '服务包主版本'},
    'servicePackMinor': {'importance': 3, 'description': '服务包次版本'},
    'suitMask': {'importance': 3, 'description': '套件掩码'},
    'productType': {'importance': 3, 'description': '产品类型'},
    'reserved': {'importance': 3, 'description': '保留'},
    'digitalProductId': {'importance': 3, 'description': '数字产品ID'},
    'installDate': {'importance': 3, 'description': '安装日期'},
  };

  // 获取排序后的设备信息列表
  List<MapEntry<String, dynamic>> _getSortedDeviceInfo() {
    return _deviceData.entries.toList()
      ..sort((a, b) {
        final aImportance = _deviceInfoMetadata[a.key]?['importance'] ?? 999;
        final bImportance = _deviceInfoMetadata[b.key]?['importance'] ?? 999;
        return aImportance.compareTo(bImportance);
      });
  }

  // 获取设备信息的中文释义
  String _getDeviceInfoDescription(String key) {
    return _deviceInfoMetadata[key]?['description'] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (kIsWeb) {
        _deviceData = _readWebBrowserInfo(await _deviceInfo.webBrowserInfo);
      } else {
        _deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android => _readAndroidBuildData(await _deviceInfo.androidInfo),
          TargetPlatform.iOS => _readIosDeviceInfo(await _deviceInfo.iosInfo),
          TargetPlatform.linux => _readLinuxDeviceInfo(await _deviceInfo.linuxInfo),
          TargetPlatform.windows => _readWindowsDeviceInfo(await _deviceInfo.windowsInfo),
          TargetPlatform.macOS => _readMacOsDeviceInfo(await _deviceInfo.macOsInfo),
          TargetPlatform.fuchsia => <String, dynamic>{'Error:': 'Fuchsia platform isn\'t supported'},
        };
      }
    } catch (e) {
      _deviceData = <String, dynamic>{'Error:': e.toString()};
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildExpandableContent(String key, dynamic value) {
    if (value is List) {
      final isExpanded = _expandedStates[key] ?? false;
      final displayItems = isExpanded ? value : value.take(5).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayItems.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(item.toString()),
              )),
          if (value.length > 5)
            TextButton(
              onPressed: () {
                setState(() {
                  _expandedStates[key] = !isExpanded;
                });
              },
              child: Text(isExpanded ? '收起' : '显示更多'),
            ),
        ],
      );
    } else if (value is String && value.length > 50) {
      final isExpanded = _expandedStates[key] ?? false;
      final displayText = isExpanded ? value : value.substring(0, 50);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(displayText),
          TextButton(
            onPressed: () {
              setState(() {
                _expandedStates[key] = !isExpanded;
              });
            },
            child: Text(isExpanded ? '收起' : '显示更多'),
          ),
        ],
      );
    }

    return Text(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设备信息示例')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _deviceData.length,
              itemBuilder: (context, index) {
                final entry = _getSortedDeviceInfo()[index];
                final key = entry.key;
                final value = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDeviceInfoDescription(key),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildExpandableContent(key, value),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'name': build.name,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      'isLowRamDevice': build.isLowRamDevice,
      'physicalRamSize': build.physicalRamSize,
      'availableRamSize': build.availableRamSize,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'modelName': data.modelName,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'isiOSAppOnMac': data.isiOSAppOnMac,
      'physicalRamSize': data.physicalRamSize,
      'availableRamSize': data.availableRamSize,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'modelName': data.modelName,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }
}
