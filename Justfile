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

# Discover the best available iPhone simulator at runtime.
# Mirrors the logic in .github/workflows/ci.yml so local and CI always pick
# their own best simulator without hardcoding a device name that may not exist.
sim := `xcrun simctl list devices available --json | python3 -c "
import json, sys
devs = json.load(sys.stdin)['devices']
iphones = sorted(
    [(rt, d) for rt, ds in devs.items()
     for d in ds if d['isAvailable'] and 'iPhone' in d['name']],
    key=lambda x: (x[0], x[1]['name']),
    reverse=True,
)
if not iphones:
    sys.exit('No available iPhone simulator found')
print('platform=iOS Simulator,id=' + iphones[0][1]['udid'])
"`

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
