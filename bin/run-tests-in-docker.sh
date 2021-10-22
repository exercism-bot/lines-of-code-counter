#! /bin/bash -e

# Synopsis:
# Test the lines of code counter Docker image by running it against a predefined set of 
# submissions with an expected output.
# The Docker image is built automatically.

# Arguments:
# $1: track slug (optional)
# $2: submission slug (optional)

# Output:
# Outputs the diff of the expected counts against the actual counts
# generated by the lines of code counter Docker image.

# Example:
# ./bin/run-tests-in-docker.sh

# Example running tests of a single track:
# ./bin/run-tests-in-docker.sh csharp

# Example running tests of a single track and a single submission slug:
# ./bin/run-tests-in-docker.sh csharp single-file

shopt -s extglob

track_slug="${1:-*}"
submission_slug="${2:-*}"

exit_code=0

# Iterate over all test directories
for test_dir in tests/${track_slug}/${submission_slug}; do
    track_name=$(basename $(realpath "${test_dir}/../"))
    submission_name=$(basename "${test_dir}")
    test_dir_path=$(realpath "${test_dir}")
    response_file_path="${test_dir_path}/response.json"
    expected_response_file_path="${test_dir_path}/expected_response.json"

    rm -rf "${response_file_path}"

    bin/run-in-docker.sh "${track_name}" "${test_dir_path}"

    # Ensure there is a trailing newline in both files
    sed -i -e '$a\' "${response_file_path}"
    sed -i -e '$a\' "${expected_response_file_path}"

    echo "${track_name}/${submission_name}: comparing response.json to expected_response.json"
    diff "${response_file_path}" "${expected_response_file_path}"

    if [ $? -ne 0 ]; then
        exit_code=1
    fi
done

exit ${exit_code}
