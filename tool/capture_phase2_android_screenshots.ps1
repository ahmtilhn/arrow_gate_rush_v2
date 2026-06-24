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
$connected = @(adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "`tdevice$" })
if ($connected.Count -eq 0) {
  throw 'No Android emulator or device is connected.'
}
if ($connected.Count -gt 1) {
  throw 'Connect exactly one Android device for deterministic capture.'
}
$serial = ($connected[0] -split "`t")[0]
$model = ((adb -s $serial shell getprop ro.product.model) -join '').Trim()
$resolution = ((adb -s $serial shell wm size) -join ' ').Trim()
New-Item -ItemType Directory -Path $out -Force | Out-Null

$states = @(
  @{ mode='loading'; file='01_loading.png'; wait=900; state='loadingAssets'; expected=@('logo','loading indicator') },
  @{ mode='prototypeGameplay'; file='02_prototype_gameplay.png'; wait=2600; state='ready'; expected=@('garden background','stone board','arrows','four gate lanes','HUD') },
  @{ mode='validAlignment'; file='03_valid_alignment.png'; wait=850; state='ready'; expected=@('aligned arrow highlight','matching gate glow') },
  @{ mode='blockedPath'; file='04_blocked_path.png'; wait=650; state='ready'; expected=@('blocked arrow feedback','blocking cell feedback','life loss') },
  @{ mode='wrongColorGate'; file='05_wrong_color_gate.png'; wait=650; state='ready'; expected=@('wrong-color aligned gate','wrong-tap feedback') },
  @{ mode='noGateAligned'; file='06_no_gate_aligned.png'; wait=650; state='ready'; expected=@('empty aligned slot','wrong-tap feedback') },
  @{ mode='lockedGate'; file='07_locked_gate.png'; wait=650; state='ready'; expected=@('locked matching gate','wrong-tap feedback') },
  @{ mode='gateRotating'; file='08_gate_rotating.png'; wait=430; state='gate visual movement'; expected=@('gates between committed slots') },
  @{ mode='bufferedTap'; file='09_buffered_tap.png'; wait=650; state='buffered timing feedback'; expected=@('queued arrow highlight','target glow') },
  @{ mode='pauseOverlay'; file='10_pause_overlay.png'; wait=750; state='paused'; expected=@('pause overlay','frozen board') },
  @{ mode='levelComplete'; file='11_level_complete.png'; wait=1400; state='levelComplete'; expected=@('completion overlay') },
  @{ mode='levelFailed'; file='12_level_failed.png'; wait=750; state='levelFailed'; expected=@('failure overlay','zero lives') },
  @{ mode='visualDebugLevel'; file='13_visual_debug_level.png'; wait=1100; state='debug fixture'; expected=@('locked gate','obstacles','debug telemetry') }
)

Push-Location $root
try {
  flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }
  $manifest = @()
  foreach ($item in $states) {
    $mode = $item.mode
    $name = $item.file
    flutter build apk --debug "--dart-define=VISUAL_REVIEW_MODE=$mode"
    if ($LASTEXITCODE -ne 0) { throw "Build failed for $mode" }
    adb -s $serial install -r 'build/app/outputs/flutter-apk/app-debug.apk' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Install failed for $mode" }
    adb -s $serial shell am force-stop $package
    adb -s $serial shell am start -W -n "$package/.MainActivity" | Out-Null
    Start-Sleep -Milliseconds ([int]$item.wait)
    $remote = "/sdcard/$name"
    $local = Join-Path $out $name
    if ((Test-Path $local) -and -not $Force) { throw "File already exists: $local" }
    adb -s $serial shell screencap -p $remote
    adb -s $serial pull $remote $local | Out-Null
    adb -s $serial shell rm -f $remote
    if (-not (Test-Path $local) -or (Get-Item $local).Length -le 24) {
      throw "Invalid runtime capture: $local"
    }
    $manifest += [ordered]@{
      filename = $name
      captureMethod = 'adb shell screencap -p followed by adb pull'
      platform = 'Android'
      deviceSerial = $serial
      deviceModel = $model
      screenResolution = $resolution
      appPackageId = $package
      buildMode = 'debug'
      captureTimestampUtc = [DateTime]::UtcNow.ToString('o')
      gameState = $item.state
      levelId = if ($mode -eq 'levelComplete') { 'phase2_qa_completion' } else { 'phase2_prototype' }
      expectedVisibleComponents = $item.expected
      assetGeneratedPreview = $false
    }
  }
  $manifest | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $out 'capture_manifest.json') -Encoding UTF8
  Write-Host "Captured $($states.Count) live Android frames in $out"
} finally {
  Pop-Location
}
