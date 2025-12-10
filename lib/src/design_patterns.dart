/// Design patterns supported by Architectify with their descriptions and benefits
library;

/// Represents a design pattern with its structure and benefits
class DesignPattern {
  final String name;
  final String description;
  final List<String> benefits;
  final List<String> folderStructure;
  final String aiPromptTemplate;

  const DesignPattern({
    required this.name,
    required this.description,
    required this.benefits,
    required this.folderStructure,
    required this.aiPromptTemplate,
  });
}

/// Available design patterns
class DesignPatterns {
  static const cleanArchitecture = DesignPattern(
    name: 'Clean Architecture',
    description: '''
Clean Architecture separates your code into layers with clear boundaries:
- Domain Layer (innermost): Business logic, entities, use cases
- Data Layer: Repository implementations, data sources, models  
- Presentation Layer: UI, state management, widgets

Each layer only depends on layers closer to the center.''',
    benefits: [
      '🎯 Separation of Concerns - Each layer has a single responsibility',
      '🧪 Testability - Business logic can be tested without UI or database',
      '🔄 Flexibility - Easy to swap implementations (e.g., change database)',
      '📦 Maintainability - Changes in one layer don\'t affect others',
      '🚀 Scalability - Easy to add new features without breaking existing code',
      '👥 Team Collaboration - Different teams can work on different layers',
    ],
    folderStructure: [
      'data/models',
      'data/repository',
      'data/requests',
      'data/datasources',
      'domain/entities',
      'domain/use_cases',
      'domain/repository',
      'presentation/logic',
      'presentation/view',
      'presentation/widget',
    ],
    aiPromptTemplate: '''
You are an expert AI in Flutter Clean Architecture.
Goal:
- Generate any missing Entities from existing Models.
- Update existing Models to extend their corresponding Entity.
- For each Repository abstract class, generate UseCases for each method.
- Place files in the correct layers:
  - Entities → domain/entities
  - Models → data/models
  - Repository interfaces → domain/repository
  - Repository implementations → data/repository
  - Requests → data/requests
  - UseCases → domain/use_cases
''',
  );

  static const mvvm = DesignPattern(
    name: 'MVVM (Model-View-ViewModel)',
    description: '''
MVVM separates the UI from business logic using ViewModels:
- Model: Data and business logic
- View: UI components (screens, widgets)
- ViewModel: Mediator between Model and View, handles UI logic

The View observes the ViewModel for state changes.''',
    benefits: [
      '🔗 Data Binding - Automatic UI updates when data changes',
      '🧪 Testability - ViewModels can be unit tested without UI',
      '♻️ Reusability - ViewModels can be reused across different views',
      '📐 Clean UI Code - Views contain no business logic',
      '🎨 Designer-Friendly - Designers can modify UI without affecting logic',
      '📱 Platform Agnostic - Same ViewModel works on different platforms',
    ],
    folderStructure: [
      'models',
      'views',
      'viewmodels',
      'services',
      'repositories',
      'widgets',
    ],
    aiPromptTemplate: '''
You are an expert AI in Flutter MVVM Architecture.
Goal:
- Organize files following MVVM pattern.
- Create ViewModels for each screen/view.
- Services handle external data (API, database).
- Models represent data structures.
- Views are pure UI with no business logic.
- Place files correctly:
  - Data models → models/
  - Screens/Pages → views/
  - State managers → viewmodels/
  - API/Database services → services/
  - Widgets → widgets/
''',
  );

  static const mvc = DesignPattern(
    name: 'MVC (Model-View-Controller)',
    description: '''
Classic MVC pattern adapted for Flutter:
- Model: Data and business rules
- View: UI presentation
- Controller: Handles user input and updates Model/View

Simple and widely understood pattern.''',
    benefits: [
      '📚 Simplicity - Easy to understand and implement',
      '👥 Familiar - Most developers already know MVC',
      '⚡ Quick Setup - Less boilerplate than other patterns',
      '🔀 Clear Data Flow - User → Controller → Model → View',
      '📦 Modular - Components can be developed independently',
      '🎯 Good for Small Apps - Perfect for simple to medium projects',
    ],
    folderStructure: [
      'models',
      'views',
      'controllers',
      'widgets',
      'services',
    ],
    aiPromptTemplate: '''
You are an expert AI in Flutter MVC Architecture.
Goal:
- Organize files following MVC pattern.
- Controllers handle user interactions and business logic.
- Models represent data and state.
- Views are pure UI components.
- Place files correctly:
  - Data classes → models/
  - Screens/UI → views/
  - Business logic → controllers/
  - Reusable UI → widgets/
  - External services → services/
''',
  );

