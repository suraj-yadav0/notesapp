

# NotesApp

A simple, modern notes-taking app for Ubuntu Touch. Organize your thoughts, tasks, and ideas with an intuitive interface and rich features designed for mobile devices.

## Features

- Create, edit, and delete notes
- Rich text editor with formatting
- To-Do list management
- Dark mode support
- Easy navigation between notes and chapters
- Data persistence using local database
- Responsive UI built with QML

## Installation

### Prerequisites

- Ubuntu Touch device or emulator
- [Clickable](https://clickable.dev/) (for building and running apps)

### Clone & Run with Clickable

Clone the repository and run using Clickable:

```bash
git clone https://github.com/suraj-yadav0/notesapp.git
cd notesapp
clickable
```

This will build and launch NotesApp on your connected Ubuntu Touch device or emulator.

### Manual Build (Desktop Testing)

If you want to build and run on a desktop (for testing):

```bash
git clone https://github.com/suraj-yadav0/notesapp.git
cd notesapp
mkdir build && cd build
cmake ..
make
./notesapp
```

## Usage

Launch the app and start creating notes. Navigate between pages using the sidebar. Access settings for theme and preferences.

## Technologies Used

- Qt/QML
- C++
- CMake

## Contributing

Contributions are welcome! Please fork the repository, create a feature branch, and submit a pull request. For major changes, open an issue first to discuss your ideas.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

Copyright (C) 2025 Suraj Yadav
