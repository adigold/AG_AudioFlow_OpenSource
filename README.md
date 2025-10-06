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

### Prerequisites
- macOS 10.13 or later
- Homebrew (for FFmpeg installation)
- Node.js (install with: `brew install node`)
- FFmpeg (install with: `brew install ffmpeg`)

### Install AG AudioFlow Services

1. **Clone the repository:**
```bash
git clone https://github.com/adigold/AG_AudioFlow_OpenSource.git
cd AG_AudioFlow_OpenSource
```

2. **Run the setup script:**
```bash
chmod +x simple-services.sh
./simple-services.sh
```

3. **Enable Services in System Preferences:**
   - Go to **System Preferences > Keyboard > Shortcuts > Services**
   - Scroll down to find "AG AudioFlow" services
   - Check the boxes to enable the services you want to use

4. **Restart Finder (optional):**
```bash
killall Finder
```

## Uninstall

To completely remove AG AudioFlow services:

```bash
# Remove all AG AudioFlow services
rm -rf ~/Library/Services/AG\ AudioFlow*

# Restart Finder to refresh Services menu
killall Finder
```

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

## Troubleshooting

### Common Issues

**Services not appearing in right-click menu:**
1. Make sure services are enabled in System Preferences > Keyboard > Shortcuts > Services
2. Restart Finder: `killall Finder`
3. Try running the setup script again

**"FFmpeg not found" error:**
```bash
brew install ffmpeg
```

**"Node not found" error:**
```bash
brew install node
```

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