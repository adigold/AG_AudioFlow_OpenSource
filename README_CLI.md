# AG AudioFlow CLI for macOS

Professional audio processing CLI tool with macOS Quick Actions integration. Process audio files directly from the command line or right-click context menu in Finder.

## Features

### Core Audio Processing
- **Stereo to Mono Conversion** - Mix, left channel only, or right channel only
- **Split Stereo Channels** - Extract left and right channels as separate files
- **Audio Format Conversion** - Convert between MP3, WAV, AAC, FLAC, OGG with bitrate control
- **Volume Adjustment** - Precise dB control for volume changes
- **Audio Normalization** - Standardize audio levels (LUFS)
- **Silence Trimming** - Remove silence from beginning and end with threshold control
- **Fade Effects** - Add fade in/out effects with customizable duration
- **Speed Adjustment** - Change playback speed with optional pitch preservation

### Advanced Features
- **Batch Processing** - Process multiple files with the same operation
- **Audio Merging** - Combine multiple audio files with optional crossfade
- **Extract Audio from Video** - Extract audio track from video files
- **Channel Manipulation** - Change number of audio channels (mono/stereo/multi-channel)
- **Sample Rate Conversion** - Change audio sample rate (8kHz to 192kHz)
- **EQ Presets** - Apply equalizer presets (bass, treble, vocal, loudness)
- **Audio Reversal** - Reverse audio playback for special effects
- **Audio Information** - Display detailed file metadata

### macOS Integration
- **Quick Actions** - Right-click audio processing in Finder
- **Batch Quick Actions** - Process multiple selected files at once
- **System Notifications** - Get notified when processing completes

## Installation

### Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/adigold/AG_AudioFlow_OpenSource.git
cd AG_AudioFlow_OpenSource

# Make install script executable
chmod +x install.sh

# Run the installer
./install.sh
```

The installer will:
1. Install Homebrew (if needed)
2. Install FFmpeg via Homebrew
3. Install Node.js (if needed)
4. Install AG AudioFlow CLI globally
5. Set up macOS Quick Actions for right-click functionality

### Manual Installation

If you prefer to install manually:

```bash
# Install dependencies
brew install ffmpeg node

# Clone the repository
git clone https://github.com/adigold/AG_AudioFlow_OpenSource.git
cd AG_AudioFlow_OpenSource

# Install Node.js dependencies
npm install

# Install globally
npm install -g .

# Set up Quick Actions (optional)
chmod +x setup-mac-services.sh
./setup-mac-services.sh
```

## CLI Usage

### Basic Syntax
```bash
agaudioflow <command> <input-file> [options]
```

### Core Commands

#### Stereo to Mono
```bash
# Mix both channels (default)
agaudioflow stereo-to-mono audio.mp3

# Use left channel only
agaudioflow s2m audio.mp3 left

# Use right channel only
agaudioflow s2m audio.mp3 right output_mono.mp3
```

#### Split Stereo Channels
```bash
# Split into left and right files
agaudioflow split-stereo recording.wav

# Specify output directory
agaudioflow split recording.wav /path/to/output/
```

#### Convert Format
```bash
# Convert to MP3
agaudioflow convert music.wav mp3

# Convert to FLAC with custom output
agaudioflow cvt audio.mp3 flac output.flac
```

#### Normalize Audio
```bash
# Default normalization (-23 LUFS)
agaudioflow normalize podcast.mp3

# Custom target level
agaudioflow norm podcast.mp3 -16
```

#### Adjust Volume
```bash
# Increase volume by 5dB
agaudioflow volume song.mp3 5

# Decrease volume by 10dB
agaudioflow vol song.mp3 -10 quieter.mp3
```

#### Trim Silence
```bash
# Default threshold (-50dB)
agaudioflow trim-silence interview.wav

# Custom threshold
agaudioflow trim interview.wav -40
```

#### Add Fade Effects
```bash
# Add 2-second fade in and 3-second fade out
agaudioflow fade music.mp3 2 3

# Only fade in
agaudioflow fade music.mp3 2 0

# Only fade out
agaudioflow fade music.mp3 0 3
```

#### Adjust Speed
```bash
# Half speed (50%)
agaudioflow speed audiobook.mp3 50

# Double speed (200%)
agaudioflow speed podcast.mp3 200

# 1.5x speed without pitch preservation
agaudioflow speed music.mp3 150 false
```

#### Get Audio Info
```bash
agaudioflow info track.mp3
```

### Advanced Commands

#### Batch Processing
```bash
# Normalize all MP3 files in current directory
agaudioflow batch normalize "*.mp3" ./output

# Convert all WAV files to FLAC
agaudioflow batch convert "*.wav" ./converted flac

# Trim silence from all audio files
agaudioflow batch trim "audio/*.mp3" ./trimmed -40
```

#### Merge Audio Files
```bash
# Simple concatenation
agaudioflow merge file1.mp3 file2.mp3 file3.mp3 output.mp3

# With 2-second crossfade
agaudioflow concat song1.mp3 song2.mp3 song3.mp3 album.mp3 --crossfade=2
```

#### Extract Audio from Video
```bash
# Extract as MP3 (default)
agaudioflow extract-audio video.mp4

# Extract as specific format
agaudioflow extract video.mkv wav soundtrack.wav
```

#### Change Channels
```bash
# Convert to mono (1 channel)
agaudioflow channels stereo.mp3 1

