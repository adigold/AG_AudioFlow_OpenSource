# AG AudioFlow CLI - Professional Audio Processing Suite for macOS

<div align="center">

  **Professional audio editing and processing CLI with macOS Quick Actions integration**

  Transform, enhance, and manipulate audio files with professional-grade tools directly from your terminal or Finder right-click menu.

  [![Made with ❤️ by Adi Goldstein](https://img.shields.io/badge/Made%20with%20❤️%20by-Adi%20Goldstein-blue)](https://agsoundtrax.com)
  [![Powered by AGsoundtrax.com](https://img.shields.io/badge/Powered%20by-AGsoundtrax.com-green)](https://agsoundtrax.com)
  [![FFmpeg](https://img.shields.io/badge/Powered%20by-FFmpeg-orange)](https://ffmpeg.org)

</div>

---

## 🎯 About

AG AudioFlow CLI is a comprehensive audio processing suite designed for professionals, content creators, podcasters, musicians, and anyone who works with audio files. Built by **Adi Goldstein** and powered by **[AGsoundtrax.com](https://agsoundtrax.com)**, this tool brings professional-grade audio processing capabilities directly to your macOS terminal and Finder context menu.

Whether you're preparing podcast episodes, mastering music tracks, converting audio formats, or processing large batches of audio files, AG AudioFlow CLI provides the tools you need with powerful command-line interface and seamless macOS integration.

## Features

### 🎵 Audio Format Conversion
- Convert between WAV, MP3, AAC, FLAC, OGG, and other formats
- Customizable bitrates (64k to 320k)
- Sample rate conversion (8kHz to 192kHz)
- Mono/Stereo channel conversion

### ✂️ Silence Trimming
- Automatically remove silence from the beginning and end of audio files
- Configurable silence detection thresholds
- Preserves audio quality while reducing file size

### 🎛️ Fade Effects
- Add professional fade-in effects at the beginning
- Add smooth fade-out effects at the end
- Customizable fade durations

### 📊 Audio Normalization
- Normalize audio levels using EBU R128 standard
- Multiple target loudness presets:
  - -16 LUFS (Streaming/Radio)
  - -18 LUFS (YouTube)
  - -23 LUFS (Broadcast Standard)
  - -14 LUFS (Spotify)
  - -11 LUFS (CD Master)

### 🔊 Volume/Gain Adjustment
- Precise volume control in decibels (-60dB to +60dB)
- Common presets for quick adjustments
- High-precision gain mode for subtle changes

### 🎚️ Stereo Processing
- **Split Stereo to Mono**: Extract separate left and right channel files
- **Stereo to Mono Conversion**: Mix stereo to mono with channel selection options
- Support for different mixing methods (mix both, left only, right only)

### ⚡ Speed Adjustment
- Variable speed control with percentage precision (10% - 1000%)
- Pitch preservation option to maintain original tone
- Perfect for lectures, music practice, or creative effects

### 📁 Batch Processing
- Process multiple audio files simultaneously
- Pattern matching for file selection
- Progress tracking for large batches
- Detailed success/failure reporting

### 🎬 Advanced Features
- **Merge Audio**: Combine multiple audio files with optional crossfade
- **Extract Audio from Video**: Extract audio tracks from video files
- **EQ Presets**: Apply bass boost, treble, vocal enhancement
- **Audio Reversal**: Create reverse playback effects
- **Channel Manipulation**: Change number of audio channels (1-8)
- **Sample Rate Conversion**: Professional resampling

### 🖱️ macOS Quick Actions
- Right-click audio processing in Finder
- 30 Quick Actions for comprehensive audio processing
- Process multiple files at once
- System notifications for completion
- Support for both audio and video files

### 📋 Audio File Information
- View detailed metadata for audio files
- Duration, bitrate, sample rate, channels
- File size and format information

## 🚀 Quick Start

### One-Click Installation

```bash
# Clone the repository
git clone https://github.com/adigold/AG_AudioFlow_OpenSource.git
cd AG_AudioFlow_OpenSource

# Run the installer
chmod +x install.sh
./install.sh
```

The installer will:
1. Install Homebrew (if needed)
2. Install FFmpeg via Homebrew
3. Install Node.js (if needed)
4. Install AG AudioFlow CLI globally
5. Set up macOS Quick Actions for right-click functionality

### Manual Installation

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

---

## 🔧 FFmpeg Installation Guide

### Why FFmpeg is Required

**FFmpeg** is the industry-standard multimedia framework that powers AG AudioFlow's audio processing capabilities.

#### 🎯 **What is FFmpeg?**
- **Industry Standard**: Used by Netflix, YouTube, VLC, and major media companies worldwide
- **Comprehensive**: Supports virtually every audio and video format ever created
- **High Quality**: Professional-grade encoding and decoding algorithms
- **Open Source**: Free, secure, and continuously updated by a global community
- **Cross-Platform**: Works on macOS, Windows, and Linux

#### 🛠️ **What FFmpeg Enables in AG AudioFlow:**
- **Format Conversion**: Convert between MP3, WAV, AAC, FLAC, OGG and more
- **Audio Processing**: Volume adjustment, normalization, fade effects
- **Advanced Filters**: Silence removal, speed adjustment, stereo processing
- **Metadata Handling**: Read and write audio file information
- **Batch Processing**: Efficiently process multiple files simultaneously

### Installation Methods

#### 🍺 **Method 1: Homebrew (Recommended)**

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install FFmpeg
brew install ffmpeg

# Verify installation
ffmpeg -version
```

#### 📦 **Method 2: Manual Installation**

1. Download FFmpeg from [ffmpeg.org](https://ffmpeg.org/download.html)
2. Extract and move to `/usr/local/bin/`
3. Add to PATH if needed

---

## 🎬 Use Cases & Workflows

### 🎙️ **Podcast Production Workflow**
```bash
# Complete podcast processing pipeline
agaudioflow trim-silence raw_recording.wav trimmed.wav
agaudioflow normalize trimmed.wav normalized.wav -16
agaudioflow fade normalized.wav 2 3 faded.wav
agaudioflow eq faded.wav vocal final_podcast.mp3
```

### 🎵 **Music Production Workflow**
```bash
# Master for streaming platforms
agaudioflow normalize track.wav mastered.wav -14
agaudioflow convert mastered.wav mp3 track_320k.mp3
agaudioflow convert mastered.wav flac track_lossless.flac
```

### 📚 **Audiobook/Educational Content**
```bash
# Create speed variations
agaudioflow speed audiobook.mp3 125 audiobook_1.25x.mp3
agaudioflow speed audiobook.mp3 150 audiobook_1.5x.mp3

# Batch process all chapters
agaudioflow batch normalize "chapter*.mp3" ./normalized -16
```

### 🎬 **Video Production Audio**
```bash
# Extract and process audio from video
agaudioflow extract-audio video.mp4 mp3 soundtrack.mp3
agaudioflow normalize soundtrack.mp3 normalized.mp3
agaudioflow fade normalized.mp3 1 2 final_audio.mp3
```

---

## 📚 Command Reference

### Core Commands

#### 🎵 **Convert Audio Format**
```bash
agaudioflow convert <input> <format> [output]
agaudioflow cvt audio.wav mp3 output.mp3

# Supported formats: mp3, wav, aac, flac, ogg
```

#### ✂️ **Trim Silence**
```bash
agaudioflow trim-silence <input> [threshold] [output]
agaudioflow trim podcast.mp3 -45 trimmed.mp3

# Default threshold: -50dB
```

#### 🎛️ **Add Fade Effects**
```bash
agaudioflow fade <input> <fade-in> <fade-out> [output]
agaudioflow fade music.mp3 2 3 faded.mp3

# Times in seconds
```

#### 📊 **Normalize Audio**
```bash
agaudioflow normalize <input> [target-level] [output]
agaudioflow norm podcast.mp3 -16 normalized.mp3

# Target levels: -23 (broadcast), -16 (streaming), -14 (Spotify)
```

#### 🔊 **Adjust Volume**
```bash
agaudioflow volume <input> <dB-change> [output]
agaudioflow vol song.mp3 -5 quieter.mp3

# Range: -60dB to +60dB
```

#### 🎚️ **Stereo to Mono**
```bash
agaudioflow stereo-to-mono <input> [method] [output]
agaudioflow s2m stereo.mp3 mix mono.mp3

# Methods: mix (default), left, right
```

#### 🔄 **Split Stereo**
```bash
agaudioflow split-stereo <input> [output-dir]
agaudioflow split recording.wav ./output

# Creates: recording_left.wav, recording_right.wav
```

#### ⚡ **Adjust Speed**
```bash
agaudioflow speed <input> <percentage> [preserve-pitch] [output]
agaudioflow speed audiobook.mp3 150 true fast.mp3

# Range: 10% to 1000%, preserve-pitch: true/false
```

### Advanced Commands

#### 📁 **Batch Processing**
```bash
agaudioflow batch <operation> <pattern> [output-dir] [options]
agaudioflow batch normalize "*.mp3" ./normalized -16
agaudioflow batch convert "*.wav" ./mp3_files mp3
agaudioflow batch trim "audio/*.mp3" ./trimmed -40
```

#### 🔗 **Merge Audio**
```bash
agaudioflow merge <file1> <file2> [...] <output> [--crossfade=seconds]
agaudioflow merge track1.mp3 track2.mp3 track3.mp3 album.mp3 --crossfade=2
```

#### 🎬 **Extract Audio from Video**
```bash
agaudioflow extract-audio <video> [format] [output]
agaudioflow extract video.mp4 mp3 audio.mp3
```

#### 🔧 **Change Channels**
```bash
agaudioflow channels <input> <num-channels> [output]
agaudioflow channels stereo.mp3 1 mono.mp3
```

#### 🎚️ **Change Sample Rate**
```bash
agaudioflow sample-rate <input> <rate> [output]
agaudioflow sr audio.mp3 48000 resampled.mp3

# Valid rates: 8000, 11025, 22050, 44100, 48000, 88200, 96000, 192000
```

#### 🎛️ **Apply EQ Preset**
```bash
agaudioflow eq <input> <preset> [output]
agaudioflow eq music.mp3 bass boosted.mp3

# Presets: bass, treble, vocal, flat, loudness
```

#### 🔄 **Reverse Audio**
```bash
agaudioflow reverse <input> [output]
agaudioflow reverse song.mp3 reversed.mp3
```

#### 📋 **Get Audio Info**
```bash
agaudioflow info <input>
agaudioflow info track.mp3
```

---

## 🖱️ macOS Quick Actions

After installation, right-click any audio or video file in Finder to access **30 comprehensive Quick Actions**:

### Basic Audio Processing
- **Stereo to Mono** - Convert stereo files to mono
- **Split Stereo** - Split into left and right channels
- **Normalize Audio** - Standardize volume levels
- **Trim Silence** - Remove quiet sections

### Format Conversion (5 formats)
- **Convert to MP3** - Compress for smaller file size
- **Convert to WAV** - Uncompressed high quality
- **Convert to FLAC** - Lossless compression
- **Convert to AAC** - Apple-optimized format
- **Convert to OGG** - Open-source format

### Volume Control (4 levels)
- **Increase Volume (+5dB)** - Make audio louder
- **Decrease Volume (-5dB)** - Make audio quieter
- **High Volume Boost (+10dB)** - Significant increase
- **Volume Reduction (-10dB)** - Significant decrease

### Professional Normalization
- **Normalize Audio** - General purpose normalization
- **Normalize for Spotify** - Optimize for Spotify (-14 LUFS)
- **Normalize for Broadcast** - TV/Radio standard (-23 LUFS)

### Speed Control (4 speeds)
- **Slow Down (50%)** - Half speed for transcription
- **Speed Up (1.5x)** - Comfortable increase
- **Double Speed (200%)** - Fast review
- **Add Fade Effects (2s)** - Professional transitions

### EQ and Enhancement (4 presets)
- **Apply Bass Boost** - Enhance low frequencies
- **Apply Treble Boost** - Enhance high frequencies
- **Vocal Enhancement** - Optimize for speech
- **Loudness Enhancement** - Professional loudness

### Technical Processing
- **Force Mono (1 Channel)** - Convert any audio to mono
- **Force Stereo (2 Channels)** - Convert to stereo
- **CD Quality (44.1kHz)** - Standard CD sample rate
- **Upsample to 48kHz** - Professional sample rate

### Special Effects
- **Reverse Audio** - Play backwards
- **Extract Audio from Video** - Get audio from video files

### Utility
- **Get Audio Info** - Display detailed file information

### Enabling Quick Actions

If Quick Actions don't appear:
1. Open **System Preferences**
2. Go to **Extensions** > **Finder**
3. Enable the **AG AudioFlow** services

---

## 💡 Tips & Best Practices

### Quality Guidelines
- **MP3**: Use 320kbps for archival, 192kbps for streaming
- **FLAC**: Best for lossless archival and professional work
- **AAC**: Optimal for Apple ecosystem compatibility
- **WAV**: Use for professional editing and mastering

### Loudness Standards
- **-23 LUFS**: Broadcast television standard
- **-16 LUFS**: Streaming platforms (Apple Music, general)
- **-14 LUFS**: Spotify target loudness
- **-11 LUFS**: CD mastering reference

### Volume Adjustments
- **+6dB**: Doubles perceived loudness
- **-6dB**: Halves perceived loudness
- **±3dB**: Noticeable but subtle change

### Speed Settings
- **50%**: Half speed for detailed transcription
- **125%**: Comfortable speed increase for podcasts
- **150%**: Fast learning/review speed
- **200%**: Double speed for quick preview

### Batch Processing
```bash
# Use quotes for patterns with wildcards
agaudioflow batch normalize "*.mp3" ./output

# Process subdirectories
agaudioflow batch convert "audio/*.wav" ./converted flac

# Chain operations
for file in *.mp3; do
  agaudioflow normalize "$file" temp.mp3
  agaudioflow fade temp.mp3 1 2 "processed_$file"
done
```

---

## 🛠️ Advanced Examples

### Complex Workflows

#### Professional Podcast Production
```bash
#!/bin/bash
# Complete podcast processing script

INPUT="raw_podcast.wav"
TRIMMED="step1_trimmed.wav"
NORMALIZED="step2_normalized.wav"
FADED="step3_faded.wav"
FINAL="final_podcast.mp3"

# Step 1: Remove silence
agaudioflow trim-silence "$INPUT" -45 "$TRIMMED"

# Step 2: Normalize to streaming standard
agaudioflow normalize "$TRIMMED" -16 "$NORMALIZED"

# Step 3: Add professional fades
agaudioflow fade "$NORMALIZED" 2 3 "$FADED"

# Step 4: Apply vocal enhancement and export
agaudioflow eq "$FADED" vocal "$FINAL"

# Cleanup temporary files
rm "$TRIMMED" "$NORMALIZED" "$FADED"

echo "Podcast processing complete: $FINAL"
```

#### Music Album Compilation
```bash
#!/bin/bash
# Create album with crossfades

# Normalize all tracks first
agaudioflow batch normalize "tracks/*.mp3" ./normalized

# Merge with crossfade
agaudioflow merge normalized/*.mp3 album.mp3 --crossfade=3

# Master the final album
agaudioflow normalize album.mp3 -14 album_mastered.mp3
```

#### Multi-Format Export
```bash
#!/bin/bash
# Export audio in multiple formats and qualities

INPUT="master.wav"
BASENAME="${INPUT%.*}"

# High quality formats
agaudioflow convert "$INPUT" flac "${BASENAME}_lossless.flac"
agaudioflow convert "$INPUT" wav "${BASENAME}_uncompressed.wav"

# Streaming formats
agaudioflow convert "$INPUT" mp3 "${BASENAME}_320k.mp3"
agaudioflow normalize "${BASENAME}_320k.mp3" -14 "${BASENAME}_spotify.mp3"

# Web/mobile formats
agaudioflow convert "$INPUT" aac "${BASENAME}_mobile.aac"
agaudioflow volume "$INPUT" -6 "${BASENAME}_reduced.mp3"
```

---

## 🔍 Command Shortcuts

All commands have short aliases for faster typing:

| Short | Full Command |
|-------|-------------|
| `s2m` | `stereo-to-mono` |
| `split` | `split-stereo` |
| `cvt` | `convert` |
| `norm` | `normalize` |
| `vol` | `volume` |
| `trim` | `trim-silence` |
| `concat` | `merge` |
| `extract` | `extract-audio` |
| `sr` | `sample-rate` |

---

## 🐛 Troubleshooting

### Common Issues

#### "FFmpeg not found"
```bash
# Reinstall FFmpeg
brew uninstall ffmpeg
brew install ffmpeg

# Verify installation
ffmpeg -version
```

#### "Command not found: agaudioflow"
```bash
# Reinstall the CLI globally
npm install -g .

# Check installation
which agaudioflow
```

#### Quick Actions not appearing
1. Run `./setup-mac-services.sh` again
2. Go to System Preferences > Extensions > Finder
3. Enable AG AudioFlow services
4. Restart Finder: `killall Finder`

#### Permission denied errors
```bash
# Make scripts executable
chmod +x install.sh
chmod +x setup-mac-services.sh
chmod +x agaudioflow-cli.js
```

---

## 📄 Requirements

- **macOS**: 10.13 or later
- **FFmpeg**: Installed via Homebrew or manually
- **Node.js**: Version 14 or higher
- **Storage**: Sufficient space for audio processing

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Feature Requests
- Open an issue with your feature request
- Describe your use case and expected behavior
- We prioritize features that benefit the audio community

---

## 📈 Changelog

### v1.0.0 - Initial Release
- ✅ **15+ Audio Processing Commands** - Complete audio processing suite
- 🎵 **Format Conversion** - Support for MP3, WAV, AAC, FLAC, OGG with quality control
- ✂️ **Audio Enhancement** - Silence trimming, fade effects, volume adjustment
- 📊 **Professional Tools** - Audio normalization using EBU R128 standards
- 🎚️ **Stereo Processing** - Split stereo to mono, stereo-to-mono conversion
- ⚡ **Speed Control** - Variable speed with pitch preservation (10%-1000%)
- 📁 **Batch Processing** - Process multiple files with pattern matching
- 🔗 **Audio Merging** - Combine files with optional crossfade
- 🎬 **Video Support** - Extract audio from video files
- 🖱️ **macOS Integration** - 30 Quick Actions for right-click processing
- 🎛️ **Advanced Effects** - EQ presets, audio reversal, channel manipulation

---

## 👨‍💻 Creator & Support

**AG AudioFlow CLI** is created with ❤️ by **Adi Goldstein**

### 🌐 **Connect & Learn More:**
- **Website**: [AGsoundtrax.com](https://agsoundtrax.com) - Professional audio services and tools
- **GitHub**: [AG AudioFlow OpenSource](https://github.com/adigold/AG_AudioFlow_OpenSource)
- **Support**: Technical support and feature requests via GitHub Issues

### 🎵 **About AGsoundtrax.com:**
AGsoundtrax.com is a professional audio services platform specializing in:
- Audio post-production and mastering
- Custom audio tool development
- Sound design and music production
- Audio technology consulting

AG AudioFlow CLI represents our commitment to bringing professional audio tools to everyday users, making advanced audio processing accessible through powerful command-line interfaces and seamless OS integration.

---

## 📜 License

MIT License - Free to use, modify, and distribute.

```
Copyright (c) 2024 Adi Goldstein / AGsoundtrax.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **FFmpeg Team** - For creating the world's best multimedia framework
- **Open Source Community** - For the tools and libraries that make this possible
- **Audio Professionals** - For feedback and feature suggestions that shaped this tool
- **Users** - For choosing AG AudioFlow for your audio processing needs

---

**AG AudioFlow CLI** - Where professional audio processing meets command-line efficiency.

*Made with ❤️ by [Adi Goldstein](https://agsoundtrax.com) | Powered by [AGsoundtrax.com](https://agsoundtrax.com)*