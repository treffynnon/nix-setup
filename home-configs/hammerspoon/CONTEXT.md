# Hammerspoon audio

Keyboard-driven choice of where this Mac’s audio plays. Destinations, not individual gadgets, are what the hotkeys mean.

## Language

**Headphones destination**:
Where audio should go when the headphones hotkey is used. Preference order: `US-2x2`, then `External Headphones`.
_Avoid_: headphones device, Tascam 2x2 as the hotkey target

**Speakers destination**:
Where audio should go when the speakers hotkey is used. Preference order: `EDIFIER R1280DB`, then `MacBook Pro Speakers`.
_Avoid_: speakers device

**Playback output**:
The macOS default output device the hotkeys set. Input devices are out of scope.
_Avoid_: default input

**Hotkey-driven switch**:
Playback output changes only when a destination hotkey is pressed.
_Avoid_: BehringerUCA222, auto-default on plug, mute-all on unplug

**Successful switch**:
A destination hotkey that set playback output to the first preferred device that exists. The user is told the destination and the device that won.
_Avoid_: silent success

**Failed switch**:
A destination hotkey that matched none of its preferred outputs. The previous playback output stays; the user is told the switch failed and which device is still playing.
_Avoid_: silent miss, console-only failure
