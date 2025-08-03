# IconPlatformMPlusMidiTranslator
Icon M+ MIDI Translator
This tool allows the Icon Platform M+ control surface to function both as a standard DAW controller and as a set of MIDI CC faders, without needing to power cycle the device or losing features like the scroll wheel, transport controls (play, stop, etc.), or navigation buttons. Everything works as usual — only the fader behavior changes depending on the selected mode.

Key Features
MIDI Port Detection
Automatically identifies the Icon M+ MIDI ports and two IAC virtual ports: IconMidiCC (for MIDI CC output) and IconMixer2DAW (for DAW input).

Fader Data Filtering
Captures MIDI data from the Icon and filters only fader movements, sent as 14-bit pitch bend messages in MCU/Logic mode.

Dual Operation Modes

Control Surface Mode: Forwards raw fader data to IconMixer2DAW, allowing Logic to interpret it via Mackie Control.

MIDI CC Mode: Rescales the fader range and maps it to standard CCs (e.g. CC 1 Modulation, CC 11 Expression, etc.), sending them via IconMidiCC.

Logic Mode Range Notice
In Logic (MCU mode), faders do not transmit a full 0–127 range — they send 0 to 117. This app rescales that for MIDI CC use, but the UI displays raw values (0–117) to match Logic’s interpretation and maintain consistency.

Simple UI
A lightweight window lets you switch modes and monitor fader values. It can be closed while the app runs in the background, showing a tray icon in the macOS menu bar.

Seamlessly blend control surface and MIDI workflows without reconfiguring your setup.
