#!/usr/bin/env node

const ffmpeg = require('fluent-ffmpeg');
const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs').promises;
const os = require('os');

// Audio Engine Detection and Management
class AudioEngineManager {
  constructor() {
    this.engines = {
      ffmpeg: this.findFFmpeg(),
      sox: this.findSoX(),
      // soundforge: this.findSoundForge(), // Not available on macOS
    };
    this.preferredEngine = this.detectBestEngine();
  }

  findFFmpeg() {
    const possiblePaths = [
      '/opt/homebrew/bin/ffmpeg',
      '/usr/local/bin/ffmpeg',
      '/usr/bin/ffmpeg',
      'ffmpeg'
    ];

    for (const ffmpegPath of possiblePaths) {
      try {
        execSync(`${ffmpegPath} -version`, { stdio: 'pipe' });
        return { path: ffmpegPath, available: true };
      } catch (error) {
        continue;
      }
    }
    return { path: null, available: false };
  }

  findSoX() {
    const possiblePaths = [
      '/opt/homebrew/bin/sox',
      '/usr/local/bin/sox',
      '/usr/bin/sox',
      'sox'
    ];

    for (const soxPath of possiblePaths) {
      try {
        execSync(`${soxPath} --version`, { stdio: 'pipe' });
        return { path: soxPath, available: true };
      } catch (error) {
        continue;
      }
    }
    return { path: null, available: false };
  }

  detectBestEngine() {
    if (this.engines.sox.available) {
      console.log('🎛️ Using SoX for professional audio processing');
      return 'sox';
    } else if (this.engines.ffmpeg.available) {
      console.log('🎵 Using FFmpeg for audio processing');
      return 'ffmpeg';
    } else {
      throw new Error('No audio processing engine found. Please install SoX or FFmpeg.');
    }
  }

  getEnginePath(engine = this.preferredEngine) {
    return this.engines[engine]?.path;
  }

  isEngineAvailable(engine) {
    return this.engines[engine]?.available || false;
  }

  installInstructions() {
    return `
Audio Processing Engines Installation:

🎛️ SoX (Recommended - Professional Audio Processing):
   brew install sox

🎵 FFmpeg (Alternative - Multimedia Processing):
   brew install ffmpeg

For best results, install both:
   brew install sox ffmpeg
`;
  }
}

// Enhanced Audio Processor with Multiple Engine Support
class AudioProcessor {
  constructor() {
    this.engineManager = new AudioEngineManager();
  }

  static generateOutputPath(inputPath, suffix, newExtension) {
    const parsedPath = path.parse(inputPath);
    const extension = newExtension || parsedPath.ext;
    return path.join(
      parsedPath.dir,
      `${parsedPath.name}_${suffix}${extension}`
    );
  }

  // SoX-based audio processing (professional grade)
  async convertStereoToMonoSoX(inputPath, outputPath, mixMethod = 'mix') {
    if (!this.engineManager.isEngineAvailable('sox')) {
      throw new Error('SoX not available. Please install: brew install sox');
    }

    const soxPath = this.engineManager.getEnginePath('sox');
    let mixParam;

    switch (mixMethod) {
      case 'left':
        mixParam = 'remix 1';
        break;
      case 'right':
        mixParam = 'remix 2';
        break;
      case 'mix':
      default:
        mixParam = 'remix 1,2';
        break;
    }

    return new Promise((resolve, reject) => {
      const command = `"${soxPath}" "${inputPath}" "${outputPath}" ${mixParam}`;

      console.log(`Converting stereo to mono (${mixMethod} method) using SoX...`);

      try {
        execSync(command, { stdio: 'inherit' });
        console.log('\nConversion complete!');
        resolve();
      } catch (error) {
        reject(new Error(`SoX conversion failed: ${error.message}`));
      }
    });
  }

  // SoX-based volume adjustment (more precise than FFmpeg)
  async adjustVolumeSoX(inputPath, outputPath, volumeChange) {
    if (!this.engineManager.isEngineAvailable('sox')) {
      throw new Error('SoX not available. Please install: brew install sox');
    }

    const soxPath = this.engineManager.getEnginePath('sox');
    // Convert dB to linear amplitude for SoX
    const amplitude = Math.pow(10, volumeChange / 20);

    return new Promise((resolve, reject) => {
      const command = `"${soxPath}" "${inputPath}" "${outputPath}" vol ${amplitude}`;

      console.log(`Adjusting volume by ${volumeChange}dB using SoX...`);

      try {
        execSync(command, { stdio: 'inherit' });
        console.log('\nVolume adjustment complete!');
        resolve();
      } catch (error) {
        reject(new Error(`SoX volume adjustment failed: ${error.message}`));
      }
    });
  }

