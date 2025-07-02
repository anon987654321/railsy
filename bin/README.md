# J Dilla Chord Progression Generator

This directory contains shell scripts to generate a J Dilla-inspired chord progression WAV file using SoX (Sound eXchange).

## Scripts

### `generate_dilla_chords.sh`
- **Primary script** - Bash/ZSH compatible version
- Works on most Unix-like systems including Linux, macOS, and OpenBSD
- Uses bash-compatible syntax for broader compatibility

### `generate_dilla_chords_zsh.sh`  
- **ZSH-optimized version** - Uses ZSH-specific features for OpenBSD
- **OpenBSD pledge/unveil integration** - Secure execution with minimal privileges
- **Mock mode support** - Demo functionality without SoX requirement
- More efficient array handling with ZSH syntax

## Requirements

- **SoX v14.4.2 or later**: Audio processing toolkit
- **OpenBSD installation**: `doas pkg_add sox`
- **Other systems**: Check your package manager (e.g., `apt-get install sox`, `brew install sox`)

## Usage

```bash
# Make executable (if not already)
chmod +x generate_dilla_chords.sh

# Run the script
./generate_dilla_chords.sh

# Demo mode (no SoX required) - shows what would be generated
./generate_dilla_chords.sh --mock

# Show help
./generate_dilla_chords.sh --help

# Or use the ZSH version on OpenBSD (with security features)
./generate_dilla_chords_zsh.sh

# ZSH version with mock mode
./generate_dilla_chords_zsh.sh --mock

# Show help for ZSH version
./generate_dilla_chords_zsh.sh --help

# With privilege escalation if needed
doas ./generate_dilla_chords.sh
```

## Output

- **File**: `DILLA_CHORDS.WAV`
- **Duration**: ~16 seconds (5 chords × 2 seconds each, repeated once)
- **Format**: Stereo WAV at 44.1kHz sample rate

## Chord Progression

Based on J Dilla's "So Far To Go":
1. **Bb Major** (Bb4, D4, F4)
2. **F Major** (F4, A4, C5)  
3. **Eb Major** (Eb4, G4, Bb4)
4. **C minor** (C4, Eb4, G4)
5. **G minor** (G3, Bb3, D4)

Each chord is repeated once for a total of 10 chord changes.

## Technical Details

- **Synthesis**: Pure sine waves for each chord tone
- **Effects**: 
  - Fade in/out for smooth transitions
  - Reverb for ambient space
  - Gain control for consistent volume
- **Approach**: Two-method fallback system
  1. One-liner SoX command (efficient)
  2. Multi-command approach (more reliable)

## Playback

```bash
# Using SoX
sox DILLA_CHORDS.WAV -d

# Linux with ALSA
aplay DILLA_CHORDS.WAV

# OpenBSD
aucat -i DILLA_CHORDS.WAV

# macOS
afplay DILLA_CHORDS.WAV
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "zsh not found" | Change shebang to `#!/usr/bin/env bash` |
| "sox not found" | Install SoX: `doas pkg_add sox` |
| Permission denied | Use `doas ./generate_dilla_chords.sh` |
| Audio issues | Check output: `sox DILLA_CHORDS.WAV -n stat` |
| File too small | Check SoX version and error messages |

## Security

- **OpenBSD pledge/unveil** (ZSH version): Minimal privileges and filesystem access
- **Simple tier security**: Minimal attack surface  
- **No external inputs**: All parameters are hardcoded
- **Clear fallbacks**: Multiple generation methods
- **Privilege escalation**: Optional doas/sudo support (doas preferred on OpenBSD)
- **Input validation**: Parameter validation and sanitization
- **Cleanup**: Automatic temporary file removal

## Frequency Reference

| Note | Frequency (Hz) |
|------|----------------|
| G3   | 196.00        |
| Bb3  | 233.08        |
| C4   | 261.63        |
| D4   | 293.66        |
| Eb4  | 311.13        |
| F4   | 349.23        |
| G4   | 392.00        |
| A4   | 440.00        |
| Bb4  | 466.16        |
| C5   | 523.25        |