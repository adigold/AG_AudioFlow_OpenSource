#!/usr/bin/env node

const ffmpeg = require('fluent-ffmpeg');
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs').promises;
const os = require('os');

// Find FFmpeg installation
function findFFmpegPath() {
  const possiblePaths = [
    '/opt/homebrew/bin/ffmpeg',  // Apple Silicon Homebrew
    '/usr/local/bin/ffmpeg',      // Intel Homebrew
    '/usr/bin/ffmpeg',             // System installation
    'ffmpeg',                      // PATH
  ];

  for (const ffmpegPath of possiblePaths) {
    try {
      execSync(`${ffmpegPath} -version`, { stdio: 'pipe' });
      return ffmpegPath;
    } catch (error) {
      continue;
    }
  }
  return '';
}

// Initialize FFmpeg
function initializeFFmpeg() {
  const ffmpegPath = findFFmpegPath();
  if (ffmpegPath) {
    ffmpeg.setFfmpegPath(ffmpegPath);
    return true;
  }
  console.error('Error: FFmpeg not found. Please install FFmpeg first.');
  console.error('Install with: brew install ffmpeg');
  process.exit(1);
}

// Audio processing functions
class AudioProcessor {
  static generateOutputPath(inputPath, suffix, newExtension) {
    const parsedPath = path.parse(inputPath);
    const extension = newExtension || parsedPath.ext;
    return path.join(
      parsedPath.dir,
      `${parsedPath.name}_${suffix}${extension}`
    );
  }

  static async getAudioInfo(filePath) {
    return new Promise((resolve, reject) => {
      ffmpeg.ffprobe(filePath, (err, metadata) => {
        if (err) {
          reject(err);
          return;
        }

        const audioStream = metadata.streams.find(
          stream => stream.codec_type === 'audio'
        );
        if (!audioStream) {
          reject(new Error('No audio stream found'));
          return;
        }

        resolve({
          duration: metadata.format.duration || 0,
          bitrate: metadata.format.bit_rate?.toString() || 'Unknown',
          sampleRate: audioStream.sample_rate || 0,
          channels: audioStream.channels || 0,
          format: metadata.format.format_name || 'Unknown',
        });
      });
    });
  }

