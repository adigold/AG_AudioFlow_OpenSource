# AG AudioFlow - Simple Audio Processing for macOS

A simple command-line tool and macOS Services integration for audio processing. Right-click any audio file and process it with common audio operations.

## Features

- **Stereo to Mono** - Convert stereo audio to mono
- **Normalize** - Normalize audio levels
- **Volume Control** - Increase/decrease volume by 5dB
- **Format Conversion** - Convert to MP3 or WAV
- **Trim Silence** - Remove silence from beginning and end
- **Speed Up** - Increase playback speed by 1.5x

## Installation

1. Clone or download this repository
2. Run the setup script:
```bash
chmod +x simple-services.sh
./simple-services.sh
```

3. Enable Services in System Preferences:
   - Go to **System Preferences > Keyboard > Shortcuts > Services**
   - Look for "AG AudioFlow" services and enable them

## Usage

### Command Line
```bash
./agaudioflow <action> <audio-file>

# Examples:
./agaudioflow stereo-to-mono song.wav
./agaudioflow normalize podcast.mp3
./agaudioflow convert-mp3 audio.aiff
```

### Right-Click Services
1. Right-click any audio file in Finder
2. Go to **Services** menu
3. Choose an **AG AudioFlow** action
4. The processed file will appear next to the original

## Requirements

- macOS
- FFmpeg (installed automatically with Homebrew)

## Actions Available

- `stereo-to-mono` - Convert stereo to mono
- `normalize` - Normalize audio levels
- `volume-up` - Increase volume by 5dB
- `volume-down` - Decrease volume by 5dB
- `convert-mp3` - Convert to MP3 format
- `convert-wav` - Convert to WAV format
- `trim-silence` - Remove silence from start/end
- `speed-up` - Increase speed by 1.5x

## How It Works

Processed files are created next to the original file with a descriptive suffix:
- `song.wav` → `song_mono.wav` (stereo to mono)
- `audio.mp3` → `audio_normalized.mp3` (normalize)
- `track.aiff` → `track_converted.mp3` (convert to MP3)

## License

MIT License