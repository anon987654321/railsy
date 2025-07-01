#!/usr/bin/env zsh
set -e

# Generate J Dilla-inspired chord progression WAV file using SoX (ZSH version)
# Based on "So Far To Go" chord progression: Bb Major, F Major, Eb Major, C minor, G minor
# Optimized for SoX v14.4.2 on OpenBSD using zsh
# 
# Usage: ./generate_dilla_chords_zsh.sh
# Output: DILLA_CHORDS.WAV (approximately 16 seconds)
#
# Installation on OpenBSD:
#   doas pkg_add sox
#   # or compile from ports: cd /usr/ports/audio/sox && doas make install
#
# Security: Simple tier - minimal attack surface, no external inputs, clear fallbacks
#
# Troubleshooting:
#   - If "sox not found": install SoX via pkg_add sox
#   - If permission denied: use doas ./generate_dilla_chords_zsh.sh
#   - If audio issues: check output with: sox DILLA_CHORDS.WAV -n stat

# Configuration
OUTPUT_FILE="DILLA_CHORDS.WAV"
CHORD_DURATION=2      # seconds per chord
SAMPLE_RATE=44100     # standard audio sample rate
CHANNELS=2            # stereo

# Chord frequencies (Hz) - using 4th octave as base
# Each chord contains 3 notes (root, third, fifth)
declare -A CHORD_FREQS
CHORD_FREQS[bb_major]="233.08 293.66 349.23"    # Bb4, D4, F4
CHORD_FREQS[f_major]="349.23 440.00 523.25"     # F4, A4, C5
CHORD_FREQS[eb_major]="311.13 392.00 466.16"    # Eb4, G4, Bb4
CHORD_FREQS[c_minor]="261.63 311.13 392.00"     # C4, Eb4, G4
CHORD_FREQS[g_minor]="196.00 233.08 293.66"     # G3, Bb3, D4

# Logging function
log() {
    echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') - $1"
}

# Error handling function
error() {
    log "ERROR: $1"
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1 || {
        error "Command '$1' not found. Please install SoX v14.4.2 or later."
    }
}

# Check for doas/sudo if needed (privilege escalation support)
check_privileges() {
    if [[ ! -w "$(pwd)" ]]; then
        if command -v doas > /dev/null 2>&1; then
            log "Using doas for privilege escalation"
            exec doas "$0" "$@"
        elif command -v sudo > /dev/null 2>&1; then
            log "Using sudo for privilege escalation"
            exec sudo "$0" "$@"
        else
            error "No write permission and no privilege escalation available"
        fi
    fi
}

# Generate a single chord using sine wave synthesis
generate_chord() {
    local chord_name="$1"
    local output_file="$2"
    local freqs="${CHORD_FREQS[$chord_name]}"
    
    if [[ -z "$freqs" ]]; then
        error "Unknown chord: $chord_name"
    fi
    
    log "Generating $chord_name chord: $freqs Hz"
    
    # ZSH-specific array splitting
    local freq_array=("${(@s/ /)freqs}")
    local synth_parts=()
    
    # Create synth command parts for each frequency
    for freq in $freq_array; do
        synth_parts+=("synth $CHORD_DURATION sine $freq")
    done
    
    # Generate chord by mixing sine waves
    sox -n -r $SAMPLE_RATE -c $CHANNELS "$output_file" \
        "${synth_parts[@]}" \
        fade h 0.1 $CHORD_DURATION 0.1 \
        gain -6 \
        reverb 20 50 100 100 0 0
        
    if [[ $? -ne 0 ]]; then
        error "Failed to generate chord: $chord_name"
    fi
}

# Main chord generation function with fallback approaches
generate_dilla_progression() {
    log "Starting J Dilla chord progression generation"
    log "Output file: $OUTPUT_FILE"
    log "Chord duration: ${CHORD_DURATION}s each, repeated once"
    
    # Clean up any existing temp files
    rm -f chord_*.wav temp_progression.wav "$OUTPUT_FILE" 2>/dev/null || true
    
    # Method 1: Try one-liner approach (preferred)
    log "Attempting one-liner SoX command approach..."
    
    if generate_one_liner; then
        log "One-liner approach successful"
        return 0
    fi
    
    log "One-liner failed, falling back to multi-command approach..."
    
    # Method 2: Fallback multi-command approach
    if generate_multi_command; then
        log "Multi-command approach successful"
        return 0
    fi
    
    error "Both generation methods failed"
}

