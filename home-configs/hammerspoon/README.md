# Hammerspoon Configuration

This directory contains a comprehensive Hammerspoon configuration that provides window management, USB device control, audio switching, and various system automation features.

## 📁 Directory Structure

```
hammerspoon/
├── init.lua                    # Main configuration file
├── uhubctl.lua                 # USB power management library
├── README.md                   # This documentation
└── Spoons/                     # Hammerspoon extensions
    ├── AudioSwitcher.spoon/    # Audio output device switching
    ├── BehringerUCA222.spoon/  # Behringer audio interface management
    ├── ControlEscape.spoon/    # Caps Lock → Escape/Control functionality
    ├── ElgatoStreamDeck.spoon/ # Stream Deck USB power management
    ├── MiroWindowsManager.spoon/ # Advanced window management
    ├── MouseBackButton.spoon/  # Mouse back button handling
    ├── OpenApplication.spoon/  # Application launcher utilities
    ├── ScreenPresets.spoon/    # Display configuration presets
    ├── URLDispatcher.spoon/    # URL handling and routing
    ├── USBPortPowerToggler.spoon/ # General USB port power control
    ├── WindowScreenLeftAndRight.spoon/ # Window movement between screens
    ├── fnutils.lua             # Functional programming utilities
    ├── inspect.lua             # Debugging and inspection utilities
    └── mock-hammerspoon.lua    # Testing utilities
```

## 🚀 Core Features

### Window Management

- **MiroWindowsManager**: Advanced window positioning with keyboard shortcuts
  - Move windows to halves, thirds, quarters
  - Corner positioning and centring
  - Multi-monitor support
- **WindowScreenLeftAndRight**: Quick window movement between multiple displays
- **ScreenPresets**: Save and restore display configurations

### USB Device Control

- **ElgatoStreamDeck**: Automatically manages Stream Deck power during sleep/wake cycles
- **USBPortPowerToggler**: General USB port power management
- **uhubctl.lua**: Low-level USB hub control library with device discovery

### Audio Management

- **AudioSwitcher**: Quick switching between speakers and headphones
  - `Cmd+Alt+S`: Switch to speakers
  - `Cmd+Alt+H`: Switch to headphones
- **BehringerUCA222**: Specific management for Behringer audio interfaces

### System Enhancements

- **ControlEscape**: Makes Caps Lock behave as Escape when tapped, Control when held
- **MouseBackButton**: Handles mouse back button functionality
- **URLDispatcher**: Smart URL routing and handling
- **OpenApplication**: Enhanced application launching utilities

## ⌨️ Key Bindings

### Window Management (MiroWindowsManager)

The window management uses a "hyper" key combination (`Ctrl+Alt+Cmd`) plus directional keys:

- **Hyper + Arrow Keys**: Move windows to screen halves
- **Hyper + Number Keys**: Position windows in specific areas
- **Hyper + Enter**: Centre window
- **Hyper + Space**: Maximise window

### Audio Switching

- **Cmd+Alt+S**: Switch to speakers
- **Cmd+Alt+H**: Switch to headphones

### Control Enhancement

- **Caps Lock (tap)**: Escape key
- **Caps Lock (hold)**: Control key

## 🔧 Configuration Files

### `init.lua`

The main configuration file that:

- Loads all Spoons
- Sets up key bindings
- Configures alert styles
- Initializes USB power management
- Sets window animation duration

### `uhubctl.lua`

A comprehensive USB control library that provides:

- Device discovery and enumeration
- Power state management
- Persistent state storage
- Error handling and logging
- Integration with system sleep/wake events

## 📱 Stream Deck Integration

The ElgatoStreamDeck Spoon provides sophisticated USB power management:

1. **Auto-discovery**: Finds Stream Deck devices automatically
2. **Sleep/Wake Integration**: Powers down Stream Deck during system sleep
3. **State Persistence**: Remembers device states across system restarts
4. **Error Recovery**: Handles USB enumeration failures gracefully

### How It Works

- Monitors system sleep/wake notifications
- Uses `uhubctl` to control USB port power
- Maintains device state in JSON files
- Provides logging for troubleshooting

## 🔊 Audio Device Management

### AudioSwitcher Features

- Quick keyboard shortcuts for common audio devices
- Seamless switching without interrupting playback
- Support for multiple output device types

### BehringerUCA222 Integration

- Specific handling for Behringer USB audio interfaces
- Automatic device detection and configuration
- Optimized settings for audio production workflows

## 🖥️ Multi-Monitor Support

### ScreenPresets

- Save current display arrangements
- Quickly restore saved configurations
- Handle display connection/disconnection events

### WindowScreenLeftAndRight

- Move windows between displays with keyboard shortcuts
- Maintains window size and relative positioning
- Works with any number of connected displays

## 🛠️ Development and Testing

### Utilities

- **fnutils.lua**: Functional programming helpers for Lua
- **inspect.lua**: Deep inspection and debugging utilities
- **mock-hammerspoon.lua**: Testing framework for Spoon development

### Testing

The configuration includes testing utilities for:

- Spoon functionality validation
- USB control testing
- Window management verification

## 📝 Setup Instructions

1. **Install Hammerspoon**: Download from [hammerspoon.org](https://www.hammerspoon.org/)
2. **Enable Accessibility**: System Preferences → Security & Privacy → Accessibility → Add Hammerspoon
3. **Auto-start**: Set Hammerspoon to launch at login
4. **USB Control**: Ensure `uhubctl` is available in PATH (installed via Nix)

### Required Permissions

- **Accessibility**: For window management and key remapping
- **Input Monitoring**: For global keyboard shortcuts
- **Camera/Microphone**: If using audio device switching

## 🐛 Troubleshooting

### Common Issues

1. **USB Control Not Working**:

   - Check that `uhubctl` is installed: `which uhubctl`
   - Verify USB device permissions
   - Check Hammerspoon console for errors

2. **Window Management Not Responding**:

   - Ensure Accessibility permissions are granted
   - Restart Hammerspoon after permission changes
   - Check for conflicting keyboard shortcuts

3. **Audio Switching Fails**:
   - Verify audio devices are properly connected
   - Check System Preferences → Sound for device availability
   - Review Hammerspoon console logs

### Logging and Debugging

- Open Hammerspoon Console: Click Hammerspoon menubar icon → Console
- Enable debug logging in individual Spoons
- Check system logs for USB-related errors: `log show --predicate 'subsystem contains "usb"'`

## 🔗 Related Documentation

- [Hammerspoon API Documentation](http://www.hammerspoon.org/docs/)
- [MiroWindowsManager Documentation](https://github.com/miromannino/miro-windows-manager)
- [uhubctl Documentation](https://github.com/mvp/uhubctl)
- [Stream Deck Technical Specifications](https://www.elgato.com/en/stream-deck)

## 📄 Licence

Individual Spoons maintain their own licences:

- **MiroWindowsManager**: MIT Licence
- **ControlEscape**: MIT Licence
- **ElgatoStreamDeck**: Custom (part of this configuration)
- **Other Spoons**: Various open source licences

This configuration is provided as-is for educational and personal use.
