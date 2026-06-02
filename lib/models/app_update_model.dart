// lib/models/app_update_model.dart

class AppUpdateModel {
  final bool updateAvailable;
  final bool forceUpdate;
  final String currentVersion;
  final int currentVersionCode;
  final String? latestVersion;
  final int? latestVersionCode;
  final String? downloadUrl;
  final String? releaseNotes;

  const AppUpdateModel({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.currentVersion,
    required this.currentVersionCode,
    this.latestVersion,
    this.latestVersionCode,
    this.downloadUrl,
    this.releaseNotes,
  });

  factory AppUpdateModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateModel(
      updateAvailable: json['updateAvailable'] as bool? ?? false,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      currentVersion: json['currentVersion'] as String? ?? '',
      currentVersionCode: json['currentVersionCode'] as int? ?? 0,
      latestVersion: json['latestVersion'] as String?,
      latestVersionCode: json['latestVersionCode'] as int?,
      downloadUrl: json['downloadUrl'] as String?,
      releaseNotes: json['releaseNotes'] as String?,
    );
  }

  @override
  String toString() =>
      'AppUpdateModel(updateAvailable=$updateAvailable, forceUpdate=$forceUpdate, '
      'currentVersion=$currentVersion, latestVersion=$latestVersion)';
}
