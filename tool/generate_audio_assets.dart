// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final audioDir = Directory('assets/audio');
  if (!audioDir.existsSync()) {
    audioDir.createSync(recursive: true);
  }

  print('Generating high-fidelity audio assets...');

  // 1. Place Sound (punchy, warm, tactile Block Blast candy-wood pop)
  File('assets/audio/place_wood.wav').writeAsBytesSync(_generatePlaceSound());
  print('Generated place_wood.wav');

  // 2. Line Clear / Juicy Pop Sound
  File('assets/audio/pop_juicy.wav').writeAsBytesSync(_generateExplosionSound());
  print('Generated pop_juicy.wav');

  // 3. Combo Sounds (1 to 10) - Super satisfying celesta + crystal chime chords
  for (int i = 1; i <= 10; i++) {
    File('assets/audio/combo_$i.wav').writeAsBytesSync(_generateComboSound(i));
    print('Generated combo_$i.wav');
  }

  // 4. All Clear Fanfare
  File('assets/audio/all_clear.wav').writeAsBytesSync(_generateAllClearSound());
  print('Generated all_clear.wav');

  print('Audio asset generation complete!');
}

// ─── 1. Place: Punchy, warm, tactile Block Blast candy-wood pop ───────────────
Uint8List _generatePlaceSound() {
  const int sampleRate = 22050;
  const double duration = 0.058; // 58ms crisp pop
  final int totalSamples = (sampleRate * duration).round();
  final List<double> samples = List.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final double t = i / totalSamples;

    // Layer 1: Warm low-mid physical body (240Hz down to 135Hz with fast punch)
    final double bodyFreq = 240.0 * exp(-t * 10.0);
    final double body = sin(2 * pi * bodyFreq * (i / sampleRate)) * 0.82;

    // Layer 2: Organic candy bubble resonance (380Hz down to 240Hz)
    final double bubbleFreq = 380.0 * exp(-t * 14.0);
    final double bubble = sin(2 * pi * bubbleFreq * (i / sampleRate)) * 0.38;

    // Layer 3: Crisp tactile mallet tap (first 5ms transient)
    final double click = sin(2 * pi * 680.0 * (i / sampleRate)) * exp(-t * 45.0) * 0.28;

    final double env = exp(-t * 14.0);
    final double attack = (t < 0.002 ? t / 0.002 : 1.0);

    final double raw = (body + bubble + click) * env * attack;
    // Soft saturation for maximum clear loudness without clipping
    samples[i] = (raw / (1.0 + raw.abs() * 0.12)).clamp(-0.98, 0.98);
  }
  return _createWav(samples, sampleRate: sampleRate);
}

// ─── 2. Combo Chimes: Ultra-satisfying celesta + bell shimmer progression ─────
Uint8List _generateComboSound(int comboIndex) {
  const int sampleRate = 22050;
  const double duration = 0.44; // 440ms lingering resonance
  final int totalSamples = (sampleRate * duration).round();
  final List<double> samples = List.filled(totalSamples, 0.0);

  final List<double> diatonicFrequencies = [
    523.25, // 1: C5
    587.33, // 2: D5
    659.25, // 3: E5
    698.46, // 4: F5
    783.99, // 5: G5
    880.00, // 6: A5
    987.77, // 7: B5
    1046.50, // 8: C6
    1174.66, // 9: D6
    1318.51, // 10: E6
    1396.91, // 11: F6
    1567.98, // 12: G6
    1760.00, // 13: A6
    1975.53, // 14: B6
    2093.00, // 15: C7
  ];

  final double baseFreq = diatonicFrequencies[(comboIndex - 1).clamp(0, diatonicFrequencies.length - 1)];

  for (int i = 0; i < totalSamples; i++) {
    final double t = i / totalSamples;
    final double env = exp(-t * 4.8);
    final double attack = (t < 0.003 ? t / 0.003 : 1.0);

    // Layer 1: Warm fundamental chime
    final double fund = sin(2 * pi * baseFreq * (i / sampleRate)) * 0.65;
    // Layer 2: Octave overtone (bright bell shimmer)
    final double octave = sin(2 * pi * (baseFreq * 2.0) * (i / sampleRate)) * 0.35 * exp(-t * 6.0);
    // Layer 3: Fifth harmonic (rich celestial sparkle)
    final double fifth = sin(2 * pi * (baseFreq * 1.5) * (i / sampleRate)) * 0.20 * exp(-t * 7.5);
    // Layer 4: High sparkle 3rd harmonic
    final double sparkle = sin(2 * pi * (baseFreq * 3.0) * (i / sampleRate)) * 0.12 * exp(-t * 9.0);
    // Layer 5: Warm marimba wooden transient (first 8ms)
    final double mallet = sin(2 * pi * (baseFreq * 0.5) * (i / sampleRate)) * exp(-t * 28.0) * 0.30;

    final double raw = (fund + octave + fifth + sparkle + mallet) * env * attack;
    samples[i] = (raw / (1.0 + raw.abs() * 0.15)).clamp(-0.98, 0.98);
  }
  return _createWav(samples, sampleRate: sampleRate);
}

