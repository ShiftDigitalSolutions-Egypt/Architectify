<p align="center">
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.0.0-blue?logo=dart" alt="Dart SDK">
  <img src="https://img.shields.io/badge/Flutter-Compatible-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/AI-GPT--4o--mini-412991?logo=openai" alt="OpenAI">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/Version-2.0.0-orange" alt="Version">
</p>

<h1 align="center">🏗️ Architectify</h1>

<p align="center">
  <strong>AI-Powered Flutter Architecture Refactoring Tool</strong>
</p>

<p align="center">
  Transform your Flutter projects into well-structured, maintainable codebases with a single command.
  <br>
  Choose from 5 popular design patterns • AI-powered file classification • Smart code generation
</p>

---

## ✨ What is Architectify?

Architectify is a powerful CLI tool that automatically restructures your Flutter feature folders into your preferred architecture pattern. It uses **OpenAI GPT-4o-mini** to intelligently classify your Dart files and generates missing components like entities, repositories, and use cases.

### 🎯 Key Features

| Feature | Description |
|---------|-------------|
| 🤖 **AI-Powered** | Uses GPT-4o-mini to intelligently analyze and classify your code |
| 📐 **5 Design Patterns** | Choose from Clean Architecture, MVVM, MVC, BLoC, or Feature-First |
| ⚡ **Auto-Generation** | Creates missing entities, models, repositories, and interfaces |
| 💉 **Injectable Support** | Handles `@Injectable(as: Repository)` annotations automatically |
| 🔗 **Smart Inheritance** | Sets up proper model-entity inheritance relationships |
| 📦 **Batch Processing** | Processes entire feature folders at once |

---

## 📐 Supported Design Patterns

### 1. 🏛️ Clean Architecture (Default)

The gold standard for scalable Flutter applications.

```
feature/
├── data/
│   ├── models/          # Data models with JSON serialization
│   ├── repository/      # Repository implementations
│   ├── requests/        # API request models
│   └── datasources/     # Remote/local data sources
├── domain/
│   ├── entities/        # Business entities (pure Dart)
│   ├── repository/      # Repository interfaces (contracts)
│   └── use_cases/       # Business logic use cases
└── presentation/
    ├── logic/           # BLoC/Cubit state management
    ├── view/            # Screens and pages
    └── widget/          # Reusable widgets
```

**Benefits:**
- ✅ Separation of Concerns
- ✅ Highly Testable
- ✅ Easy to swap implementations
- ✅ Scales with team size

---

### 2. 📊 MVVM (Model-View-ViewModel)

Perfect for reactive UIs with data binding.

```
feature/
├── models/              # Data models
├── views/               # UI screens
├── viewmodels/          # View logic and state
├── services/            # External services
├── repositories/        # Data access
└── widgets/             # Reusable components
```

**Benefits:**
- ✅ Automatic UI updates
- ✅ Clean separation of UI and logic
- ✅ Great for data-driven apps
- ✅ Easy to unit test ViewModels

---

### 3. 🎮 MVC (Model-View-Controller)

Classic pattern, simple and familiar.

```
feature/
├── models/              # Data and business rules
├── views/               # UI presentation
├── controllers/         # User input handling
├── widgets/             # Reusable UI
└── services/            # External integrations
```

**Benefits:**
- ✅ Simple to understand
- ✅ Quick to implement
- ✅ Familiar to most developers
- ✅ Good for small-medium projects

---

### 4. 🌊 BLoC Pattern

Stream-based state management for complex apps.

```
feature/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── bloc/            # Events, States, BLoC
    ├── screens/
    └── widgets/
```

**Benefits:**
- ✅ Predictable state transitions
- ✅ Excellent testability
- ✅ Great for complex UIs
- ✅ Reactive by design

---

### 5. 📦 Feature-First

Modular architecture for large teams.

```
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── core/
    ├── utils/
    ├── theme/
    └── widgets/
```

**Benefits:**
- ✅ Features are self-contained
- ✅ Teams can own features
- ✅ Easy to extract as packages
- ✅ Scales with codebase size

---

## 🚀 Installation

### Global Activation (Recommended)

```bash
dart pub global activate architectify
```

### From Source

```bash
git clone https://github.com/Abdelmonem-wagih/architectify.git
cd architectify
dart pub global activate --source path .
```

