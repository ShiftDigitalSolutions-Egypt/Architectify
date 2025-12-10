## 2.0.0

### 🎉 Major Release - Rebranded as Architectify!

#### ✨ New Features
- **Multi-Pattern Support**: Choose from 5 design patterns:
  - Clean Architecture
  - MVVM (Model-View-ViewModel)
  - MVC (Model-View-Controller)
  - BLoC Pattern
  - Feature-First Architecture
- **Interactive Pattern Selection**: CLI now shows pattern descriptions and benefits
- **Pattern-Specific AI Prompts**: Each pattern has optimized AI instructions
- **Beautiful CLI Interface**: ASCII art banner and formatted output
- **Command-Line Options**: New flags for pattern selection and help

#### 🔧 Improvements
- Better error handling and user feedback
- Improved folder structure generation
- Enhanced AI prompt engineering for each pattern
- Cleaner code organization with separate modules

#### 📦 Breaking Changes
- Package renamed from `clean_architect_cli` to `architectify`
- CLI command changed from `clean_architect_cli` to `architectify`
- Requires `-p` flag for pattern selection (defaults to Clean Architecture)

---

## 1.1.0

### ✨ Features
- AI-powered file classification using OpenAI GPT-4o-mini
- Automatic entity generation from models
- Repository interface generation
- Use case generation from repository methods
- Injectable annotation support (`@Injectable(as: Repository)`)
- Smart inheritance management (Model extends Entity)

### 🔧 Improvements
- Better regex patterns for file parsing
- Improved error messages
- Support for complex generic types

---

## 1.0.0

### 🎉 Initial Release
- Basic Clean Architecture folder structure generation
- File classification using pattern matching
- Support for standard Flutter project structure
