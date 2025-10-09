#!/bin/bash

# Test all WebWords implementations concurrently 
# 
# Configuration via environment variables:
#   WEBWORDS_CONCURRENT_JOBS - Number of concurrent tests (default: number of CPU cores)
#   WEBWORDS_PORT_RANGE_START - Starting port for random ports (default: 32000)
#   WEBWORDS_PORT_RANGE_SIZE - Size of port range (default: 8000)
#   WEBWORDS_STARTUP_WAIT - Seconds to wait for container startup (default: 5)
#
# Usage:
#   ./test-all.sh                           # Use all CPU cores
#   WEBWORDS_CONCURRENT_JOBS=4 ./test-all.sh # Use 4 concurrent jobs
#   make test-all                           # Via Makefile
#
set -e

# Create output directory
BUILD_DIR="/tmp/webwords"
mkdir -p $BUILD_DIR

# Log file
LOG_FILE="$BUILD_DIR/test-results.log"
WORKING_FILE="$BUILD_DIR/working-implementations"
BROKEN_FILE="$BUILD_DIR/broken-implementations"

# Clear previous results
> $LOG_FILE
> $WORKING_FILE
> $BROKEN_FILE

# Get number of CPU cores for concurrent testing (configurable via environment variable)
CPU_CORES=${WEBWORDS_CONCURRENT_JOBS:-$(nproc)}

echo "Testing all WebWords implementations with $CPU_CORES concurrent jobs..." | tee $LOG_FILE
echo "===================================================================" | tee -a $LOG_FILE
echo "Output logged to: $LOG_FILE" | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

# Get all webwords images (excluding old git ones and test variants)
IMAGES=$(docker images | grep webwords | grep -v git | grep -v '\-test$' | awk '{print $1}' | sort)

