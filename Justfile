# SwiftIntro — task runner (https://github.com/casey/just)
#
# Prerequisites:
#   brew install just xcpretty
#   CI only: brew install xcresultparser  (converts xcresult → Cobertura for Codecov)

set shell := ["zsh", "-cu"]

project    := "SwiftIntro.xcodeproj"
scheme     := "SwiftIntro"
# Override on the command line: just device="iPhone 16" test
device     := "iPhone 17"
sim        := "platform=iOS Simulator,name=" + device + ",OS=latest"
result_dir := ".build"
result     := result_dir + "/TestResults.xcresult"
cov_json   := result_dir + "/coverage.json"

# ── Default ───────────────────────────────────────────────────────────────────

# List available recipes
default:
    @just --list

# ── Testing ───────────────────────────────────────────────────────────────────

# Build and run the unit test suite
test:
    xcodebuild test \
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
    xcodebuild test \
        -project {{project}} \
        -scheme {{scheme}} \
        -destination '{{sim}}' \
        -only-testing:SwiftIntroTests \
        -enableCodeCoverage YES \
        -resultBundlePath {{result}} \
        ENABLE_USER_SCRIPT_SANDBOXING=NO \
        | xcpretty
    @xcrun xccov view --report --json {{result}} > {{cov_json}}
