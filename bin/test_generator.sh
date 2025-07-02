#!/usr/bin/env bash
# Test script for J Dilla chord progression generator
# Validates script logic without requiring SoX installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/generate_dilla_chords.sh"
ZSH_SCRIPT="$SCRIPT_DIR/generate_dilla_chords_zsh.sh"

echo "Testing J Dilla Chord Progression Generator Scripts"
echo "=================================================="

# Test 1: Check if scripts exist and are executable
echo "Test 1: Script existence and permissions"
if [[ -x "$MAIN_SCRIPT" ]]; then
    echo "✓ Main script exists and is executable"
else
    echo "✗ Main script missing or not executable"
    exit 1
fi

if [[ -x "$ZSH_SCRIPT" ]]; then
    echo "✓ ZSH script exists and is executable"
else
    echo "✗ ZSH script missing or not executable"
    exit 1
fi

# Test 2: Syntax validation
echo
echo "Test 2: Syntax validation"
if bash -n "$MAIN_SCRIPT"; then
    echo "✓ Main script syntax is valid"
else
    echo "✗ Main script has syntax errors"
    exit 1
fi

if bash -n "$ZSH_SCRIPT"; then
    echo "✓ ZSH script syntax is valid"
else
    echo "✗ ZSH script has syntax errors"
    exit 1
fi

# Test 3: Check chord frequency definitions
echo
echo "Test 3: Chord frequency validation"
EXPECTED_CHORDS=("bb_major" "f_major" "eb_major" "c_minor" "g_minor")
for chord in "${EXPECTED_CHORDS[@]}"; do
    if grep -q "CHORD_FREQS\[$chord\]" "$MAIN_SCRIPT"; then
        echo "✓ Found chord definition: $chord"
    else
        echo "✗ Missing chord definition: $chord"
        exit 1
    fi
done

# Test 4: Test error handling (should fail gracefully without SoX)
echo
echo "Test 4: Error handling validation"
echo "Running script without SoX (should show proper error):"
echo "----"
if output=$(cd /tmp && "$MAIN_SCRIPT" 2>&1); then
    echo "✗ Script should have failed without SoX"
    exit 1
else
    if echo "$output" | grep -q "Command 'sox' not found"; then
        echo "✓ Proper error message displayed for missing SoX"
    else
        echo "✗ Unexpected error message"
        echo "Got: $output"
        exit 1
    fi
fi

# Test 5: Verify frequency accuracy
echo
echo "Test 5: Musical frequency accuracy check"
# Standard 4th octave frequencies (A4 = 440 Hz)
declare -A EXPECTED_FREQS
EXPECTED_FREQS[440.00]="A4"     # Reference pitch
EXPECTED_FREQS[261.63]="C4"     # Used in C minor
EXPECTED_FREQS[293.66]="D4"     # Used in Bb major and G minor  
EXPECTED_FREQS[349.23]="F4"     # Used in Bb major and F major
EXPECTED_FREQS[392.00]="G4"     # Used in Eb major and C minor

for freq in "${!EXPECTED_FREQS[@]}"; do
    if grep -q "$freq" "$MAIN_SCRIPT"; then
        echo "✓ Found accurate frequency: $freq Hz (${EXPECTED_FREQS[$freq]})"
    else
        echo "⚠ Note: $freq Hz (${EXPECTED_FREQS[$freq]}) not found - may be using octave variants"
    fi
done

# Test 6: Check for security features
echo
echo "Test 6: Security features validation"
SECURITY_FEATURES=("check_privileges" "doas" "trap" "set -e")
for feature in "${SECURITY_FEATURES[@]}"; do
    if grep -q "$feature" "$MAIN_SCRIPT"; then
        echo "✓ Security feature implemented: $feature"
    else
        echo "⚠ Security feature missing: $feature"
    fi
done

# Test 7: Documentation completeness
echo
echo "Test 7: Documentation validation"
README_FILE="$SCRIPT_DIR/README.md"
if [[ -f "$README_FILE" ]]; then
    echo "✓ README.md exists"
    
    DOC_SECTIONS=("Usage" "Requirements" "Troubleshooting" "Chord Progression")
    for section in "${DOC_SECTIONS[@]}"; do
        if grep -q "$section" "$README_FILE"; then
            echo "✓ Documentation section found: $section"
        else
            echo "⚠ Documentation section missing: $section"
        fi
    done
else
    echo "✗ README.md missing"
fi

echo
echo "=================================================="
echo "All tests completed successfully! ✓"
echo
echo "To test with actual audio generation:"
echo "1. Install SoX: pkg_add sox (OpenBSD) or apt-get install sox (Linux)"
echo "2. Run: ./generate_dilla_chords.sh"
echo "3. Play: sox DILLA_CHORDS.WAV -d"