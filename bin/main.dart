import 'dart:io';

final home = Platform.environment['HOME'] ?? '';

final Map<String, List<String>> paths = {
  'Gradle Caches': ['$home/.gradle/caches'],
  'Android AVDs': ['$home/.android/avd'],
  'Android Studio Cache': [
    // Wildcard-style matching
    '$home/Library/Caches/Google/',
  ],
  'Xcode Derived Data': ['$home/Library/Developer/Xcode/DerivedData'],
  'Xcode Archives': ['$home/Library/Developer/Xcode/Archives'],
  'iOS Simulators': ['$home/Library/Developer/CoreSimulator/Devices'],
  'Telegram Cache': ['$home/Library/Caches/ru.keepcoder.Telegram/org.sparkle-project.Sparkle/PersistentDownloads'],
};

Future<int> getSize(Directory dir) async {
  int totalSize = 0;

  if (!await dir.exists()) return 0;

  await for (var entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      try {
        totalSize += await entity.length();
      } catch (_) {}
    }
  }

  return totalSize;
}

String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  int i = 0;
  double size = bytes.toDouble();

  while (size >= 1024 && i < units.length - 1) {
    size /= 1024;
    i++;
  }

  return '${size.toStringAsFixed(2)} ${units[i]}';
}

Future<void> listDirectoryDetails(String label, List<String> pathList) async {
  print('\n📁 $label');

  int grandTotal = 0;

  for (var path in pathList) {
    final baseDir = Directory(path);
    if (!await baseDir.exists()) {
      print('  ❌ Directory not found: $path');
      continue;
    }

    final entries = await baseDir.list(followLinks: false).toList();

    for (var entry in entries) {
      if (entry is Directory &&
          label == 'Android Studio Cache' &&
          entry.path.contains(RegExp(r'AndroidStudio\d{4}\.\d+'))) {
        final size = await getSize(entry);
        grandTotal += size;
        print('  - ${entry.path.split('/').last}: ${formatBytes(size)}');
      } else if (entry is Directory && label != 'Android Studio Cache') {
        final size = await getSize(entry);
        grandTotal += size;
        final name = entry.path.split('/').last;
        print('  - $name: ${formatBytes(size)}');
      }
    }
  }

  print('  🔸 Total for $label: ${formatBytes(grandTotal)}');
}

Future<void> main() async {
  print('\n📦 Developer Cache Storage Audit');
  print('--------------------------------');

  for (final entry in paths.entries) {
    await listDirectoryDetails(entry.key, entry.value);
  }

  print('\n✅ Done.');
}
