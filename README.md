# CCUsage Menu Bar Extra

A macOS menu bar application that displays Claude API usage and costs using [ccusage](https://github.com/ryoppippi/ccusage).

## Features

- 📊 Real-time display of today's Claude API costs in the menu bar
- 💰 Monthly cost tracking
- 🔄 Automatic refresh every 5 minutes
- 📈 Detailed token usage breakdown
- 🎯 Native macOS app using SwiftUI

## Requirements

- macOS 13.0+
- [ccusage](https://github.com/ryoppippi/ccusage) installed (`npm install -g ccusage`)
- Claude API usage data

## Installation

### From Source

1. Clone this repository:
```bash
git clone https://github.com/yourusername/ccusage-menu-bar-extra.git
cd ccusage-menu-bar-extra/CCUsageMenuBar
```

2. Build the app:
```bash
swift build -c release
```

3. Run the app:
```bash
.build/release/CCUsageMenuBar
```

### Optional: Install to Applications

```bash
cp -r .build/release/CCUsageMenuBar /Applications/
```

## Usage

1. Click on the cost display in the menu bar to see detailed usage
2. The app automatically refreshes every 5 minutes
3. Click "Refresh" to manually update the data
4. Click "Quit" to exit the application

## Development

Open the project in Xcode:
```bash
open Package.swift
```

## License

MIT

## Acknowledgments

- [ccusage](https://github.com/ryoppippi/ccusage) by ryoppippi for the Claude usage analysis tool
- Built with SwiftUI and Swift Package Manager