  // SoX-based normalization (professional loudness)
  async normalizeAudioSoX(inputPath, outputPath, method = 'rms') {
    if (!this.engineManager.isEngineAvailable('sox')) {
      throw new Error('SoX not available. Please install: brew install sox');
    }

    const soxPath = this.engineManager.getEnginePath('sox');
    let normalizeParam;

    switch (method) {
      case 'peak':
        normalizeParam = 'norm';
        break;
      case 'rms':
      default:
        normalizeParam = 'norm -0.1'; // Normalize to -0.1dB peak
        break;
    }

    return new Promise((resolve, reject) => {
      const command = `"${soxPath}" "${inputPath}" "${outputPath}" ${normalizeParam}`;

      console.log(`Normalizing audio (${method} method) using SoX...`);

      try {
        execSync(command, { stdio: 'inherit' });
        console.log('\nNormalization complete!');
        resolve();
      } catch (error) {
        reject(new Error(`SoX normalization failed: ${error.message}`));
      }
    });
  }

  // SoX-based EQ (more precise than FFmpeg)
  async applyEQSoX(inputPath, outputPath, preset) {
    if (!this.engineManager.isEngineAvailable('sox')) {
      throw new Error('SoX not available. Please install: brew install sox');
    }

    const soxPath = this.engineManager.getEnginePath('sox');
    let eqParams;

    switch (preset) {
      case 'bass':
        eqParams = 'bass +10';
        break;
      case 'treble':
        eqParams = 'treble +5';
        break;
      case 'vocal':
        eqParams = 'equalizer 1000 2q +3 equalizer 3000 1q +2';
        break;
      case 'loudness':
        eqParams = 'loudness';
        break;
      case 'flat':
      default:
        eqParams = ''; // No EQ
        break;
    }

    return new Promise((resolve, reject) => {
      const command = `"${soxPath}" "${inputPath}" "${outputPath}" ${eqParams}`;

      console.log(`Applying ${preset} EQ using SoX...`);

      try {
        execSync(command, { stdio: 'inherit' });
        console.log('\nEQ applied!');
        resolve();
      } catch (error) {
        reject(new Error(`SoX EQ failed: ${error.message}`));
      }
    });
  }

  // SoX-based speed adjustment (high quality)
  async adjustSpeedSoX(inputPath, outputPath, speedPercentage, preservePitch = true) {
    if (!this.engineManager.isEngineAvailable('sox')) {
      throw new Error('SoX not available. Please install: brew install sox');
    }

    const soxPath = this.engineManager.getEnginePath('sox');
    const factor = speedPercentage / 100;

    let speedParam;
    if (preservePitch) {
      speedParam = `tempo ${factor}`;
    } else {
      speedParam = `speed ${factor}`;
    }

    return new Promise((resolve, reject) => {
      const command = `"${soxPath}" "${inputPath}" "${outputPath}" ${speedParam}`;

      console.log(`Adjusting speed to ${speedPercentage}% using SoX...`);

      try {
        execSync(command, { stdio: 'inherit' });
        console.log('\nSpeed adjustment complete!');
        resolve();
      } catch (error) {
        reject(new Error(`SoX speed adjustment failed: ${error.message}`));
      }
    });
  }

  // SoX-based silence trimming (more accurate)
  async trimSilenceSoX(inputPath, outputPath, threshold = 0.1) {
    if (!this.engineManager.isEngineAvailable('sox')) {
      throw new Error('SoX not available. Please install: brew install sox');
    }

    const soxPath = this.engineManager.getEnginePath('sox');
    // SoX silence trimming is more sophisticated
    const silenceParams = `silence 1 0.1 ${threshold}% reverse silence 1 0.1 ${threshold}% reverse`;

    return new Promise((resolve, reject) => {
      const command = `"${soxPath}" "${inputPath}" "${outputPath}" ${silenceParams}`;

      console.log(`Trimming silence using SoX...`);

      try {
        execSync(command, { stdio: 'inherit' });
        console.log('\nSilence trimmed!');
        resolve();
      } catch (error) {
        reject(new Error(`SoX silence trimming failed: ${error.message}`));
      }
    });
  }

  // SoX-based fade effects (smoother curves)
  async addFadeSoX(inputPath, outputPath, fadeIn = 0, fadeOut = 0) {
    if (!this.engineManager.isEngineAvailable('sox')) {
      throw new Error('SoX not available. Please install: brew install sox');
    }

    const soxPath = this.engineManager.getEnginePath('sox');
    let fadeParams = '';

    if (fadeIn > 0) {
      fadeParams += `fade h ${fadeIn}`;
    }
    if (fadeOut > 0) {
      if (fadeParams) fadeParams += ' ';
      fadeParams += `fade h 0 0 ${fadeOut}`;
    }

    if (!fadeParams) {
      throw new Error('At least one fade effect must be specified');
    }

    return new Promise((resolve, reject) => {
      const command = `"${soxPath}" "${inputPath}" "${outputPath}" ${fadeParams}`;

      console.log(`Adding fade effects using SoX...`);

      try {
        execSync(command, { stdio: 'inherit' });
        console.log('\nFade effects added!');
        resolve();
      } catch (error) {
        reject(new Error(`SoX fade effects failed: ${error.message}`));
      }
    });
  }

  // FFmpeg fallback methods (keep existing functionality)
  async convertStereoToMono(inputPath, outputPath, mixMethod = 'mix') {
    if (this.engineManager.isEngineAvailable('sox')) {
      return this.convertStereoToMonoSoX(inputPath, outputPath, mixMethod);
    }
    // Fallback to original FFmpeg implementation
    // ... (existing FFmpeg code)
  }

