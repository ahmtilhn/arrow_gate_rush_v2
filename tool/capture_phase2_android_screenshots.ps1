param([switch]$Force)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'docs/visual_qa/phase2/runtime_android'
$package = 'com.example.arrow_gate_rush_v2'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'flutter was not found in PATH.'
}
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
  throw 'adb was not found in PATH.'
}
$device = (adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "`tdevice$" } | Select-Object -First 1)
if (-not $device) {
  throw 'No Android emulator or device is connected.'
}
$serial = ($device -split "`t")[0]
New-Item -ItemType Directory -Path $out -Force | Out-Null

$states = @(
  @('loading','01_loading.png',900),
  @('prototypeGameplay','02_prototype_gameplay.png',2600),
  @('validAlignment','03_valid_alignment.png',850),
  @('blockedPath','04_blocked_path.png',650),
  @('wrongColorGate','05_wrong_color_gate.png',650),
  @('noGateAligned','06_no_gate_aligned.png',650),
  @('lockedGate','07_locked_gate.png',650),
  @('gateRotating','08_gate_rotating.png',430),
  @('bufferedTap','09_buffered_tap.png',650),
  @('pauseOverlay','10_pause_overlay.png',750),
  @('levelComplete','11_level_complete.png',1400),
  @('levelFailed','12_level_failed.png',750),
  @('visualDebugLevel','13_visual_debug_level.png',1100)
)

Push-Location $root
try {
  flutter pub get
  foreach ($item in $states) {
    $mode = $item[0]
    $name = $item[1]
    $wait = [int]$item[2]
    flutter build apk --debug "--dart-define=VISUAL_REVIEW_MODE=$mode"
    if ($LASTEXITCODE -ne 0) { throw "Build failed for $mode" }
    adb -s $serial install -r 'build/app/outputs/flutter-apk/app-debug.apk' | Out-Null
    adb -s $serial shell am force-stop $package
    adb -s $serial shell am start -W -n "$package/.MainActivity" | Out-Null
    Start-Sleep -Milliseconds $wait
    $remote = "/sdcard/$name"
    $local = Join-Path $out $name
    if ((Test-Path $local) -and -not $Force) { throw "File already exists: $local" }
    adb -s $serial shell screencap -p $remote
    adb -s $serial pull $remote $local | Out-Null
    adb -s $serial shell rm -f $remote
    if (-not (Test-Path $local) -or (Get-Item $local).Length -le 24) {
      throw "Invalid runtime capture: $local"
    }
  }
} finally {
  Pop-Location
}