# Convert to stereo (2 channels)
agaudioflow channels mono.mp3 2 stereo_output.mp3
```

#### Change Sample Rate
```bash
# Convert to 48kHz
agaudioflow sample-rate audio.mp3 48000

# Convert to 44.1kHz (CD quality)
agaudioflow sr podcast.mp3 44100 cd_quality.mp3
```

#### Apply EQ Presets
```bash
# Apply bass boost
agaudioflow eq music.mp3 bass

# Apply vocal enhancement
agaudioflow eq podcast.mp3 vocal

# Available presets: bass, treble, vocal, flat, loudness
```

#### Reverse Audio
```bash
# Create reversed version
agaudioflow reverse song.mp3

# Specify output
agaudioflow reverse voice.wav reversed_voice.wav
```

## macOS Quick Actions

After installation, you can process audio files directly from Finder:

1. **Select** one or more audio files in Finder
2. **Right-click** to open the context menu
3. Look for **Quick Actions** (or **Services** on older macOS)
4. Select any **AG AudioFlow** action:

### Basic Actions
- **Stereo to Mono** - Convert stereo files to mono
- **Split Stereo** - Split into left and right channels
- **Normalize Audio** - Standardize volume levels
- **Trim Silence** - Remove quiet sections

### Format Conversion
- **Convert to MP3** - Compress for smaller file size
- **Convert to WAV** - Uncompressed high quality
- **Convert to FLAC** - Lossless compression

### Audio Effects
- **Increase Volume (+5dB)** - Make audio louder
- **Decrease Volume (-5dB)** - Make audio quieter
- **Add Fade Effects (2s)** - Add fade in/out
- **Speed Up (1.5x)** - Increase playback speed
- **Apply Bass Boost** - Enhance low frequencies
- **Reverse Audio** - Play backwards

### Utility
- **Extract Audio from Video** - Get audio track from video files
- **Get Audio Info** - Display file information dialog

### Enabling Quick Actions

If Quick Actions don't appear:

1. Open **System Preferences**
2. Go to **Extensions** > **Finder**
3. Enable the **AG AudioFlow** services
4. They should now appear in the right-click menu

## Supported Audio Formats

- **Input**: MP3, WAV, AAC, M4A, FLAC, OGG, WMA, AIFF, and more
- **Output**: MP3, WAV, AAC, FLAC, OGG

## Command Shortcuts

Most commands have short aliases for convenience:

- `s2m` → `stereo-to-mono`
- `split` → `split-stereo`
- `cvt` → `convert`
- `norm` → `normalize`
- `vol` → `volume`
- `trim` → `trim-silence`
- `concat` → `merge`
- `extract` → `extract-audio`
- `sr` → `sample-rate`

## Examples

### Batch Processing Examples
```bash
# Built-in batch command (recommended)
agaudioflow batch normalize "*.wav" ./normalized
agaudioflow batch convert "*.mp3" ./flac_files flac
agaudioflow batch trim "podcast/*.mp3" ./trimmed -45

# Shell loop method
for file in *.wav; do
    agaudioflow normalize "$file"
done

# Process files with specific pattern
agaudioflow batch speed "audiobook*.mp3" ./fast 150
```

### Pipeline Processing
```bash
# Normalize then convert
agaudioflow normalize input.mp3 temp.mp3 && \
agaudioflow convert temp.mp3 wav final.wav

# Extract, normalize, and convert
agaudioflow extract video.mp4 mp3 audio.mp3 && \
agaudioflow normalize audio.mp3 normalized.mp3 && \
agaudioflow fade normalized.mp3 2 3 final.mp3
```

### Complex Workflows
```bash
# Prepare podcast episode
agaudioflow trim-silence raw_recording.wav trimmed.wav
agaudioflow normalize trimmed.wav normalized.wav -16
agaudioflow fade normalized.wav 1 2 faded.wav
agaudioflow eq faded.wav vocal final_podcast.mp3

# Create music compilation
agaudioflow normalize song1.mp3 norm1.mp3
agaudioflow normalize song2.mp3 norm2.mp3
agaudioflow normalize song3.mp3 norm3.mp3
agaudioflow merge norm1.mp3 norm2.mp3 norm3.mp3 album.mp3 --crossfade=3
```

## Requirements

- macOS 10.13 or later
- FFmpeg (installed automatically)
- Node.js 14+ (installed automatically)

## Troubleshooting

### FFmpeg not found
If you get an FFmpeg error, install it manually:
```bash
brew install ffmpeg
```

### Permission denied
Make sure the scripts are executable:
```bash
chmod +x install.sh
chmod +x setup-mac-services.sh
chmod +x agaudioflow-cli.js
```

### Quick Actions not appearing
1. Check System Preferences > Extensions > Finder
2. Look for AG AudioFlow services and enable them
3. Restart Finder: `killall Finder`

## Uninstallation

To remove AG AudioFlow:

```bash
# Uninstall CLI
npm uninstall -g agaudioflow

# Remove Quick Actions
rm -rf ~/Library/Services/AG\ AudioFlow*

# Remove the repository (optional)
rm -rf /path/to/AG_AudioFlow_OpenSource
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues on the [GitHub repository](https://github.com/adigold/AG_AudioFlow_OpenSource).

## License

MIT License - See LICENSE file for details

## Author

AG - [GitHub](https://github.com/adigold)

## Acknowledgments

- Built with [FFmpeg](https://ffmpeg.org/)
- Uses [fluent-ffmpeg](https://github.com/fluent-ffmpeg/node-fluent-ffmpeg) for Node.js integration
- Originally created as a Raycast extension