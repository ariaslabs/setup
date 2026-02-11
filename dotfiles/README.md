# Dotfiles

This is your personal dotfiles repository.

## Structure

- `.` - Your actual configuration files (symlinked to home directory)
- `backup/` - Backup of original files before symlinking
- `backup/.config/` - Separate backup for config directories

## Usage

### Create symlinks:
```bash
link-dotfiles.sh
```

### Restore original files:
```bash
restore-dotfiles.sh
```

## Examples

Add your config files here:
- `.zshrc`
- `.gitconfig`
- `.vscode/settings.json`
- `.config/nvim/init.lua`

For directories like `.config/`, create the folder structure within `backup/.config/`.