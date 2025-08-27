# nsxiv Production Branch Management

## Updating from Upstream

### Prerequisites
Ensure the upstream remote is configured:
```bash
git remote add upstream https://codeberg.org/nsxiv/nsxiv.git
# or if using GitHub mirror:
# git remote add upstream https://github.com/nsxiv/nsxiv.git
```

### Step 1: Sync Master with Upstream
First, update the pristine `master` branch:
```bash
git checkout master
git fetch upstream master
git rebase upstream/master
git push origin master
```

**Note**: There should be no conflicts here since `master` must remain pristine and unchanged.

### Step 2: Rebase Production Branch

**Warning**: This may produce conflicts that need to be resolved.

Rebase `prod` branch against the updated `master`:
```bash
git checkout prod
git rebase master
```

#### Handling Conflicts
If merge conflicts occur:

1. **Resolve conflicts** in the affected files (use `git status` to see conflicted files)
   ```bash
   git status
   # Edit conflicted files to resolve conflicts
   # Look for <<<<<<< HEAD markers
   ```

2. **Stage resolved files** and continue the rebase:
   ```bash
   git add resolved_file.c
   git rebase --continue
   ```

3. **If things go wrong**, you can always abort:
   ```bash
   git rebase --abort
   ```

Common conflict areas:
- `config.h` - Your custom configuration vs upstream changes
- `config.mk` - Build configuration modifications
- Key bindings in `commands.c` or `config.def.h`

### Step 3: Build and Test

After rebasing, rebuild and test nsxiv:
```bash
# If install.sh exists:
./install.sh

# Otherwise:
make clean
rm -f config.h  # Force regeneration from config.def.h
make
sudo make install
```

Test functionality:
- Open various image formats (PNG, JPG, GIF, etc.)
- Test thumbnail mode (press `t`)
- Verify your custom key bindings work
- Check that scripts (key-handler, image-info) still function

### Step 4: Push Changes

Once everything is working:
```bash
git push --force-with-lease origin prod
```

**Note**: Force push is required after rebasing. The `--force-with-lease` option is safer than `--force` as it ensures you don't overwrite any remote changes you haven't seen.

## Quick Reference

### Check Current Branch Status
```bash
git status
git log --oneline --graph --decorate -10
```

### View Differences
```bash
git diff master..prod  # See your customizations
git log master..prod   # See your commits
```

### Emergency Rollback
If an update breaks something critical:
```bash
git checkout prod
git reset --hard origin/prod  # Reset to last known good state
```

### Build Variations
```bash
# Full build with all features
make clean && make

# Minimal build (no optional dependencies)
make clean && make OPT_DEP_DEFAULT=0

# Debug build
make clean && make CFLAGS="-Wall -pedantic -DDEBUG -g3"
```

## Customization Management

### Tracking Your Changes
Keep your customizations organized:

1. **config.h** - Your runtime configuration
   - Key bindings
   - Colors and fonts
   - Default behaviors

2. **config.mk** - Build configuration
   - Installation paths
   - Optional dependencies
   - Compiler flags

3. **Custom scripts** in `~/.config/nsxiv/exec/`
   - key-handler
   - image-info
   - thumb-info

### Backup Your Configuration
Before updating, backup your customizations:
```bash
cp config.h config.h.backup
cp config.mk config.mk.backup
# Backup any custom scripts
tar -czf nsxiv-scripts-backup.tar.gz ~/.config/nsxiv/exec/
```

## Important Notes

1. **Never modify `master`** - It must remain identical to upstream/master
2. **Always test** after rebasing before pushing
3. **Keep backups** of your `config.h` and custom scripts before updating
4. **Document conflicts** - Keep notes on recurring conflict resolutions for future updates
5. **Static analysis** - Run `./etc/woodpecker/analysis.sh` after making changes

## Troubleshooting

### X11 Connection Issues
If nsxiv fails to start after update:
```bash
# Check X11 is running
echo $DISPLAY
xset q

# Rebuild with debug info
make clean && make CFLAGS="-Wall -pedantic -DDEBUG -g3"
```

### Missing Dependencies
```bash
# Debian/Ubuntu
sudo apt-get install libimlib2-dev libx11-dev libxft-dev libexif-dev

# Arch Linux
sudo pacman -S imlib2 libx11 libxft libexif

# Build without optional deps if needed
make clean && make HAVE_LIBFONTS=0 HAVE_LIBEXIF=0
```

### Performance Issues
If image loading is slow:
```bash
# Clear thumbnail cache
rm -rf ~/.cache/nsxiv

# Rebuild with optimizations
make clean && make CFLAGS="-O3 -march=native"
```