# Convert to array for easier processing
IMAGES_ARRAY=($IMAGES)
TOTAL_IMAGES=${#IMAGES_ARRAY[@]}

# Configuration variables with defaults
PORT_RANGE_START=${WEBWORDS_PORT_RANGE_START:-32000}
PORT_RANGE_SIZE=${WEBWORDS_PORT_RANGE_SIZE:-8000}
STARTUP_WAIT=${WEBWORDS_STARTUP_WAIT:-5}

# Generate unique port for each implementation
generate_unique_port() {
    local base_port=$(($PORT_RANGE_START + $1))
    echo $base_port
}

# Test single implementation with assigned port
test_implementation() {
    local image=$1
    local port=$2
    local lang=$(echo $image | sed 's/webwords-//')
    local result_file="$BUILD_DIR/result_$lang.tmp"
    
    echo "Testing $lang on port $port..." > $result_file
    
    # Start container with assigned port
    local container_id=$(docker run -d -p $port:31337 --name "test-$lang-$port" $image 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "✗ $lang - Failed to start container" >> $result_file
        echo "BROKEN" > "$result_file.status"
        echo "$lang - container start failed" > "$result_file.broken"
        return 1
    fi
    
    # Wait for startup
    sleep $STARTUP_WAIT
    
    # Test positive case (potato should return true)
    local potato_result=$(curl -s --max-time 10 "http://localhost:$port/?keyword=potato&target=https://www.remarkbox.com" 2>/dev/null || echo "ERROR")
    
    # Test negative case (lemon should return false)  
    local lemon_result=$(curl -s --max-time 10 "http://localhost:$port/?keyword=lemon&target=https://www.remarkbox.com" 2>/dev/null || echo "ERROR")
    
    # Stop container
    docker stop "test-$lang-$port" >/dev/null 2>&1
    docker rm "test-$lang-$port" >/dev/null 2>&1
    
    # Evaluate results
    if [ "$potato_result" = "true" ] && [ "$lemon_result" = "false" ]; then
        echo "✓ $lang - Working correctly (potato: '$potato_result', lemon: '$lemon_result')" >> $result_file
        echo "WORKING" > "$result_file.status"
        echo "$lang" > "$result_file.working"
    else
        echo "✗ $lang - Broken (potato: '$potato_result', lemon: '$lemon_result')" >> $result_file
        echo "BROKEN" > "$result_file.status"
        echo "$lang - potato: '$potato_result', lemon: '$lemon_result'" > "$result_file.broken"
    fi
}

echo "Starting concurrent testing with $CPU_CORES concurrent jobs..." | tee -a $LOG_FILE

# Track running jobs and current image index
running_jobs=0
current_image=0

# Main testing loop - run CPU_CORES jobs concurrently
while [ $current_image -lt $TOTAL_IMAGES ] || [ $running_jobs -gt 0 ]; do
    # Start new jobs up to CPU_CORES limit
    while [ $running_jobs -lt $CPU_CORES ] && [ $current_image -lt $TOTAL_IMAGES ]; do
        image=${IMAGES_ARRAY[$current_image]}
        port=$(generate_unique_port $current_image)
        lang=$(echo $image | sed 's/webwords-//')
        
        echo "  Starting $lang test on port $port..." | tee -a $LOG_FILE
        
        # Start test in background
        test_implementation $image $port &
        
        running_jobs=$((running_jobs + 1))
        current_image=$((current_image + 1))
    done
    
    # Wait for any job to complete
    if [ $running_jobs -gt 0 ]; then
        wait -n  # Wait for any background job to finish
        running_jobs=$((running_jobs - 1))
    fi
done

echo "All tests completed. Collecting results..." | tee -a $LOG_FILE

# Collect results from temporary files
for result_file in $BUILD_DIR/result_*.tmp; do
    if [ -f "$result_file" ]; then
        lang=$(basename "$result_file" .tmp | sed 's/result_//')
        cat "$result_file" >> $LOG_FILE
        
        if [ -f "$result_file.status" ]; then
            if grep -q "WORKING" "$result_file.status"; then
                if [ -f "$result_file.working" ]; then
                    cat "$result_file.working" >> $WORKING_FILE
                fi
            elif grep -q "BROKEN" "$result_file.status"; then
                if [ -f "$result_file.broken" ]; then
                    cat "$result_file.broken" >> $BROKEN_FILE
                fi
            fi
        fi
        
        # Clean up temporary files
        rm -f "$result_file" "$result_file.status" "$result_file.working" "$result_file.broken"
    fi
done

# Count results
WORKING_COUNT=$(wc -l < $WORKING_FILE 2>/dev/null || echo 0)
BROKEN_COUNT=$(wc -l < $BROKEN_FILE 2>/dev/null || echo 0)
TOTAL_TESTED=$((WORKING_COUNT + BROKEN_COUNT))

echo | tee -a $LOG_FILE
echo "Results Summary:" | tee -a $LOG_FILE
echo "===============" | tee -a $LOG_FILE
echo "Total tested: $TOTAL_TESTED" | tee -a $LOG_FILE
echo "Working: $WORKING_COUNT" | tee -a $LOG_FILE
echo "Broken: $BROKEN_COUNT" | tee -a $LOG_FILE

if [ $TOTAL_TESTED -gt 0 ]; then
    SUCCESS_RATE=$(( WORKING_COUNT * 100 / TOTAL_TESTED ))
    echo "Success rate: $SUCCESS_RATE%" | tee -a $LOG_FILE
fi

echo | tee -a $LOG_FILE
echo "✓ Working implementations:" | tee -a $LOG_FILE
if [ -f "$WORKING_FILE" ] && [ -s "$WORKING_FILE" ]; then
    while IFS= read -r impl; do
        echo "  $impl" | tee -a $LOG_FILE
    done < "$WORKING_FILE"
else
    echo "  None" | tee -a $LOG_FILE
fi

echo | tee -a $LOG_FILE
echo "✗ Broken implementations:" | tee -a $LOG_FILE
if [ -f "$BROKEN_FILE" ] && [ -s "$BROKEN_FILE" ]; then
    while IFS= read -r impl; do
        echo "  $impl" | tee -a $LOG_FILE
    done < "$BROKEN_FILE"
else
    echo "  None" | tee -a $LOG_FILE
fi

echo | tee -a $LOG_FILE
if [ $TOTAL_TESTED -gt 0 ]; then
    echo "Final result: $WORKING_COUNT/$TOTAL_TESTED implementations working ($SUCCESS_RATE%)" | tee -a $LOG_FILE
else
    echo "No implementations found to test!" | tee -a $LOG_FILE
fi
echo "Detailed results in: $WORKING_FILE and $BROKEN_FILE" | tee -a $LOG_FILE
echo | tee -a $LOG_FILE
echo "Configuration used:" | tee -a $LOG_FILE
echo "  Concurrent jobs: $CPU_CORES" | tee -a $LOG_FILE
echo "  Port range: $PORT_RANGE_START-$(($PORT_RANGE_START + $TOTAL_IMAGES - 1))" | tee -a $LOG_FILE
echo "  Startup wait: ${STARTUP_WAIT}s" | tee -a $LOG_FILE