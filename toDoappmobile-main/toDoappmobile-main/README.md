# Todo App with Theme Switching

A beautiful and intuitive Flutter todo app with comprehensive theme switching functionality. The app supports Light, Dark, and System theme modes with smooth transitions and persistent theme preferences.

## Features

### 🎨 Theme Switching
- **Light Mode**: Clean, bright interface with purple accent colors
- **Dark Mode**: Elegant dark interface with light purple accents
- **System Mode**: Automatically follows your device's system theme
- **Persistent Preferences**: Theme choice is remembered across app sessions
- **Smooth Transitions**: Beautiful animations when switching themes

### 📱 Todo Management
- Add, edit, and delete todos
- Categorize todos (Personal, Work, School, Urgent, Shopping, Health)
- Set due dates for todos
- Mark todos as completed
- Search functionality
- Filter by status (All, Pending, Completed) or categories
- Beautiful Material 3 design

### 🎯 User Experience
- Modern, responsive UI
- Smooth animations and transitions
- Intuitive navigation
- Accessibility-friendly designn
- Cross-platform support

## Theme Switching Implementation

### Architecture
The theme switching system is built using the Provider pattern for state management:

```
lib/
├── providers/
│   └── theme_provider.dart      # Theme state management
├── theme/
│   └── app_theme.dart          # Light and dark theme definitions
├── widgets/
│   └── theme_switcher.dart     # Theme switching UI components
└── screens/
    ├── login_screen.dart       # Login with theme switcher
    ├── home_screen.dart        # Main todo screen with theme switcher
    └── settings_screen.dart    # Dedicated settings screen
```

### Key Components

#### ThemeProvider
- Manages theme state using `ChangeNotifier`
- Supports Light, Dark, and System modes
- Provides theme information and switching methods
- Handles theme persistence (when shared_preferences is added)

#### AppTheme
- Defines comprehensive light and dark themes
- Uses Material 3 design system
- Consistent color schemes and typography
- Proper contrast ratios for accessibility

#### ThemeSwitcher Widgets
- **ThemeSwitcher**: Popup menu for quick theme switching
- **ThemeSwitcherCard**: Card-based theme selector with visual options
- **FloatingThemeSwitcher**: Animated floating action button

### Usage

#### Switching Themes
1. **App Bar**: Tap the theme icon in the app bar for a popup menu
2. **Settings Screen**: Navigate to Settings for a detailed theme selector
3. **Login Screen**: Theme switcher available in the top-right corner

#### Theme Options
- **Light**: Bright interface with dark text
- **Dark**: Dark interface with light text
- **System**: Follows device system theme automatically

### Code Examples

#### Using ThemeProvider
```dart
// Access theme provider
final themeProvider = Provider.of<ThemeProvider>(context);

// Switch themes
themeProvider.setThemeMode(ThemeMode.dark);
themeProvider.toggleTheme();

// Check current theme
if (themeProvider.isDarkMode) {
  // Dark mode specific code
}
```

#### Adding Theme Switcher to Your Screen
```dart
import '../widgets/theme_switcher.dart';

// In your app bar actions
actions: [
  const ThemeSwitcher(),
  // Other actions...
],

// Or as a floating action button
floatingActionButton: const FloatingThemeSwitcher(),
```

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `flutter`: Core Flutter framework
- `provider`: State management for theme switching
- `cupertino_icons`: iOS-style icons

## Future Enhancements

- [ ] Add shared_preferences for persistent theme storage
- [ ] Custom theme color picker
- [ ] Theme transition animations
- [ ] High contrast mode for accessibility
- [ ] Auto theme switching based on time of day

## Contributing

Feel free to contribute to this project by:
- Reporting bugs
- Suggesting new features
- Submitting pull requests
- Improving documentation

## License

This project is open source and available under the MIT License.
