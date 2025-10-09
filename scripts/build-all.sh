#!/bin/bash

# Build all WebWords implementations in parallel with progress tracking
set -e

# Get number of CPU cores
CORES=$(nproc)
echo "Building all WebWords implementations using $CORES parallel jobs"

# List all language directories
LANGUAGES=(
    "python" "go" "js" "php" "java" "cpp" "csharp" "elixir" 
    "awk" "rust" "perl" "ruby" "swift" "lua" "bash" "kotlin"
    "tcl" "sql" "vbnet" "brainfuck" "powershell" "matlab" 
    "prolog" "assembly" "fortran" "cobol" "odin" "v" "zig" 
    "deno" "julia" "erlang" "nim" "crystal" "clojure" "fsharp" 
    "ocaml" "haskell" "r" "dart" "scala"
)

TOTAL=${#LANGUAGES[@]}
COMPLETED=0
FAILED=()
SUCCESS=()

# Create build directory and status file
BUILD_DIR="/tmp/webwords"
mkdir -p $BUILD_DIR
STATUS_FILE="$BUILD_DIR/build-status"
echo "0" > $STATUS_FILE

# Function to build a single language
build_language() {
    local lang=$1
    local start_time=$(date +%s)
    
    if [ -d "$lang" ]; then
        echo "Building $lang..."
        if docker build -t "webwords-$lang" "$lang" > "$BUILD_DIR/build-$lang.log" 2>&1; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            echo "✓ $lang completed in ${duration}s"
            echo "$lang" >> "$BUILD_DIR/webwords-success"
        else
            echo "✗ $lang failed"
            echo "$lang" >> "$BUILD_DIR/webwords-failed"
        fi
    else
        echo "⚠ $lang directory not found"
        echo "$lang" >> "$BUILD_DIR/webwords-failed"
    fi
    
    # Update progress
    local current=$(cat $STATUS_FILE)
    echo $((current + 1)) > $STATUS_FILE
}

# Clean up status files
rm -f $BUILD_DIR/webwords-success $BUILD_DIR/webwords-failed

# Function to show progress
show_progress() {
    while [ $COMPLETED -lt $TOTAL ]; do
        COMPLETED=$(cat $STATUS_FILE)
        local percent=$((COMPLETED * 100 / TOTAL))
        local filled=$((percent / 2))
        local empty=$((50 - filled))
        
        printf "\rProgress: ["
        printf "%${filled}s" | tr ' ' '='
        printf "%${empty}s" | tr ' ' '-'
        printf "] %d/%d (%d%%)" $COMPLETED $TOTAL $percent
        
        sleep 1
    done
    echo
}

echo "Starting parallel builds..."

# Start progress monitor in background
show_progress &
PROGRESS_PID=$!

# Export the build_language function and required variables for xargs
export -f build_language
export BUILD_DIR
export STATUS_FILE

# Use xargs to limit parallel jobs to number of cores
printf "%s\n" "${LANGUAGES[@]}" | xargs -n 1 -P $CORES -I {} bash -c 'build_language "{}"'

# Stop progress monitor
kill $PROGRESS_PID 2>/dev/null || true
wait $PROGRESS_PID 2>/dev/null || true

echo
echo "Build completed!"

# Show results
if [ -f "$BUILD_DIR/webwords-success" ]; then
    SUCCESS_COUNT=$(wc -l < $BUILD_DIR/webwords-success)
    echo "✓ Successful builds ($SUCCESS_COUNT):"
    cat $BUILD_DIR/webwords-success | sed 's/^/  /'
else
    SUCCESS_COUNT=0
fi

if [ -f "$BUILD_DIR/webwords-failed" ]; then
    FAILED_COUNT=$(wc -l < $BUILD_DIR/webwords-failed)
    echo "✗ Failed builds ($FAILED_COUNT):"
    cat $BUILD_DIR/webwords-failed | sed 's/^/  /'
else
    FAILED_COUNT=0
fi

echo
echo "Summary: $SUCCESS_COUNT successful, $FAILED_COUNT failed out of $TOTAL total"

# Clean up
rm -f $STATUS_FILE $BUILD_DIR/webwords-success $BUILD_DIR/webwords-failed $BUILD_DIR/build-*.log