#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <build_semver> <binary_directory> <output_directory>"
    exit 1
fi

# Assign the arguments to variables
build_semver="$1"
binary_dir="$2"
output_dir="$3"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Create a checksums file
checksums_file="$output_dir/${build_semver}_checksums.txt"
touch "$checksums_file"

# Define a lock file for parallel-safe writing to checksums
checksums_lockfile="${checksums_file}.lock"

# Iterate over each binary file
for binary_file in "$binary_dir"/*; do
    (
        compressed=""
        if [[ $binary_file == *.exe ]]; then
            # If the file is a Windows binary, zip it
            filename=$(basename "$binary_file")
            compressed="${filename%.exe}.zip"
            zip -j "$output_dir/$compressed" "$binary_file"
        else
            # For other binaries, tar and gzip them
            filename=$(basename "$binary_file")
            compressed="${filename}.tar.gz"
            tar -czf "$output_dir/$compressed" "$binary_file"
        fi

        # Compute checksum and append it to the checksums file using a lock
        checksum="$(shasum -a 256 "$output_dir/$compressed" | awk '{print $1}')"
        (
            flock -x 200
            echo "$checksum $compressed" >> "$checksums_file"
        ) 200>"$checksums_lockfile"

    ) &
done

# Echo message indicating background tasks are running
echo "All zip and tar processes started. Waiting for them to finish..."

# Wait for all background processes to complete
wait

echo "All compression and checksum operations completed."