// ─── 3. Line Clear: Juicy candy pop & sub thump ──────────────────────────────
Uint8List _generateExplosionSound() {
  const int sampleRate = 22050;
  const double duration = 0.32;
  final int totalSamples = (sampleRate * duration).round();
  final List<double> samples = List.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final double t = i / totalSamples;

    // 1. Deep Sub-Punch: 130Hz -> 50Hz (satisfying physical thud)
    final double subFreq = 130.0 * exp(-t * 8.0);
    final double subWave = sin(2 * pi * subFreq * (i / sampleRate)) * exp(-t * 7.0) * 0.65;

    // 2. Juicy Candy Pop: 420Hz -> 260Hz
    final double popFreq = 420.0 * exp(-t * 12.0);
    final double popWave = sin(2 * pi * popFreq * (i / sampleRate)) * exp(-t * 14.0) * 0.45;

    // 3. Mallet Glass Tone (D5 + A5)
    final double mallet1 = sin(2 * pi * 587.33 * (i / sampleRate)) * 0.35;
    final double mallet2 = sin(2 * pi * 880.00 * (i / sampleRate)) * 0.20;
    final double malletEnv = exp(-t * 16.0);

    // 4. Crisp Transient Click
    final double click = sin(2 * pi * 2400.0 * (i / sampleRate)) * exp(-t * 60.0) * 0.25;

    final double raw = subWave + popWave + ((mallet1 + mallet2) * malletEnv) + click;
    samples[i] = (raw / (1.0 + raw.abs() * 0.20)).clamp(-0.98, 0.98);
  }
  return _createWav(samples, sampleRate: sampleRate);
}

// ─── 4. All Clear Fanfare ───────────────────────────────────────────────────
Uint8List _generateAllClearSound() {
  const int sampleRate = 22050;
  const double duration = 0.85;
  final int totalSamples = (sampleRate * duration).round();
  final List<double> samples = List.filled(totalSamples, 0.0);

  final List<double> chordFreqs = [523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98]; // C Major arpeggio
  final int noteCount = chordFreqs.length;

  for (int i = 0; i < totalSamples; i++) {
    final double t = i / totalSamples;
    double val = 0.0;

    for (int c = 0; c < noteCount; c++) {
      final double noteStart = c * 0.06;
      if (t >= noteStart) {
        final double noteT = (t - noteStart) / (1.0 - noteStart);
        final double noteEnv = exp(-noteT * 3.5);
        final double f = chordFreqs[c];
        val += (sin(2 * pi * f * (i / sampleRate)) * 0.50 +
                sin(2 * pi * (f * 2.0) * (i / sampleRate)) * 0.25) *
            noteEnv /
            noteCount;
      }
    }

    final double sub = sin(2 * pi * 90.0 * (i / sampleRate)) * exp(-t * 4.0) * 0.35;
    final double raw = val * 1.8 + sub;
    samples[i] = (raw / (1.0 + raw.abs() * 0.15)).clamp(-0.98, 0.98);
  }
  return _createWav(samples, sampleRate: sampleRate);
}

// ─── WAV File Header Generator ──────────────────────────────────────────────
Uint8List _createWav(List<double> samples, {required int sampleRate}) {
  final int numSamples = samples.length;
  final int byteRate = sampleRate * 2;
  final int blockAlign = 2;
  final int subChunk2Size = numSamples * 2;
  final int chunkSize = 36 + subChunk2Size;

  final ByteData byteData = ByteData(44 + subChunk2Size);

  byteData.setUint8(0, 0x52); // 'R'
  byteData.setUint8(1, 0x49); // 'I'
  byteData.setUint8(2, 0x46); // 'F'
  byteData.setUint8(3, 0x46); // 'F'
  byteData.setUint32(4, chunkSize, Endian.little);
  byteData.setUint8(8, 0x57);  // 'W'
  byteData.setUint8(9, 0x41);  // 'A'
  byteData.setUint8(10, 0x56); // 'V'
  byteData.setUint8(11, 0x45); // 'E'

  byteData.setUint8(12, 0x66); // 'f'
  byteData.setUint8(13, 0x6D); // 'm'
  byteData.setUint8(14, 0x74); // 't'
  byteData.setUint8(15, 0x20); // ' '
  byteData.setUint32(16, 16, Endian.little);
  byteData.setUint16(20, 1, Endian.little);
  byteData.setUint16(22, 1, Endian.little);
  byteData.setUint32(24, sampleRate, Endian.little);
  byteData.setUint32(28, byteRate, Endian.little);
  byteData.setUint16(32, blockAlign, Endian.little);
  byteData.setUint16(34, 16, Endian.little);

  byteData.setUint8(36, 0x64); // 'd'
  byteData.setUint8(37, 0x61); // 'a'
  byteData.setUint8(38, 0x74); // 't'
  byteData.setUint8(39, 0x61); // 'a'
  byteData.setUint32(40, subChunk2Size, Endian.little);

  int offset = 44;
  for (int i = 0; i < numSamples; i++) {
    final int sample = (samples[i].clamp(-1.0, 1.0) * 32767).toInt();
    byteData.setInt16(offset, sample, Endian.little);
    offset += 2;
  }

  return byteData.buffer.asUint8List();
}
