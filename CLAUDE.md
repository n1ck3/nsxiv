# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

nsxiv (Neo Simple X Image Viewer) is a lightweight image viewer for X11, forked from sxiv. It's a C program that uses Imlib2 for image loading and X11 for display. The project prioritizes simplicity, extensibility, and maintaining compatibility as a drop-in replacement for sxiv.

## Build Commands

- **Quick build and install**: `./install.sh` - Cleans, builds, installs system-wide (if script exists)
- **Clean build**: `make clean && make`
- **Incremental build**: `make`
- **Install**: `sudo make install`
- **Install everything**: `sudo make install-all` (binary, desktop entry, and icons)
- **Build without optional deps**: `make OPT_DEP_DEFAULT=0`
- **Disable specific features**:
  - `make HAVE_LIBEXIF=0` - Disable EXIF support
  - `make HAVE_LIBFONTS=0` - Disable font/status bar support
  - `make HAVE_INOTIFY=0` - Disable auto-reload support
- **Note**: No unit tests - manual testing required

## Repository Structure

### Key Files
- `config.def.h` - Default configuration (copy to `config.h` before building)
- `config.mk` - Build configuration (paths, optional libraries, compiler flags)
- `nsxiv.h` - Main header with data structures and type definitions
- `commands.h` - Command definitions and key bindings
- `main.c` - Entry point and event loop
- `etc/examples/` - Example scripts for key-handler, image-info, etc.

### Branch Strategy
- `master` - Pristine copy of upstream (NEVER modify)
- `prod` - Production customizations on top of master

## Architecture

### Core Components
- **main.c** - Entry point, event loop, and coordination between modules
- **image.c** - Core image loading, caching, and manipulation (zoom, rotate, pan)
- **window.c** - X11 window management, drawing, and event handling
- **thumbs.c** - Thumbnail mode implementation and thumbnail caching
- **commands.c** - Command execution and key/button binding handlers
- **options.c** - Command-line argument parsing and configuration
- **autoreload.c** - File monitoring for auto-reload (using inotify on Linux)
- **util.c** - Utility functions for memory management, string operations, etc.

### Key Data Structures
- `img_t` - Represents an image with its display state
- `win_t` - Window and X11 display information
- `tns_t` - Thumbnail mode state and cache
- `fileinfo_t` - File metadata and loading state

### Configuration System
- Runtime configuration via `config.h` (user customization)
- Build-time configuration via `config.mk` (paths, dependencies)
- External scripts for extensibility (key-handler, image-info, thumb-info, win-title)

### Operating Modes
- **Image mode** - Single image viewing with zoom, pan, rotate
- **Thumbnail mode** - Grid view of all images with selection

## Development Workflow

### Updating from Upstream
1. Ensure upstream remote: `git remote add upstream https://codeberg.org/nsxiv/nsxiv.git`
2. Update master: `git checkout master && git fetch upstream master && git rebase upstream/master && git push origin master`
3. Rebase prod: `git checkout prod && git rebase master` (resolve conflicts if any)
4. Build and test: `./install.sh` or `make clean && make && sudo make install`
5. Push: `git push --force-with-lease origin prod`

### Making Changes
1. Work on `prod` branch for customizations
2. Edit `config.h` for runtime configuration changes
3. Follow existing code patterns and style
4. Test thoroughly - no automated tests available
5. Run static analysis: `./etc/woodpecker/analysis.sh`

### Quick Reference Commands
- **Check status**: `git status`
- **View recent commits**: `git log --oneline --graph --decorate -10`
- **Compare branches**: `git diff master..prod`
- **View compiler flags**: `make dump_cppflags`
- **Emergency rollback**: `git checkout prod && git reset --hard origin/prod`

## Code Quality

### Static Analysis
```bash
# Run all checks (cppcheck and clang-tidy)
./etc/woodpecker/analysis.sh

# Run cppcheck only
cppcheck --std=c99 --enable=performance,portability \
    --force --quiet --inline-suppr --error-exitcode=1 \
    --check-level=exhaustive \
    $(make OPT_DEP_DEFAULT=1 dump_cppflags) -DDEBUG *.c

# Check for issues with minimal build
make OPT_DEP_DEFAULT=0 dump_cppflags  # Then use output with cppcheck
```

## Code Style

- **Language**: C99 standard
- **Indentation**: Tabs (not spaces)
- **Naming**: snake_case for functions/variables, SCREAMING_SNAKE_CASE for macros
- **Braces**: Opening brace on same line
- **Comments**: Code should be self-documenting; avoid unnecessary comments
- **Error handling**: Check return values, use `error()` for fatal errors
- **Memory**: Free all allocated resources, especially X resources

## Important Notes

- Image format support is handled by Imlib2 - format requests go upstream
- Maintain backwards compatibility with sxiv
- Avoid adding new dependencies; if necessary, add compile-time switches
- Consider external scripts before adding features to core
- Project scope: bug fixes, maintenance, and simple extensibility over new features
- The project is hosted on Codeberg, mirrored to GitHub