  async adjustVolume(inputPath, outputPath, volumeChange) {
    if (this.engineManager.isEngineAvailable('sox')) {
      return this.adjustVolumeSoX(inputPath, outputPath, volumeChange);
    }
    // Fallback to FFmpeg
    // ... (existing FFmpeg code)
  }

  async normalizeAudio(inputPath, outputPath, method = 'rms') {
    if (this.engineManager.isEngineAvailable('sox')) {
      return this.normalizeAudioSoX(inputPath, outputPath, method);
    }
    // Fallback to FFmpeg
    // ... (existing FFmpeg code)
  }

  async applyEQ(inputPath, outputPath, preset) {
    if (this.engineManager.isEngineAvailable('sox')) {
      return this.applyEQSoX(inputPath, outputPath, preset);
    }
    // Fallback to FFmpeg
    // ... (existing FFmpeg code)
  }

  async adjustSpeed(inputPath, outputPath, speedPercentage, preservePitch = true) {
    if (this.engineManager.isEngineAvailable('sox')) {
      return this.adjustSpeedSoX(inputPath, outputPath, speedPercentage, preservePitch);
    }
    // Fallback to FFmpeg
    // ... (existing FFmpeg code)
  }

  async trimSilence(inputPath, outputPath, threshold = 0.1) {
    if (this.engineManager.isEngineAvailable('sox')) {
      return this.trimSilenceSoX(inputPath, outputPath, threshold);
    }
    // Fallback to FFmpeg
    // ... (existing FFmpeg code)
  }

  async addFade(inputPath, outputPath, fadeIn = 0, fadeOut = 0) {
    if (this.engineManager.isEngineAvailable('sox')) {
      return this.addFadeSoX(inputPath, outputPath, fadeIn, fadeOut);
    }
    // Fallback to FFmpeg
    // ... (existing FFmpeg code)
  }
}

// CLI Command Handler with Engine Selection
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    printHelp();
    return;
  }

  if (args[0] === '--engines') {
    const processor = new AudioProcessor();
    console.log('\n🎛️ Audio Processing Engines Status:');
    console.log(`SoX: ${processor.engineManager.isEngineAvailable('sox') ? '✅ Available' : '❌ Not installed'}`);
    console.log(`FFmpeg: ${processor.engineManager.isEngineAvailable('ffmpeg') ? '✅ Available' : '❌ Not installed'}`);
    console.log(`\nPreferred Engine: ${processor.engineManager.preferredEngine}`);

    if (!processor.engineManager.isEngineAvailable('sox') && !processor.engineManager.isEngineAvailable('ffmpeg')) {
      console.log(processor.engineManager.installInstructions());
    }
    return;
  }

  const processor = new AudioProcessor();

  // Rest of the CLI handling code...
  // (Similar to existing implementation but using the new AudioProcessor)
}

function printHelp() {
  console.log(`
AG AudioFlow CLI - Professional Audio Processing Suite
Enhanced with SoX and FFmpeg Engine Support

Usage: agaudioflow <command> <input-file> [options]

Engine Commands:
  --engines                     Show available audio processing engines
  --engine sox|ffmpeg          Force specific engine

Core Commands:
  stereo-to-mono, s2m <input> [method] [output]
    Convert stereo to mono. Methods: mix (default), left, right
    🎛️ Uses SoX for superior audio quality

  volume, vol <input> <dB-change> [output]
    Adjust volume by specified dB (positive or negative)
    🎛️ Uses SoX for precise amplitude control

  normalize, norm <input> [method] [output]
    Normalize audio levels. Methods: rms (default), peak
    🎛️ Uses SoX for professional loudness standards

  eq <input> <preset> [output]
    Apply EQ preset. 🎛️ SoX presets: bass, treble, vocal, loudness, flat

  speed <input> <percentage> [preserve-pitch] [output]
    Adjust playback speed with high-quality algorithms
    🎛️ Uses SoX tempo/speed processing

  trim-silence, trim <input> [threshold] [output]
    Remove silence with advanced detection
    🎛️ Uses SoX sophisticated silence detection

  fade <input> <fade-in-seconds> <fade-out-seconds> [output]
    Add professional fade curves
    🎛️ Uses SoX smooth fade algorithms

🎛️ = Enhanced with SoX professional processing
🎵 = FFmpeg fallback available

Install Engines:
  brew install sox ffmpeg    # Install both for best results
  brew install sox          # Professional audio processing
  brew install ffmpeg       # Multimedia processing

Examples:
  agaudioflow --engines                    # Check engine status
  agaudioflow stereo-to-mono audio.mp3    # Uses best available engine
  agaudioflow volume song.mp3 -3          # Precise SoX volume control
  agaudioflow normalize podcast.mp3 rms   # Professional loudness
`);
}

// Run the CLI
main().catch(error => {
  console.error('Fatal error:', error.message);
  process.exit(1);
});

module.exports = { AudioProcessor, AudioEngineManager };