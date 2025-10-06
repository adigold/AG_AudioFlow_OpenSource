import { Detail, ActionPanel, Action } from "@raycast/api";

export default function About() {
  const markdown = `
# About AG AudioFlow

## 🎵 Your Complete Audio Processing Suite

AG AudioFlow brings professional-grade audio processing directly to your macOS desktop through Raycast. Transform, enhance, and manipulate audio files with **11 powerful commands** designed for musicians, podcasters, content creators, and audio professionals.

## ✨ Key Features

- **🔄 Convert Audio Format** - Transform between MP3, WAV, AAC, FLAC, OGG with quality control
- **✂️ Trim Silence** - Remove unwanted silence from beginnings and endings
- **🎛️ Add Fade Effects** - Professional fade-in/out with custom durations
- **📊 Normalize Audio** - EBU R128 standard normalization for consistent levels
- **🔊 Adjust Volume** - Precise dB control (-60dB to +60dB range)
- **🎚️ Stereo Processing** - Split stereo or convert to mono with channel options
- **⚡ Speed Control** - Variable speed (10%-1000%) with pitch preservation
- **📁 Batch Processing** - Apply operations to multiple files simultaneously
- **📋 Audio Analysis** - Detailed metadata and technical specifications
- **🔧 Smart Setup** - Automated FFmpeg detection and installation guidance

---

## 👨‍💻 Built with ❤️ by Adi Goldstein

### The Story Behind AG AudioFlow

As a passionate musician and audio enthusiast, I've always believed that the best tools are often the simplest ones. Throughout my journey in the audio world, I discovered that **small, focused utilities** can be incredibly powerful for daily musical tasks.

Whether you're:
- **Quickly converting a WAV file** for a client presentation
- **Normalizing podcast levels** before publishing  
- **Adding fade effects** to a demo track
- **Trimming silence** from voice recordings
- **Batch processing** an entire album

These seemingly simple tasks happen **every single day** in our creative workflows. Yet finding reliable, fast tools for these basic operations often meant juggling multiple applications, complex interfaces, or expensive software suites.

### The Vision

**AG AudioFlow** was born from this frustration. I wanted to create something that felt **natural** - where audio processing becomes as effortless as any other task on your Mac. 

By integrating with Raycast, these essential audio operations are now **just a keystroke away**. No more switching applications, navigating complex menus, or waiting for heavy software to load. Just press your Raycast hotkey, type what you need, and get back to creating.

### For Musicians, By Musicians

Every feature in AG AudioFlow comes from **real-world experience**:

- The **fade durations** are based on industry standards for radio and music production
- The **normalization levels** follow streaming platform requirements (Spotify, YouTube, broadcast)
- The **batch processing** handles the repetitive tasks we all face with album releases
- The **format conversion** supports the exact quality settings needed for different distribution channels

### The Philosophy

I believe that **great tools should be invisible** - they should enhance your creativity without getting in the way. AG AudioFlow embodies this philosophy by providing:

- **Instant access** through Raycast integration
- **Professional results** using industry-standard FFmpeg processing
- **Clear feedback** so you always know what's happening
- **Comprehensive documentation** because good tools should be approachable

---

## 🌟 Why These "Little" Tools Matter

In the professional audio world, we often focus on the big picture - the DAWs, the plugins, the expensive hardware. But it's the **small, daily tasks** that can make or break your workflow efficiency.

**AG AudioFlow** handles the tasks that happen between the creative moments:
- Converting files for collaboration
- Preparing assets for different platforms  
- Processing voice-overs for videos
- Organizing and optimizing audio libraries
- Quick fixes and adjustments

These **simple but essential operations** are now as easy as opening Raycast and typing a few characters.

---

## 🚀 Powered by Industry Standards

- **FFmpeg** - The world's leading multimedia framework, trusted by Netflix, YouTube, and major broadcasters
- **EBU R128** - Professional loudness standards used across the broadcasting industry
- **Raycast** - The productivity platform that's revolutionizing how we interact with our Macs

---

## 💫 Join the Community

AG AudioFlow is more than just a tool - it's part of a vision where **audio processing becomes effortless** for everyone, from bedroom producers to professional studios.

**Created with passion for the audio community** 🎶

*Thank you for using AG AudioFlow. May it serve your creative journey well.*

---

**AG AudioFlow v1.0** - Professional Audio Processing Suite  
© 2024 Adi Goldstein | Built with ❤️ for musicians everywhere
`;

  return (
    <Detail
      markdown={markdown}
      navigationTitle="About AG AudioFlow"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Version" text="1.0.0" />
          <Detail.Metadata.Label title="Author" text="Adi Goldstein" />
          <Detail.Metadata.Label title="Total Commands" text="11" />
          <Detail.Metadata.Label title="Built With" text="FFmpeg + Raycast" />
          <Detail.Metadata.Separator />
          <Detail.Metadata.Link
            title="GitHub Repository"
            target="https://github.com/adigold/AG-AudioFlow-Raycast"
            text="View Source Code"
          />
          <Detail.Metadata.Link
            title="Website"
            target="https://agsoundtrax.com"
            text="AGsoundtrax.com"
          />
        </Detail.Metadata>
      }
      actions={
        <ActionPanel>
          <Action.OpenInBrowser
            title="Visit GitHub Repository"
            url="https://github.com/adigold/AG-AudioFlow-Raycast"
          />
          <Action.OpenInBrowser
            title="Visit AGsoundtrax.com"
            url="https://agsoundtrax.com"
          />
          <Action.CopyToClipboard
            title="Copy Extension Info"
            content="AG AudioFlow v1.0 - Professional Audio Processing Suite by Adi Goldstein"
          />
        </ActionPanel>
      }
    />
  );
}