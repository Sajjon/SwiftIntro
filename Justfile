# SwiftIntro — task runner (https://github.com/casey/just)
#
# Prerequisites:
#   brew install just xcpretty
#   CI only: brew install xcresultparser  (converts xcresult → Cobertura for Codecov)

set shell := ["zsh", "-cu"]

project    := "SwiftIntro.xcodeproj"
scheme     := "SwiftIntro"
result_dir := ".build"
result     := result_dir + "/TestResults.xcresult"
cov_json   := result_dir + "/coverage.json"
sim_device := env_var_or_default("SIM_DEVICE", "iPhone 17")
sim_os     := env_var_or_default("SIM_OS", "26.1")

# Keep in sync with .github/workflows/ci.yml to ensure local and CI use
# the same Apple Silicon simulator destination.
sim := "platform=iOS Simulator,name=" + sim_device + ",OS=" + sim_os + ",arch=arm64"

# ── Default ───────────────────────────────────────────────────────────────────

# List available recipes
default:
    @just --list

# ── Testing ───────────────────────────────────────────────────────────────────

# Build and run the unit test suite
test:
    set -o pipefail && xcodebuild test \
        -project {{project}} \
        -scheme {{scheme}} \
        -destination '{{sim}}' \
        -only-testing:SwiftIntroTests \
        ENABLE_USER_SCRIPT_SANDBOXING=NO \
        | xcpretty

# Run tests, then print a pretty per-file coverage table.
# Produces .build/coverage.json for machine use (no extra tools required).
cov: _run-cov
    @python3 scripts/cov_table.py {{cov_json}}

# Like cov, but also shows every uncovered line highlighted red.
cov-detailed: _run-cov
    @python3 scripts/cov_detailed.py {{result}} {{cov_json}}

# ── Internal ──────────────────────────────────────────────────────────────────

# Run xcodebuild with coverage enabled and write the result bundle + JSON.
_run-cov:
    rm -rf {{result}}
    mkdir -p {{result_dir}}
    set -o pipefail && xcodebuild test \
        -project {{project}} \
        -scheme {{scheme}} \
        -destination '{{sim}}' \
        -only-testing:SwiftIntroTests \
        -enableCodeCoverage YES \
        -resultBundlePath {{result}} \
        ENABLE_USER_SCRIPT_SANDBOXING=NO \
        | xcpretty
    @xcrun xccov view --report --json {{result}} > {{cov_json}}