  static async convertStereoToMono(inputPath, outputPath, mixMethod = 'mix') {
    const inputInfo = await this.getAudioInfo(inputPath);

    if (inputInfo.channels !== 2) {
      throw new Error('Input file must be stereo (2 channels) to convert to mono');
    }

    return new Promise((resolve, reject) => {
      let audioFilter;
      switch (mixMethod) {
        case 'left':
          audioFilter = 'pan=mono|c0=c0';
          break;
        case 'right':
          audioFilter = 'pan=mono|c0=c1';
          break;
        case 'mix':
        default:
          audioFilter = 'pan=mono|c0=0.5*c0+0.5*c1';
          break;
      }

      ffmpeg(inputPath)
        .audioFilters([audioFilter])
        .audioChannels(1)
        .on('start', () => {
          console.log(`Converting stereo to mono (${mixMethod} method)...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nConversion complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async splitStereoToMono(inputPath, outputDir) {
    const inputInfo = await this.getAudioInfo(inputPath);

    if (inputInfo.channels !== 2) {
      throw new Error('Input file must be stereo (2 channels) to split');
    }

    const baseName = path.parse(inputPath).name;
    const extension = path.extname(inputPath);
    const leftPath = path.join(outputDir, `${baseName}_left${extension}`);
    const rightPath = path.join(outputDir, `${baseName}_right${extension}`);

    return new Promise((resolve, reject) => {
      let completedCount = 0;
      const errors = [];

      const checkCompletion = () => {
        completedCount++;
        if (completedCount === 2) {
          if (errors.length > 0) {
            reject(errors[0]);
          } else {
            console.log('\nStereo split complete!');
            console.log(`Left channel: ${leftPath}`);
            console.log(`Right channel: ${rightPath}`);
            resolve({ leftPath, rightPath });
          }
        }
      };

      console.log('Splitting stereo into left and right channels...');

      // Extract left channel
      ffmpeg(inputPath)
        .audioFilters(['pan=mono|c0=c0'])
        .audioChannels(1)
        .on('end', checkCompletion)
        .on('error', (err) => {
          errors.push(err);
          checkCompletion();
        })
        .save(leftPath);

      // Extract right channel
      ffmpeg(inputPath)
        .audioFilters(['pan=mono|c0=c1'])
        .audioChannels(1)
        .on('end', checkCompletion)
        .on('error', (err) => {
          errors.push(err);
          checkCompletion();
        })
        .save(rightPath);
    });
  }

  static async mergeAudio(inputFiles, outputPath, crossfade = 0) {
    return new Promise((resolve, reject) => {
      let command = ffmpeg();

      // Add all input files
      inputFiles.forEach(file => {
        command = command.input(file);
      });

      // Build filter complex for concatenation
      const filterComplex = [];
      if (crossfade > 0 && inputFiles.length > 1) {
        // Implement crossfade between tracks
        for (let i = 0; i < inputFiles.length - 1; i++) {
          if (i === 0) {
            filterComplex.push(`[0:a][1:a]acrossfade=d=${crossfade}:c1=tri:c2=tri[a01]`);
          } else if (i < inputFiles.length - 2) {
            filterComplex.push(`[a${i-1}${i}][${i+1}:a]acrossfade=d=${crossfade}:c1=tri:c2=tri[a${i}${i+1}]`);
          }
        }
        const lastTag = inputFiles.length > 2 ? `[a${inputFiles.length-2}${inputFiles.length-1}]` : '[a01]';
        command = command.complexFilter(filterComplex.join(';'), lastTag.replace(/[\[\]]/g, ''));
      } else {
        // Simple concatenation without crossfade
        const inputs = inputFiles.map((_, i) => `[${i}:a]`).join('');
        command = command.complexFilter(`${inputs}concat=n=${inputFiles.length}:v=0:a=1[out]`, 'out');
      }

      command
        .on('start', () => {
          console.log(`Merging ${inputFiles.length} audio files...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nMerge complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async extractAudioFromVideo(inputPath, outputPath, format = 'mp3') {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .noVideo()
        .format(format)
        .on('start', () => {
          console.log('Extracting audio from video...');
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nAudio extraction complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async changeChannels(inputPath, outputPath, channels) {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioChannels(channels)
        .on('start', () => {
          console.log(`Changing to ${channels} channel(s)...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nChannel change complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async changeSampleRate(inputPath, outputPath, sampleRate) {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioFrequency(sampleRate)
        .on('start', () => {
          console.log(`Changing sample rate to ${sampleRate} Hz...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nSample rate change complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async applyEQ(inputPath, outputPath, preset) {
    const eqPresets = {
      bass: 'bass=g=10:f=100:w=1',
      treble: 'treble=g=5:f=5000:w=1',
      vocal: 'equalizer=f=800:t=h:w=200:g=3,equalizer=f=3000:t=h:w=1000:g=2',
      flat: 'equalizer=f=1000:t=h:w=1000:g=0',
      loudness: 'loudnorm=I=-16:TP=-1.5:LRA=11'
    };

    const filter = eqPresets[preset] || eqPresets.flat;

    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioFilters([filter])
        .on('start', () => {
          console.log(`Applying ${preset} EQ preset...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nEQ applied!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async reverseAudio(inputPath, outputPath) {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioFilters(['areverse'])
        .on('start', () => {
          console.log('Reversing audio...');
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nAudio reversed!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async convertFormat(inputPath, outputPath, format) {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .format(format)
        .on('start', () => {
          console.log(`Converting to ${format.toUpperCase()}...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nConversion complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async normalizeAudio(inputPath, outputPath, targetLevel = -23) {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioFilters([`loudnorm=I=${targetLevel}:TP=-2:LRA=7`])
        .on('start', () => {
          console.log('Normalizing audio levels...');
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nNormalization complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async adjustVolume(inputPath, outputPath, volumeChange) {
    const volumeChangeStr = volumeChange >= 0 ? `+${volumeChange}dB` : `${volumeChange}dB`;

    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioFilters([`volume=${volumeChangeStr}`])
        .on('start', () => {
          console.log(`Adjusting volume by ${volumeChangeStr}...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nVolume adjustment complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async trimSilence(inputPath, outputPath, threshold = -50) {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioFilters([
          `silenceremove=start_periods=1:start_duration=1:start_threshold=${threshold}dB:detection=peak`,
          'areverse',
          `silenceremove=start_periods=1:start_duration=1:start_threshold=${threshold}dB:detection=peak`,
          'areverse'
        ])
        .on('start', () => {
          console.log('Trimming silence...');
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nSilence trimmed!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async addFade(inputPath, outputPath, fadeIn = 0, fadeOut = 0) {
    if (fadeIn === 0 && fadeOut === 0) {
      throw new Error('At least one fade effect must be specified');
    }

    const audioInfo = await this.getAudioInfo(inputPath);
    const filters = [];

    if (fadeIn > 0) {
      filters.push(`afade=t=in:ss=0:d=${fadeIn}`);
    }

    if (fadeOut > 0) {
      const startTime = audioInfo.duration - fadeOut;
      filters.push(`afade=t=out:st=${startTime}:d=${fadeOut}`);
    }

    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioFilters(filters)
        .on('start', () => {
          const fadeDesc = [];
          if (fadeIn > 0) fadeDesc.push(`fade-in: ${fadeIn}s`);
          if (fadeOut > 0) fadeDesc.push(`fade-out: ${fadeOut}s`);
          console.log(`Adding ${fadeDesc.join(', ')}...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nFade effects added!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }

  static async adjustSpeed(inputPath, outputPath, speedPercentage, preservePitch = true) {
    if (speedPercentage <= 0) {
      throw new Error('Speed percentage must be greater than 0');
    }

    const speedFactor = speedPercentage / 100;
    const audioFilters = [];

    if (preservePitch) {
      if (speedFactor >= 0.5 && speedFactor <= 2.0) {
        audioFilters.push(`atempo=${speedFactor}`);
      } else {
        // Chain multiple atempo filters for extreme speed changes
        let currentFactor = speedFactor;
        while (currentFactor > 2.0) {
          audioFilters.push('atempo=2.0');
          currentFactor /= 2.0;
        }
        while (currentFactor < 0.5) {
          audioFilters.push('atempo=0.5');
          currentFactor /= 0.5;
        }
        if (currentFactor !== 1.0) {
          audioFilters.push(`atempo=${currentFactor}`);
        }
      }
    } else {
      audioFilters.push(`asetrate=${Math.round(44100 * speedFactor)},aresample=44100`);
    }

    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .audioFilters(audioFilters)
        .on('start', () => {
          console.log(`Adjusting speed to ${speedPercentage}%...`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            process.stdout.write(`\rProgress: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log('\nSpeed adjustment complete!');
          resolve();
        })
        .on('error', reject)
        .save(outputPath);
    });
  }
}

// Batch processing function
async function processBatch(args) {
  const operation = args[0];
  const pattern = args[1];
  const outputDir = args[2] || '.';

  if (!operation || !pattern) {
    console.error('Error: Batch processing requires operation and file pattern');
    console.error('Usage: agaudioflow batch <operation> <pattern> [output-dir]');
    console.error('Example: agaudioflow batch normalize "*.mp3" ./output');
    process.exit(1);
  }

  // Get matching files
  const glob = require('glob');
  const files = glob.sync(pattern);

  if (files.length === 0) {
    console.error(`No files matching pattern: ${pattern}`);
    process.exit(1);
  }

  console.log(`\nBatch processing ${files.length} files...`);
  console.log(`Operation: ${operation}`);
  console.log(`Output directory: ${outputDir}\n`);

  // Create output directory if it doesn't exist
  await fs.mkdir(outputDir, { recursive: true });

  let successCount = 0;
  let failCount = 0;
  const additionalArgs = args.slice(3);

  for (const file of files) {
    try {
      console.log(`\nProcessing: ${path.basename(file)}`);
      const outputFile = path.join(outputDir, path.basename(file));

      // Build command arguments
      const commandArgs = [operation, file, ...additionalArgs];

      // Handle output path based on operation
      switch(operation) {
        case 'stereo-to-mono':
        case 's2m':
          commandArgs.push(additionalArgs[0] || 'mix');
          commandArgs.push(outputFile);
          break;
        case 'convert':
        case 'cvt':
          commandArgs.push(additionalArgs[0] || 'mp3');
          commandArgs.push(outputFile);
          break;
        default:
          commandArgs.push(outputFile);
      }

      // Process file
      await processCommand(commandArgs);
      successCount++;
    } catch (error) {
      console.error(`Failed: ${error.message}`);
      failCount++;
    }
  }

  console.log(`\n${'='.repeat(50)}`);
  console.log(`Batch processing complete!`);
  console.log(`Success: ${successCount}/${files.length}`);
  if (failCount > 0) {
    console.log(`Failed: ${failCount}`);
  }
}

// Process individual command
async function processCommand(args) {
  const command = args[0];
  const inputFile = args[1];

  const processor = new AudioProcessor();

  switch (command) {
    case 'stereo-to-mono':
    case 's2m': {
      const method = args[2] || 'mix';
      const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'mono');
      await AudioProcessor.convertStereoToMono(inputFile, outputFile, method);
      return outputFile;
    }

    case 'split-stereo':
    case 'split': {
      const outputDir = args[2] || path.dirname(inputFile);
      await AudioProcessor.splitStereoToMono(inputFile, outputDir);
      break;
    }

    case 'convert':
    case 'cvt': {
      const format = args[2];
      if (!format) {
        throw new Error('Output format is required');
      }
      const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'converted', `.${format}`);
      await AudioProcessor.convertFormat(inputFile, outputFile, format);
      return outputFile;
    }

    case 'normalize':
    case 'norm': {
      const targetLevel = args[2] ? parseFloat(args[2]) : -23;
      const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'normalized');
      await AudioProcessor.normalizeAudio(inputFile, outputFile, targetLevel);
      return outputFile;
    }

    case 'volume':
    case 'vol': {
      const volumeChange = parseFloat(args[2]);
      if (isNaN(volumeChange)) {
        throw new Error('Volume change in dB is required');
      }
      const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, `vol_${volumeChange}dB`);
      await AudioProcessor.adjustVolume(inputFile, outputFile, volumeChange);
      return outputFile;
    }

    case 'trim-silence':
    case 'trim': {
      const threshold = args[2] ? parseFloat(args[2]) : -50;
      const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'trimmed');
      await AudioProcessor.trimSilence(inputFile, outputFile, threshold);
      return outputFile;
    }

    case 'fade': {
      const fadeIn = parseFloat(args[2]) || 0;
      const fadeOut = parseFloat(args[3]) || 0;
      const outputFile = args[4] || AudioProcessor.generateOutputPath(inputFile, 'faded');
      await AudioProcessor.addFade(inputFile, outputFile, fadeIn, fadeOut);
      return outputFile;
    }

    case 'speed': {
      const speedPercentage = parseFloat(args[2]);
      if (isNaN(speedPercentage)) {
        throw new Error('Speed percentage is required');
      }
      const preservePitch = args[3] !== 'false';
      const outputFile = args[4] || AudioProcessor.generateOutputPath(inputFile, `speed_${speedPercentage}`);
      await AudioProcessor.adjustSpeed(inputFile, outputFile, speedPercentage, preservePitch);
      return outputFile;
    }

    default:
      throw new Error(`Unknown command: ${command}`);
  }
}

// CLI Command Handler
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    printHelp();
    return;
  }

  initializeFFmpeg();

  const command = args[0];
  const inputFile = args[1];

  if (!inputFile) {
    console.error('Error: Input file is required');
    printHelp();
    process.exit(1);
  }

  try {
    // Special handling for batch and multi-file operations
    if (command === 'batch') {
      await processBatch(args.slice(1));
      return;
    }

    if (command === 'merge' || command === 'concat') {
      const outputFile = args[args.length - 1];
      const filesToMerge = [];

      // Collect all input files (all args except command and output)
      for (let i = 1; i < args.length - 1; i++) {
        if (!args[i].startsWith('--')) {
          filesToMerge.push(args[i]);
        }
      }

      if (filesToMerge.length < 2) {
        console.error('Error: At least 2 input files required for merge');
        printHelp();
        process.exit(1);
      }

      // Check all input files exist
      for (const file of filesToMerge) {
        await fs.access(file);
      }

      const crossfade = parseFloat(args.find(a => a.startsWith('--crossfade='))?.split('=')[1] || '0');
      await AudioProcessor.mergeAudio(filesToMerge, outputFile, crossfade);
      console.log(`Output: ${outputFile}`);
      return;
    }

    // Check if input file exists
    await fs.access(inputFile);

    switch (command) {
      case 'stereo-to-mono':
      case 's2m': {
        const method = args[2] || 'mix';
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'mono');
        await AudioProcessor.convertStereoToMono(inputFile, outputFile, method);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'split-stereo':
      case 'split': {
        const outputDir = args[2] || path.dirname(inputFile);
        await AudioProcessor.splitStereoToMono(inputFile, outputDir);
        break;
      }

      case 'convert':
      case 'cvt': {
        const format = args[2];
        if (!format) {
          console.error('Error: Output format is required');
          console.error('Supported formats: mp3, wav, aac, flac, ogg');
          process.exit(1);
        }
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'converted', `.${format}`);
        await AudioProcessor.convertFormat(inputFile, outputFile, format);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'normalize':
      case 'norm': {
        const targetLevel = args[2] ? parseFloat(args[2]) : -23;
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'normalized');
        await AudioProcessor.normalizeAudio(inputFile, outputFile, targetLevel);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'volume':
      case 'vol': {
        const volumeChange = parseFloat(args[2]);
        if (isNaN(volumeChange)) {
          console.error('Error: Volume change in dB is required (e.g., 5 or -10)');
          process.exit(1);
        }
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, `vol_${volumeChange}dB`);
        await AudioProcessor.adjustVolume(inputFile, outputFile, volumeChange);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'trim-silence':
      case 'trim': {
        const threshold = args[2] ? parseFloat(args[2]) : -50;
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'trimmed');
        await AudioProcessor.trimSilence(inputFile, outputFile, threshold);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'fade': {
        const fadeIn = parseFloat(args[2]) || 0;
        const fadeOut = parseFloat(args[3]) || 0;
        const outputFile = args[4] || AudioProcessor.generateOutputPath(inputFile, 'faded');
        await AudioProcessor.addFade(inputFile, outputFile, fadeIn, fadeOut);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'speed': {
        const speedPercentage = parseFloat(args[2]);
        if (isNaN(speedPercentage)) {
          console.error('Error: Speed percentage is required (e.g., 50 for half speed, 200 for double speed)');
          process.exit(1);
        }
        const preservePitch = args[3] !== 'false';
        const outputFile = args[4] || AudioProcessor.generateOutputPath(inputFile, `speed_${speedPercentage}`);
        await AudioProcessor.adjustSpeed(inputFile, outputFile, speedPercentage, preservePitch);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'info': {
        const info = await AudioProcessor.getAudioInfo(inputFile);
        console.log('\nAudio Information:');
        console.log(`  Duration: ${Math.round(info.duration)}s`);
        console.log(`  Channels: ${info.channels}`);
        console.log(`  Sample Rate: ${info.sampleRate} Hz`);
        console.log(`  Bitrate: ${info.bitrate}`);
        console.log(`  Format: ${info.format}`);
        break;
      }

      case 'merge':
      case 'concat': {
        const outputFile = args[args.length - 1];
        const filesToMerge = [inputFile, ...args.slice(2, -1)];

        if (filesToMerge.length < 2) {
          console.error('Error: At least 2 input files required for merge');
          process.exit(1);
        }

        // Check all input files exist
        for (const file of filesToMerge) {
          await fs.access(file);
        }

        const crossfade = parseFloat(args.find(a => a.startsWith('--crossfade='))?.split('=')[1] || '0');
        await AudioProcessor.mergeAudio(filesToMerge, outputFile, crossfade);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'extract-audio':
      case 'extract': {
        const format = args[2] || 'mp3';
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, 'audio', `.${format}`);
        await AudioProcessor.extractAudioFromVideo(inputFile, outputFile, format);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'channels': {
        const numChannels = parseInt(args[2]);
        if (isNaN(numChannels) || numChannels < 1 || numChannels > 8) {
          console.error('Error: Number of channels must be between 1 and 8');
          process.exit(1);
        }
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, `${numChannels}ch`);
        await AudioProcessor.changeChannels(inputFile, outputFile, numChannels);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'sample-rate':
      case 'sr': {
        const sampleRate = parseInt(args[2]);
        const validRates = [8000, 11025, 22050, 44100, 48000, 88200, 96000, 192000];
        if (isNaN(sampleRate) || !validRates.includes(sampleRate)) {
          console.error(`Error: Sample rate must be one of: ${validRates.join(', ')}`);
          process.exit(1);
        }
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, `${sampleRate}hz`);
        await AudioProcessor.changeSampleRate(inputFile, outputFile, sampleRate);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'eq': {
        const preset = args[2] || 'flat';
        const validPresets = ['bass', 'treble', 'vocal', 'flat', 'loudness'];
        if (!validPresets.includes(preset)) {
          console.error(`Error: EQ preset must be one of: ${validPresets.join(', ')}`);
          process.exit(1);
        }
        const outputFile = args[3] || AudioProcessor.generateOutputPath(inputFile, `eq_${preset}`);
        await AudioProcessor.applyEQ(inputFile, outputFile, preset);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'reverse': {
        const outputFile = args[2] || AudioProcessor.generateOutputPath(inputFile, 'reversed');
        await AudioProcessor.reverseAudio(inputFile, outputFile);
        console.log(`Output: ${outputFile}`);
        break;
      }

      case 'batch': {
        await processBatch(args.slice(1));
        break;
      }

      default:
        console.error(`Error: Unknown command '${command}'`);
        printHelp();
        process.exit(1);
    }
  } catch (error) {
    console.error(`\nError: ${error.message}`);
    process.exit(1);
  }
}

function printHelp() {
  console.log(`
AG AudioFlow CLI - Professional Audio Processing Tool

Usage: agaudioflow <command> <input-file> [options]

Core Commands:
  stereo-to-mono, s2m <input> [method] [output]
    Convert stereo to mono. Methods: mix (default), left, right

  split-stereo, split <input> [output-dir]
    Split stereo into separate left and right mono files

  convert, cvt <input> <format> [output]
    Convert audio format. Formats: mp3, wav, aac, flac, ogg

  normalize, norm <input> [target-level] [output]
    Normalize audio levels. Default target: -23 LUFS

  volume, vol <input> <dB-change> [output]
    Adjust volume by specified dB (positive or negative)

  trim-silence, trim <input> [threshold] [output]
    Remove silence from beginning and end. Default threshold: -50dB

  fade <input> <fade-in-seconds> <fade-out-seconds> [output]
    Add fade in/out effects

  speed <input> <percentage> [preserve-pitch] [output]
    Adjust playback speed. 50 = half speed, 200 = double speed
    preserve-pitch: true (default) or false

Advanced Commands:
  merge, concat <input1> <input2> [...] <output> [--crossfade=seconds]
    Merge multiple audio files into one

  extract-audio, extract <video-file> [format] [output]
    Extract audio from video file

  channels <input> <num-channels> [output]
    Change number of audio channels (1-8)

  sample-rate, sr <input> <rate> [output]
    Change sample rate. Valid: 8000, 11025, 22050, 44100, 48000, 88200, 96000

  eq <input> <preset> [output]
    Apply EQ preset. Presets: bass, treble, vocal, flat, loudness

  reverse <input> [output]
    Reverse audio playback

  batch <operation> <pattern> [output-dir] [options]
    Batch process multiple files

  info <input>
    Display detailed audio file information

Examples:
  agaudioflow stereo-to-mono audio.mp3 mix
  agaudioflow merge track1.mp3 track2.mp3 track3.mp3 combined.mp3 --crossfade=2
  agaudioflow batch normalize "*.mp3" ./normalized
  agaudioflow extract-audio video.mp4 mp3
  agaudioflow eq music.mp3 bass
  agaudioflow channels stereo.mp3 1
  agaudioflow sample-rate audio.mp3 48000
`);
}

// Run the CLI
main().catch(error => {
  console.error('Fatal error:', error.message);
  process.exit(1);
});