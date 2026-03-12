# NexShell

A personal PowerShell configuration with utilities and features.

## Installation

Run this command in PowerShell:
```powershell
irm https://raw.githubusercontent.com/aksiez/PowerShell/main/install.ps1 | iex
```

## Features

- **upd** - Update NexShell to the latest version
- **reload** - Reload your PowerShell profile
- **batt** - Show battery status
- **ip** - Show your public IP address
- **port** - Check what process is using a specific port
- **psx** - Show top processes by CPU usage
- **mkcd** - Create a directory and cd into it
- **ff** - Fuzzy file finder
- And more!

## Configuration

Edit `config.toml` in your NexShell folder:
- `showWelcome` - Set to `false` to disable the welcome message on startup

## Updating

To update NexShell, simply run:
```powershell
upd
```

Or if you have an older version:
```powershell
cd ~/Documents/PowerShell/NexShell
git pull
```

## Requirements

- PowerShell 5.1+ or PowerShell Core
- Git (automatically installed if not present via Scoop)

## License

MIT
