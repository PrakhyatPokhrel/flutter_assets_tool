# Flutter Assets Tool (fassets)

A Flutter CLI tool that scans your project for unused assets, cleans them, and generates strongly-typed Dart references for used assets, reducing app size and preventing runtime errors.

## 🚀 Features

- **Scan Assets**: Recursively scans all asset folders listed in `pubspec.yaml` and compares them against Dart/Flutter code references.
- **Clean Unused Assets**: Removes or moves unused assets to a backup folder to help reduce app size and clutter.
- **Generate Typed References**: Automatically generates a Dart class (e.g., `lib/generated/assets.dart`) containing constants for all used assets to prevent typos.
- **Intelligent Parsing**:
  - **Dynamic Path Support**: Detects assets even when paths are dynamically concatenated (e.g., `link + 'icon.svg'`).
  - **Comment Awareness**: Automatically ignores asset references that are commented out in your code.
- **Watch Mode**: Optional mode to watch asset folders and Dart files to automatically update typed references in real time.
- **CI/CD Integration**: Ideal for automated pipelines to warn or fail builds if unused assets are detected.

## 📦 Installation

```bash
dart pub global activate --source path .
```

## 🛠 Usage

### Scan Assets
Lists used and unused assets in your project.
```bash
fassets scan
```

### Generate Typed References
Creates a Dart class with constants for all assets.
```bash
fassets gen
```

### Clean Unused Assets
Removes unused assets and optionally moves them to a backup folder.
```bash
fassets clean --backup ./backup_assets
```

### Watch Mode
Monitors for filesystem changes and updates references automatically.
```bash
fassets watch
```

## 📝 Example Output (Generated Code)

```dart
class Assets {
  Assets._();
  static const String logo = 'assets/logo.png';
  static const String swasthyaFull = 'assets/Swasthya_Full.svg';
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details.