  static const bloc = DesignPattern(
    name: 'BLoC Pattern',
    description: '''
Business Logic Component pattern for Flutter:
- Events: User actions/triggers
- States: UI states based on data
- BLoC: Transforms events into states

Reactive pattern using streams for state management.''',
    benefits: [
      '🌊 Reactive - Stream-based state management',
      '🧪 Highly Testable - Easy to test state transitions',
      '📊 Predictable - Clear event → state transformations',
      '🔄 Single Source of Truth - Centralized state management',
      '📱 Platform Independent - BLoC works across platforms',
      '🎯 Separation - UI completely separate from business logic',
    ],
    folderStructure: [
      'data/models',
      'data/repositories',
      'data/datasources',
      'domain/entities',
      'domain/repositories',
      'presentation/bloc',
      'presentation/screens',
      'presentation/widgets',
    ],
    aiPromptTemplate: '''
You are an expert AI in Flutter BLoC Architecture.
Goal:
- Organize files following BLoC pattern.
- Create BLoCs with Events and States for each feature.
- Repositories handle data operations.
- Entities represent core business objects.
- Place files correctly:
  - Data models → data/models/
  - Repository implementations → data/repositories/
  - Domain entities → domain/entities/
  - Repository interfaces → domain/repositories/
  - BLoC files → presentation/bloc/
  - Screens → presentation/screens/
  - Widgets → presentation/widgets/
''',
  );

  static const featureFirst = DesignPattern(
    name: 'Feature-First',
    description: '''
Organizes code by features instead of layers:
- Each feature is self-contained with its own layers
- Features can be developed, tested, and deployed independently
- Great for large teams and microservice-like architecture

Scales well with growing codebase.''',
    benefits: [
      '📦 Modularity - Each feature is a standalone module',
      '👥 Team Scalability - Teams own specific features',
      '🚀 Independent Deployment - Features can be released separately',
      '🔍 Easy Navigation - Find all feature code in one place',
      '♻️ Reusability - Features can be shared across apps',
      '🧹 Easy Cleanup - Remove feature by deleting its folder',
    ],
    folderStructure: [
      'features/[feature_name]/data/models',
      'features/[feature_name]/data/repositories',
      'features/[feature_name]/domain/entities',
      'features/[feature_name]/domain/usecases',
      'features/[feature_name]/presentation/pages',
      'features/[feature_name]/presentation/widgets',
      'features/[feature_name]/presentation/bloc',
      'core/utils',
      'core/theme',
      'core/widgets',
    ],
    aiPromptTemplate: '''
You are an expert AI in Flutter Feature-First Architecture.
Goal:
- Organize files by feature, each feature self-contained.
- Each feature has its own data, domain, and presentation layers.
- Shared code goes in core/ folder.
- Place files correctly:
  - Feature models → features/[feature]/data/models/
  - Feature repositories → features/[feature]/data/repositories/
  - Feature entities → features/[feature]/domain/entities/
  - Feature use cases → features/[feature]/domain/usecases/
  - Feature screens → features/[feature]/presentation/pages/
  - Feature widgets → features/[feature]/presentation/widgets/
  - Shared utilities → core/
''',
  );

  /// Get all available patterns
  static List<DesignPattern> get all => [
        cleanArchitecture,
        mvvm,
        mvc,
        bloc,
        featureFirst,
      ];

  /// Get pattern by index (1-based for CLI display)
  static DesignPattern getByIndex(int index) {
    if (index < 1 || index > all.length) {
      return cleanArchitecture; // Default
    }
    return all[index - 1];
  }

  /// Get pattern by name
  static DesignPattern? getByName(String name) {
    final lowerName = name.toLowerCase();
    for (final pattern in all) {
      if (pattern.name.toLowerCase().contains(lowerName)) {
        return pattern;
      }
    }
    return null;
  }
}
