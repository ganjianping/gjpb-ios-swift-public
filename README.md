# GJPB iOS Swift Public

GAN JIANPING Blog

## Overview

GJPB is a native iOS application built using Swift and SwiftUI. It serves as a content-browsing platform for GAN JIANPING Blog, providing users with access to various content types, including Websites, Q&A, Articles, Images, Audios, Videos, and Files. The app supports bilingual functionality (English/Chinese), light/dark themes, and customizable accent colors.

## Features

- **Content Sections**: Websites, Q&A, Articles, Images, Audios, Videos, and Files.
- **Bilingual Support**: English and Chinese Simplified.
- **Theming**: Light/dark mode and 5 accent color options.
- **Offline Caching**: Caches app settings for faster startup.
- **Responsive Design**: Adaptive layouts for iPhone and iPad.
- **Accessibility**: VoiceOver support and dynamic type scaling.
- **Media Playback**: Inline video playback and persistent audio player.

## Architecture

### Tech Stack

- **Language**: Swift 6.2
- **Framework**: SwiftUI
- **Networking**: URLSession with async/await
- **State Management**: `@Observable` classes
- **Persistence**: UserDefaults
- **Minimum iOS Version**: 26
- **Dependencies**: None (pure Swift + Foundation + AVFoundation)

### Project Structure

```plaintext
├── Models/
│   ├── ApiTypes.swift            // API response models
│   ├── AppSetting.swift          // App settings model
│   ├── Website.swift             // Website model
│   ├── Question.swift            // Q&A model
│   ├── Article.swift             // Article models
│   ├── MediaItem.swift           // Media item model
│   └── FileItem.swift            // File model
├── Services/
│   ├── ApiService.swift          // Networking layer
│   └── AppSettingsService.swift  // App settings service
├── Stores/
│   ├── SettingsStore.swift       // Global settings store
│   └── AudioPlayerStore.swift    // Audio playback state
├── Views/
│   ├── ContentView.swift         // Main TabView
│   ├── Components/               // Shared UI components
│   ├── Websites/                 // Websites section
│   ├── Questions/                // Q&A section
│   ├── Articles/                 // Articles section
│   ├── Images/                   // Images section
│   ├── Audios/                   // Audios section
│   ├── Videos/                   // Videos section
│   └── Files/                    // Files section
```

## API Integration

The app communicates with the GAN JIANPING Blog API to fetch content. Key endpoints include:

| Endpoint         | Method | Description                  |
|------------------|--------|------------------------------|
| `app-settings`   | GET    | Fetch app settings           |
| `cms/websites`   | GET    | Fetch websites               |
| `cms/questions`  | GET    | Fetch Q&A items              |
| `cms/articles`   | GET    | Fetch articles               |
| `cms/images`     | GET    | Fetch images                 |
| `cms/videos`     | GET    | Fetch videos                 |
| `cms/audios`     | GET    | Fetch audios                 |
| `cms/files`      | GET    | Fetch files                  |

## Theming System

- **Light/Dark Mode**: Automatically adapts to system preferences.
- **Accent Colors**: Choose from Blue, Purple, Green, Orange, and Red.
- **Customization**: Users can toggle themes and select accent colors via the settings menu.

## Navigation

The app uses a `TabView` with 7 tabs:

| Tab       | Icon               | Description |
|-----------|--------------------|-------------|
| Websites  | `globe`            | Browse websites |
| Q&A       | `questionmark.circle` | View Q&A items |
| Articles  | `doc.text`         | Read articles |
| Images    | `photo`            | View images |
| Audios    | `headphones`       | Listen to audios |
| Videos    | `play.rectangle`   | Watch videos |
| Files     | `folder`           | Access files |

## Build & Run Requirements

- **Xcode**: 16+
- **iOS Deployment Target**: 26+
- **Bundle Identifier**: `com.ganjianping.blog`

## Contribution

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

