# Audio Processing Engine Options for AG AudioFlow

## Current: FFmpeg
- ✅ Full command line support
- ✅ Cross-platform (macOS, Windows, Linux)
- ✅ Supports all audio formats
- ✅ Professional-grade processing

## SoundForge Options

### 1. SoundForge Pro (Windows Only)
- ⚠️ Limited CLI support
- ⚠️ Windows only (no macOS version)
- ⚠️ Requires expensive license
- ❌ Not suitable for our macOS CLI tool

### 2. SoundForge Audio Studio
- ❌ No command line interface
- ❌ GUI only
- ❌ Not suitable for automation

## Better Professional Alternatives

### 1. SoX (Sound eXchange)
- ✅ Excellent command line interface
- ✅ Professional audio processing
- ✅ Cross-platform
- ✅ Free and open source
- ✅ Often called "Swiss Army knife of audio"

### 2. Hybrid Approach
- ✅ Keep FFmpeg for format conversion
- ✅ Add SoX for advanced audio processing
- ✅ Add other specialized tools as needed

## Recommendation

Since SoundForge doesn't have proper CLI support on macOS, I recommend:

1. **Primary**: Keep FFmpeg (best overall CLI tool)
2. **Secondary**: Add SoX for advanced audio processing
3. **Tertiary**: Add other specialized tools (aubio, librosa, etc.)

This gives users the best of all worlds with professional-grade processing.