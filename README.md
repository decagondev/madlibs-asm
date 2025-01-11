# Mad Libs Assembly Application

A high-performance Windows desktop application for generating and playing Mad Libs, written in x86_64 assembly language. This retro-inspired application provides an interactive way to create fun stories by inputting different types of words.

## Features

- Clean, minimalist user interface
- Multiple story templates with random selection
- Real-time input validation
- Animated story display
- High-performance native Windows application
- Custom font rendering
- Clear/Reset functionality

## Prerequisites

Before building the application, ensure you have the following installed:

1. **NASM (Netwide Assembler)** - Version 2.15 or higher
   - Download from: https://www.nasm.us/
   - Add NASM to your system PATH

2. **Microsoft Visual Studio Build Tools**
   - Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
   - Required components:
     - Windows SDK
     - MSVC v143 build tools (or latest version)
     - C++ build tools core features

3. **Windows Development Environment**
   - Windows 10 or Windows 11
   - Administrator privileges for installation

## Building the Application

### Command Line Build

1. Open "x64 Native Tools Command Prompt for VS" (comes with Visual Studio Build Tools)

2. Navigate to the project directory:
   ```batch
   cd path\to\madlibs
   ```

3. Assemble the source code:
   ```batch
   nasm -f win64 madlibs.asm -o madlibs.obj
   ```

4. Link the object file:
   ```batch
   link /subsystem:windows madlibs.obj kernel32.lib user32.lib gdi32.lib
   ```

### Build Script

Alternatively, you can use the following batch script (save as `build.bat`):

```batch
@echo off
nasm -f win64 madlibs.asm -o madlibs.obj
if %errorlevel% neq 0 (
    echo Assembly failed
    exit /b %errorlevel%
)
link /subsystem:windows madlibs.obj kernel32.lib user32.lib gdi32.lib
if %errorlevel% neq 0 (
    echo Linking failed
    exit /b %errorlevel%
)
echo Build successful
```

Run the script:
```batch
build.bat
```

## Running the Application

After successful compilation, run the application by double-clicking `madlibs.exe` or from the command line:
```batch
madlibs.exe
```

## Usage Instructions

1. Launch the application
2. Enter requested words in each field:
   - Noun field
   - Verb field
   - Adjective field
3. Click "Generate Story" to create your Mad Lib
4. Click "Clear All" to start over
5. Click "Exit" to close the application

## Technical Details

- Written in x86_64 assembly language using NASM
- Uses Windows API (Win32) for UI components
- Implements custom memory management
- Uses GDI+ for text rendering
- Follows Windows x64 calling convention

## File Structure

```
madlibs-asm/
│
├── madlibs.asm          # Main source code
├── build.bat           # Build script
├── README.md          # This file
└── LICENSE            # License file
```

## Common Issues and Solutions

1. **"nasm not recognized" error**
   - Make sure NASM is properly installed and added to PATH
   - Try restarting the command prompt after installation

2. **Linking errors**
   - Ensure you're using x64 Native Tools Command Prompt
   - Verify all required libraries are available

3. **Runtime errors**
   - Verify Windows SDK installation
   - Check system compatibility (must be 64-bit Windows)

## Contributing

Contributions are welcome! Some areas for potential improvement:

- Additional story templates
- Enhanced animations
- Sound effects
- Save/load functionality
- Custom color schemes

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- NASM development team
- Microsoft Windows SDK documentation
- Assembly language community

## Version History

- 1.0.0 (2025-01-11)
  - Initial release
  - Basic story generation
  - Animation support
  - Multiple templates
