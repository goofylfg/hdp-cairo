#!/bin/bash

run_tests() {
    local cairo_file="$1"
    local filename=$(basename "$cairo_file" .cairo)
    local temp_output=$(mktemp)

    echo "Running tests for $cairo_file..."

    # Redirecting output to temp file for potential error capture
    cairo-compile --cairo_path="packages/eth_essentials" "$cairo_file" --output "build/compiled_cairo_files/$filename.json" > "$temp_output" 2>&1
    cairo-run --program="build/compiled_cairo_files/$filename.json" --layout=starknet_with_keccak >> "$temp_output" 2>&1
    local status=$?

    if [ $status -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Test Successful: $cairo_file"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Test Failed: $cairo_file"
        cat "$temp_output" # Display the captured output on failure
        rm -f "$temp_output"
        return $status
    fi

    rm -f "$temp_output"
}

# Activate the virtual environment
source venv/bin/activate

# Export the function so it's available in subshells
export -f run_tests

# Find all .cairo files under tests/cairo_programs directory and run tests in parallel
# Excluding 'test_vectors.cairo' and './src/cairo1/*' files
echo "Finding and running tests..."
find ./tests/cairo_programs -name '*.cairo' ! -name 'test_vectors.cairo' ! -path "./src/cairo1/*" | parallel --halt soon,fail=1 run_tests

# Capture the exit status of parallel
exit_status=$?

# Exit with the captured status
echo "Parallel execution exited with status: $exit_status"
exit $exit_status
