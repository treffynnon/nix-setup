# Hammerspoon audio

Choice of where this Mac’s audio plays, plus Meet setup. Destinations, not individual gadgets, are what the destination hotkeys mean.

## Language

**Headphones destination**:
Where audio should go when the headphones hotkey is used. Preference order: `US-2x2`, then `External Headphones`.
_Avoid_: headphones device, Tascam 2x2 as the hotkey target

**Speakers destination**:
Where audio should go when the speakers hotkey is used. Preference order: `EDIFIER R1280DB`, then `MacBook Pro Speakers`.
_Avoid_: speakers device

**Playback output**:
The macOS default output device. Destination hotkeys set this only.
_Avoid_: treating destination hotkeys as also changing input

**Capture input**:
The macOS default input device. Destination hotkeys leave it alone.
_Avoid_: default input as a hotkey target

**Explicit switch**:
Playback output, capture input, and Key Light Neo power change on destination hotkeys (output only), Meet URL open, or Meet revert. Not on device plug or unplug.
_Avoid_: Hotkey-driven switch, BehringerUCA222, auto-default on plug, mute-all on unplug

**Successful switch**:
A destination hotkey that set playback output to the first preferred device that exists. The user is told the destination and the device that won.
_Avoid_: silent success

**Failed switch**:
A destination hotkey that matched none of its preferred outputs. The previous playback output stays; the user is told the switch failed and which device is still playing.
_Avoid_: silent miss, console-only failure

**Meet setup**:
The audio and lighting state prepared on Meet URL open: Meet playback output, Meet capture input, and Key Light Neo powered on. Distinct from Headphones destination and Speakers destination. Each part is applied independently; the Meet URL is still opened if some parts fail.
_Avoid_: headphones destination, call mode, meet profile, all-or-nothing

**Meet playback output**:
Preferred playback output during Meet setup. Order: `US-2x2`, then `External Headphones`, then `EDIFIER R1280DB`, then `MacBook Pro Speakers`. First successful switch wins.
_Avoid_: Headphones destination, Speakers destination

**Meet capture input**:
Preferred capture input during Meet setup. Order: `Yeti Stereo Microphone`, then `MacBook Pro Microphone`. First successful switch wins.
_Avoid_: Yeti, built-in mic

**Meet URL open**:
Opening a Google Meet URL through the system URL handler. In-browser navigation of Meet URLs does not apply Meet setup. Meet setup is applied then; it is not undone when the meeting ends.
_Avoid_: Chrome navigation, Meet tab, meeting joined, restore on leave

**Pre-Meet snapshot**:
The audio and lighting state in effect at the first unrestored Meet URL open. Later Meet URL opens leave this snapshot unchanged.
_Avoid_: stack of snapshots, overwrite on every Meet link

**Meet revert**:
Restores the Pre-Meet snapshot, best-effort per field, then always clears it. Missing devices or an unreachable Key Light Neo leave the current value. If there is no snapshot, nothing changes and the user is told there is nothing to revert.
_Avoid_: automatic restore, restore on leave, keep snapshot until full restore

**Meet report**:
A single alert after Meet setup or Meet revert listing playback, capture, and Key Light Neo: each either the device/state that won or that it failed and what is still in effect.
_Avoid_: silent success, three stacked alerts, Successful switch

**Key Light Neo**:
The Elgato Key Light Neo whose power is part of Meet setup. Meet URL open turns it on and does not change brightness or colour temperature. Already on counts as on.
_Avoid_: Stream Deck, brightness preset, colour temperature
