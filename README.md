# Workly - Job Swiping App

A Flutter-based job discovery app that allows users to swipe through job opportunities, similar to dating apps but for career opportunities.

## Features

- **Resume Upload & Parsing**: Upload DOCX, TXT, or PDF resumes and automatically extract profile information
- **Job Swiping**: Swipe right on jobs you like, left on jobs you don't
- **Profile Management**: Comprehensive user profiles with skills, experience, and education
- **Cross-Platform**: Works on Web, Android, iOS, Windows, macOS, and Linux
- **Real-time Parsing**: Extracts name, email, phone, location, skills, work experience, and education from resumes

## Resume Upload Features

- **Supported Formats**: DOCX, TXT (PDF falls back gracefully)
- **Automatic Data Extraction**: Parses resumes to populate user profiles
- **Cross-Platform Support**: Works on web browsers, mobile devices, and desktop
- **Smart Field Population**: Only fills empty fields, preserves user input
- **Visual Feedback**: Loading states, success messages, and error handling

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/workly.git
cd workly
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
# For web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Windows
flutter run -d windows
```

## Project Structure

```
lib/
├── models/           # Data models (User, Job)
├── screens/          # UI screens
├── services/         # Business logic (Resume parsing, File upload)
├── themes/           # App theming
└── widgets/          # Reusable UI components
```

## Resume Parsing

The app uses the `docx_to_text` package to parse DOCX files and extract:

- Personal information (name, email, phone, location)
- Professional summary
- Skills and technologies
- Work experience
- Education history

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **docx_to_text**: DOCX file parsing
- **file_picker**: File selection
- **path_provider**: File system access
- **permission_handler**: Platform permissions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
