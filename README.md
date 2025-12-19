# Detla Shelf

A modern Flutter library management application for tracking books, authors, readers, and loans.

## Features

### Current Features

- **Book Management**
  - View all books in the library
  - Track book availability status (on shelf / loaned)
  - Display book information with author details

- **Reader Management**
  - Add new readers to the system
  - View all registered readers
  - Track active loans per reader

- **Loan System**
  - Issue books to readers
  - Return books to the library
  - Track loan dates and return dates
  - Prevent issuing unavailable books

- **Smart Search**
  - Search across multiple fields simultaneously
  - Find books by title
  - Find books by author name
  - Find books by current reader (if loaned)
  - Combined results with full book and reader information

- **Data Persistence**
  - SQLite database for reliable data storage
  - Automatic database initialization
  - Demo data for testing

### Planned Features

- [ ] Advanced filtering and sorting options
- [ ] Book categories and genres
- [ ] Book images
- [ ] Reader statistics and activity history
- [ ] Overdue book notifications
- [ ] Export library data
- [ ] Dark theme support
- [ ] Multi-language support (i18n)

## Project Structure

```project
lib/
├── main.dart                          # App entry point
├── controllers/
│   └── book_controller.dart           # Business logic & state management
├── services/
│   └── library_core.dart              # Core library operations
├── database/
│   └── library_database.dart          # SQLite database initialization
├── models/
│   ├── database/                      # Models mapping to DB tables
│   │   ├── author.dart
│   │   ├── book.dart
│   │   ├── reader.dart
│   │   └── loan.dart
│   └── ui/                            # Models for UI layer
│       └── search_result.dart         # Combined search results
├── screens/
│   └── home_screen.dart               # Main app screen
└── widgets/
    ├── issue_dialog.dart              # Book issue dialog
    └── return_dialog.dart             # Book return dialog
```

## Architecture

- **Provider Pattern** - State management using `provider` package
- **Service Layer** - `LibraryCore` handles all business logic
- **Database Layer** - `LibraryDatabase` manages SQLite operations
- **Model Separation** - Database models and UI models are kept separate

## Database Schema

### Authors

```sql
CREATE TABLE authors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL
)
```

### Books

```sql
CREATE TABLE books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  status TEXT NOT NULL, -- 'on_shelf' or 'loaned'
  FOREIGN KEY (author_id) REFERENCES authors (id)
)
```

### Readers

```sql
CREATE TABLE readers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL
)
```

### Loans

```sql
CREATE TABLE loans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER NOT NULL,
  reader_id INTEGER NOT NULL,
  loan_date TEXT NOT NULL,
  return_date TEXT, -- NULL if book not returned
  FOREIGN KEY (book_id) REFERENCES books (id),
  FOREIGN KEY (reader_id) REFERENCES readers (id)
)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+

### Installation

```bash
# Clone the repository
git clone https://github.com/detla4796/online_library4796

# Navigate to project
cd online_library4796

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### First Run

The app automatically initializes the database with demo data on first launch:

- 2 sample authors (Фёдор Достоевский, Лев Толстой)
- 2 sample books
- 2 sample readers

To reinitialize with fresh demo data, call:

```dart
await core.initDemoData(force: true);
```

## Usage

### View Books

- Open the app to see all available books
- Each book shows title, author, and availability status

### Issue a Book

1. Tap the book you want to issue
2. Select a reader from the list
3. Confirm the transaction

### Return a Book

1. Tap the loaned book
2. Confirm return
3. Book status changes to "on_shelf"

### Search Books

- Use the search field to find books by:
  - Book title
  - Author name
  - Current reader name (if loaned)
- Results update in real-time

## Dependencies

```yaml
    sqflite: ^2.3.0
    path_provider: ^2.1.2
    path: ^1.9.0
    provider: ^6.0.5
```

## Development Notes

### Database Access

After initialization in `main()`, use synchronous database access:

```dart
final db = LibraryDatabase.instance.db; // No await needed
```

### Adding New Features

1. Add database changes in `LibraryDatabase`
2. Implement logic in `LibraryCore`
3. Add controller methods in `BookController`
4. Update UI in screens/widgets

## License

This project is open source and available under the MIT License.