### Compile to Executable

```bash
dart compile exe bin/architectify.dart -o architectify
```

---

## 💻 Usage

### Basic Command

```bash
architectify <feature_folder_path> [options]
```

### Options

| Option | Short | Description |
|--------|-------|-------------|
| `--help` | `-h` | Show usage information |
| `--list-patterns` | `-l` | List all available design patterns with descriptions |
| `--pattern` | `-p` | Design pattern to use (1-5 or name) |
| `--api-key` | `-k` | OpenAI API key |

### Examples

```bash
# Use Clean Architecture (default)
architectify ./lib/features/auth -k sk-xxx

# Use MVVM pattern
architectify ./lib/features/auth -p 2 -k sk-xxx

# Use pattern by name
architectify ./lib/features/auth -p mvvm -k sk-xxx

# Use environment variable for API key
export OPENAI_API_KEY=sk-xxx
architectify ./lib/features/auth -p bloc

# List all available patterns
architectify -l
```

---

## 📋 Example Output

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║ 🏗️  Selected Pattern: Clean Architecture                                      ║
╚═══════════════════════════════════════════════════════════════════════════════╝

📝 Description:
   Clean Architecture separates your code into layers with clear boundaries...

✅ Benefits:
   🎯 Separation of Concerns - Each layer has a single responsibility
   🧪 Testability - Business logic can be tested without UI or database
   🔄 Flexibility - Easy to swap implementations
   ...

📁 Folder Structure:
   └── data/models
   └── data/repository
   └── domain/entities
   └── domain/use_cases
   └── presentation/view
   └── ... and 4 more

🚀 Starting Clean Architecture refactor for: ./lib/features/auth

📂 Creating Clean Architecture folder structure...
🔄 Processing 8 files with AI...
✅ Wrote/updated: domain/entities/auth_entity.dart
✅ Wrote/updated: data/models/auth_model.dart
✅ Wrote/updated: domain/repository/auth_repository.dart
✅ Wrote/updated: domain/use_cases/login_use_case.dart
✅ Wrote/updated: presentation/logic/auth_cubit.dart

✨ Refactor completed successfully!
📋 Your code is now organized using Clean Architecture
```

---

## 🤖 How It Works

1. **Scans** your feature folder for all Dart files
2. **Sends** the files to GPT-4o-mini with pattern-specific instructions
3. **Analyzes** file contents to classify them (model, entity, repository, etc.)
4. **Generates** missing files (entities from models, interfaces from implementations)
5. **Organizes** everything into the selected architecture pattern
6. **Updates** imports and inheritance relationships

---

## ⚙️ Requirements

| Requirement | Version |
|-------------|---------|
| Dart SDK | ≥3.0.0 <4.0.0 |
| OpenAI API Key | Required |
| Internet | Required for AI classification |

---

## 🔧 Configuration

### Environment Variable

Set your OpenAI API key as an environment variable:

**Linux/macOS:**
```bash
export OPENAI_API_KEY=sk-your-api-key-here
```

**Windows (PowerShell):**
```powershell
$env:OPENAI_API_KEY="sk-your-api-key-here"
```

**Windows (CMD):**
```cmd
set OPENAI_API_KEY=sk-your-api-key-here
```

---

## 🧪 Running Tests

```bash
dart test
```

---

## 👨‍💻 Author

**Abdelmonem Wagih**
- 📧 Email: [abdowagih38@gmail.com](mailto:abdowagih38@gmail.com)
- 🐙 GitHub: [@Abdelmonem-wagih](https://github.com/Abdelmonem-wagih)

---

## 🔗 Links

- [GitHub Repository](https://github.com/Abdelmonem-wagih/architectify)
- [Issue Tracker](https://github.com/Abdelmonem-wagih/architectify/issues)
- [Changelog](CHANGELOG.md)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. 🍴 Fork the repository
2. 🌿 Create your feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔃 Open a Pull Request

### Ideas for Contributions

- [ ] Add more design patterns (Redux, GetX, Riverpod)
- [ ] Support for custom pattern templates
- [ ] Dry-run mode to preview changes
- [ ] Interactive mode with confirmations
- [ ] VS Code extension

---

<p align="center">
  Made with ❤️ for the Flutter community
</p>