# One-liner approach - complex but efficient (ZSH optimized)
generate_one_liner() {
    local chord_sequence=("bb_major" "f_major" "eb_major" "c_minor" "g_minor")
    
    # Build complex SoX command for entire progression
    local sox_cmd="sox -n -r $SAMPLE_RATE -c $CHANNELS \"$OUTPUT_FILE\""
    
    # Add each chord twice (repeated once)
    for iteration in {1..2}; do
        for chord in $chord_sequence; do
            local freqs="${CHORD_FREQS[$chord]}"
            # ZSH-specific array splitting
            local freq_array=("${(@s/ /)freqs}")
            
            # Add synth parts for this chord
            for freq in $freq_array; do
                sox_cmd+=" synth $CHORD_DURATION sine $freq"
            done
        done
    done
    
    # Add effects
    sox_cmd+=" fade h 0.2 $(( ${#chord_sequence} * 2 * $CHORD_DURATION )) 0.2"
    sox_cmd+=" gain -3 reverb 30 50 100 100 10 0"
    
    log "Executing: $sox_cmd"
    
    # Execute the command
    eval "$sox_cmd" 2>/dev/null || return 1
    
    return 0
}

# Multi-command fallback approach - more reliable
generate_multi_command() {
    local chord_sequence=("bb_major" "f_major" "eb_major" "c_minor" "g_minor")
    local temp_files=()
    
    log "Generating individual chord files..."
    
    # Generate each chord file
    for chord in $chord_sequence; do
        local chord_file="chord_${chord}.wav"
        generate_chord "$chord" "$chord_file"
        temp_files+=("$chord_file")
    done
    
    log "Creating chord progression sequence..."
    
    # Create the progression (each chord twice)
    local sequence_files=()
    for iteration in {1..2}; do
        for chord_file in $temp_files; do
            sequence_files+=("$chord_file")
        done
    done
    
    log "Concatenating and applying effects..."
    
    # Concatenate all chord files
    sox "${sequence_files[@]}" temp_progression.wav
    
    if [[ $? -ne 0 ]]; then
        error "Failed to concatenate chord files"
    fi
    
    # Apply final effects
    sox temp_progression.wav "$OUTPUT_FILE" \
        fade h 0.2 0 0.2 \
        gain -1 \
        reverb 25 50 100 100 5 0
    
    if [[ $? -ne 0 ]]; then
        error "Failed to apply final effects"
    fi
    
    # Clean up temporary files
    rm -f chord_*.wav temp_progression.wav
    
    return 0
}

# Verify output file
verify_output() {
    if [[ ! -f "$OUTPUT_FILE" ]]; then
        error "Output file was not created: $OUTPUT_FILE"
    fi
    
    local file_size=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null)
    
    if [[ $file_size -lt 1000 ]]; then
        error "Output file appears to be too small: ${file_size} bytes"
    fi
    
    log "Successfully created $OUTPUT_FILE (${file_size} bytes)"
    
    # Try to get duration info if possible
    if sox --info "$OUTPUT_FILE" 2>/dev/null | grep -q "Duration"; then
        local duration=$(sox --info "$OUTPUT_FILE" 2>/dev/null | grep "Duration" | awk '{print $3}')
        log "Audio duration: ${duration}"
    fi
}

# Main execution
main() {
    log "J Dilla Chord Progression Generator v1.0 (ZSH)"
    log "Generating chord progression based on 'So Far To Go'"
    log "Target: Bb Major -> F Major -> Eb Major -> C minor -> G minor (repeated)"
    
    # Check prerequisites
    check_privileges
    command_exists "sox"
    
    # Verify SoX version (warn if not v14.4.2)
    local sox_version=$(sox --version 2>/dev/null | head -1)
    log "SoX version: $sox_version"
    
    if ! echo "$sox_version" | grep -q "v14.4"; then
        log "WARNING: Script optimized for SoX v14.4.2, current version may behave differently"
    fi
    
    # Generate the progression
    generate_dilla_progression
    
    # Verify output
    verify_output
    
    log "J Dilla chord progression generation complete!"
    log "Play with: sox \"$OUTPUT_FILE\" -d"
    log "Or: aplay \"$OUTPUT_FILE\" (Linux)"
    log "Or: aucat -i \"$OUTPUT_FILE\" (OpenBSD)"
}

# Trap to clean up on exit
trap 'rm -f chord_*.wav temp_progression.wav 2>/dev/null' EXIT

# Execute main function
main "$@"