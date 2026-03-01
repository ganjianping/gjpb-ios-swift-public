# AI Prompt

The native iOS app (Swift / SwiftUI, minimum iOS 26) is a content-browsing platform with 7 content sections: Websites, Q&A, Articles, Images, Audios, Videos, and Files. It consumes a REST API and supports bilingual (English/Chinese), light/dark themes, and 5 accent colors.

### 1. Architecture & Tech Stack

- **Language**: Swift 6.2
- **UI Framework**: SwiftUI
- **Navigation**: NavigationStack with 4 TabViews: Websites, Articles, Images, More (Images, Audios, Videos, and Files)
- **Networking**: async/await with URLSession
- **State Management**: `@Observable` classes (or `ObservableObject` with `@StateObject`/`@EnvironmentObject`)
- **Persistence**: UserDefaults for settings (theme, language, accent color)
- **Minimum Target**: iOS 26
- **Dependencies**: No third-party dependencies (use native APIs for syntax highlighting, media playback, etc.)

### 2. Data Models

Define Swift structs conforming to `Codable` and `Identifiable`:

```swift
struct ApiStatus {
    let code: Int
    let message: String
    let errors: String?
}

struct ApiMeta {
    let serverDateTime: String
}

struct ApiListResponse<T: Codable> {
    let status: ApiStatus
    let data: T
    let meta: ApiMeta?
}

struct PagedData<T: Codable> {
    let content: [T]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
}
```

Other models include:

- `AppSetting`: `{ name: String, value: String, lang: String }`
- `Website`: `{ id: Int, name: String, url: String, ... }`
- `Question`: `{ id: Int, question: String, answer: String, ... }`
- `ArticleSummary` and `ArticleDetail`
- `MediaItem`: `{ id: Int, name: String?, title: String?, ... }`
- `FileItem`: `{ id: Int, name: String, description: String?, ... }`

### 3. API Layer

- **Base URL**: `https://www.ganjianping.com/blog/v1/public/`
- **Headers**: `Accept: application/json`
- **Pagination**: 0-based page indexing

Endpoints:

| Endpoint         | Method | Query Params                  | Response Type               |
|------------------|--------|------------------------------|-----------------------------|
| `app-settings`   | GET    | —                            | `ApiListResponse<[AppSetting]>` |
| `cms/websites`   | GET    | `page, size, search?, tag?`  | `ApiPagedResponse<Website>` |
| `cms/questions`  | GET    | `page, size, search?, tag?`  | `ApiPagedResponse<Question>` |
| `cms/articles`   | GET    | `page, size, lang?`          | `ApiPagedResponse<ArticleSummary>` |
| `cms/images`     | GET    | `page, size, lang?`          | `ApiPagedResponse<MediaItem>` |
| `cms/videos`     | GET    | `page, size, lang?`          | `ApiPagedResponse<MediaItem>` |
| `cms/audios`     | GET    | `page, size, lang?`          | `ApiPagedResponse<MediaItem>` |
| `cms/files`      | GET    | `page, size, lang?`          | `ApiPagedResponse<FileItem>` |

### 4. App Settings & Configuration

Fetch `AppSettings` on app launch. Store as an array grouped by `name` → dictionary of `[lang: value]`.

Key settings used by the app:

- `app_company`: Company name for footer
- `app_name`: App name for footer
- `app_version`: Version string for footer
- `website_tags`, `question_tags`, etc.: Comma-separated tag lists per language for filter UI

### 5. Global State (Settings Store)

Create an `@Observable` settings store providing:

| Property    | Type          | Default         | Persisted Key     |
|-------------|---------------|-----------------|-------------------|
| `theme`     | `"light"`/`"dark"` | System preference | `gjpb.theme`     |
| `language`  | `"EN"`/`"ZH"`      | Device locale     | `gjpb.language`  |
| `themeColor`| `"blue"`/`"purple"`/... | `"blue"`         | `gjpb.themeColor`|

### 6. Navigation & Layout

Use a `TabView` (bottom tab bar) with 7 tabs, each with its own `NavigationStack`:

| Tab       | Icon (SF Symbol) | Label (EN / ZH) |
|-----------|------------------|-----------------|
| Websites  | `globe`          | Websites / 网站 |
| Q&A       | `questionmark.circle` | Q&A / 问答 |
| Articles  | `doc.text`       | Articles / 文章 |
| Images    | `photo`          | Images / 图片   |
| Audios    | `headphones`     | Audios / 音频   |
| Videos    | `play.rectangle` | Videos / 视频   |
| Files     | `folder`         | Files / 文件    |

### 7. Shared UI Components

#### 7a. Search & Filter Toolbar

- **Search bar**: `.searchable(text:)` modifier with localized placeholder
- **Tag filter chips**: Horizontal `ScrollView` of tag buttons
- **Sort picker**: Menu or Picker with options: Default Order, Alphabetical, Most Recent

#### 7b. Pagination

- Infinite scroll (preferred for mobile)
- Show item count: `{startItem}–{endItem} of {totalElements}`

#### 7c. Skeleton Loading

- Placeholder/shimmer views (`.redacted(reason: .placeholder)`) while data is loading

#### 7d. Error & Empty States

- **Error state**: Show error message with a "Retry" button
- **Empty state**: Localized message like "No websites found" / "未找到网站"

### 8. Pages — Detailed Specifications

#### 8a. Websites Page

- Grid/List of `WebsiteCard` items
- Tap action: Open `website.url` in `SFSafariViewController`

#### 8b. Questions (Q&A) Page

- List of expandable `QuestionCard` items
- Expanded state: Render `answer` HTML content

#### 8c. Articles Page

- Grid of `ArticleCard` items
- Tap action: Navigate to `ArticleDetailView`

#### 8d. Article Detail Page

- Render `article.content` (HTML) using `WKWebView`

#### 8e. Images Page

- Grid layout using `LazyVGrid`
- Tap action: Open fullscreen `ImagePreview`

#### 8f. Audios Page

- List/Grid of `AudioCard` items
- Persistent bottom audio player

#### 8g. Videos Page

- List/Grid of `VideoCard` items
- Play video inline or navigate to a full-screen player

#### 8h. Files Page

- List of `FileCard` items
- Tap/Download action: Open `file.url` via `SFSafariViewController`

### 9. Internationalization (i18n)

Support English (EN) and Chinese Simplified (ZH). The language is toggled at runtime.

### 10. Theming System

- **Light/Dark mode**: Use `.preferredColorScheme(.light / .dark)`
- **Accent colors**: Apply `.tint(accentColor)` globally

### 11. Project Structure

```plaintext
├── Models/
│   ├── ApiTypes.swift
│   ├── AppSetting.swift
│   ├── Website.swift
│   ├── Question.swift
│   ├── Article.swift
│   ├── MediaItem.swift
│   └── FileItem.swift
├── Services/
│   ├── ApiService.swift
│   └── AppSettingsService.swift
├── Stores/
│   ├── SettingsStore.swift
│   └── AudioPlayerStore.swift
├── Localization/
│   └── Localizer.swift
├── Views/
│   ├── ContentView.swift
│   ├── Components/
│   ├── Websites/
│   ├── Questions/
│   ├── Articles/
│   ├── Images/
│   ├── Audios/
│   ├── Videos/
│   └── Files/
```

### 12. Key iOS-Specific Behaviors

1. Pull-to-refresh on all list views
2. Infinite scroll
3. Image caching
4. Audio continuity
5. Haptic feedback
6. Swipe gestures
7. iPad support
8. Dynamic Type
9. VoiceOver accessibility
10. Deep linking

### 13. Build & Run Requirements

- **Xcode**: 16+
- **iOS Deployment Target**: 26+
- **Dependencies**: None (pure SwiftUI + Foundation + AVFoundation)
- **Bundle Identifier**: `com.ganjianping.blog`