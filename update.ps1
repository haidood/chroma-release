# Chroma Audio Suite - One-Line Cross-Legacy CI/CD App Slug
# Hosted at: https://raw.githubusercontent.com/haidood/chroma-release/main/update.ps1
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoRootRaw = 'https://raw.githubusercontent.com/haidood/chroma-release/main'
$RepoRawBase = "$RepoRootRaw/precompiled"
$CacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

Write-Host ''
Write-Host '================================================================' -ForegroundColor Cyan
Write-Host '  CHROMA AUDIO SUITE // CI/CD AUTO-DISCOVERY & UPDATER (ALL 15)' -ForegroundColor Cyan
Write-Host '================================================================' -ForegroundColor Cyan

# Self-elevate with TLS 1.2 so Program Files VST2/VST3 folders are writable
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin -and -not $env:CHROMA_TARGET_OVERRIDE) {
    Write-Host '[*] Requesting Administrator permission for VST folder access...' -ForegroundColor Yellow
    $cmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm $RepoRootRaw/update.ps1?t=$CacheBust | iex"
    Start-Process powershell -Verb RunAs -ArgumentList @('-STA', '-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $cmd)
    return
}

# Warn if a DAW holds plugin DLLs open
$daws = @('Ableton Live 10 Suite', 'Ableton Live 11 Suite', 'Ableton Live 12 Suite', 'Live', 'FL64', 'FL', 'reaper', 'Bitwig Studio', 'Cubase', 'Studio One')
$runningDaws = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $n = $_.ProcessName
    ($daws | Where-Object { $n -ieq $_ }).Count -gt 0
} | Select-Object -ExpandProperty ProcessName -Unique
if ($runningDaws -and -not $env:CHROMA_TARGET_OVERRIDE) {
    Write-Host "[!] Running DAW detected: $($runningDaws -join ', ')" -ForegroundColor Yellow
    Write-Host '    Close your DAW first so VST files are not locked, then press Enter to continue...' -ForegroundColor Yellow
    Read-Host | Out-Null
}

# Settings helpers (%APPDATA%\ChromaAudio\settings.ini)
$chromaAppDir = Join-Path $env:APPDATA 'ChromaAudio'
New-Item -ItemType Directory -Force -Path $chromaAppDir | Out-Null
$iniPath = Join-Path $chromaAppDir 'settings.ini'

function Get-IniSetting([string]$key, [string]$defaultVal) {
    if (Test-Path $iniPath) {
        foreach ($line in Get-Content $iniPath -ErrorAction SilentlyContinue) {
            if ($line -match "^\s*$key\s*=\s*(.+)$") {
                $val = $matches[1].Trim().TrimEnd('\','/')
                if ($val -like '*\Dev') { $val = $val.Substring(0, $val.Length - 4) }
                if ($val) { return $val }
            }
        }
    }
    return $defaultVal
}

function Set-IniSetting([string]$section, [string]$key, [string]$val) {
    $lines = New-Object 'System.Collections.Generic.List[string]'
    if (Test-Path $iniPath) {
        foreach ($rawLine in @(Get-Content $iniPath -ErrorAction SilentlyContinue)) {
            if ($null -ne $rawLine) { [void]$lines.Add([string]$rawLine) }
        }
    }
    $inSec = $false; $secIdx = -1; $found = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $t = $lines[$i].Trim()
        if ($t -match '^\[(.+)\]$') {
            $inSec = ($matches[1] -ieq $section)
            if ($inSec) { $secIdx = $i }
        } elseif ($inSec -and $t -match "^\s*$key\s*=") {
            $lines[$i] = "$key=$val"
            $found = $true
            break
        }
    }
    if (-not $found) {
        if ($secIdx -lt 0) {
            [void]$lines.Add("[$section]")
            [void]$lines.Add("$key=$val")
        } else {
            $lines.Insert($secIdx + 1, "$key=$val")
        }
    }
    Set-Content -Path $iniPath -Value $lines.ToArray() -Encoding ASCII
}

# 1. Fetch live CI/CD manifest to inspect versions and know what the user needs
$wc = New-Object System.Net.WebClient
$manifest = $null
try {
    $manifestJson = $wc.DownloadString("$RepoRootRaw/version_manifest.json?t=$CacheBust")
    $manifest = $manifestJson | ConvertFrom-Json
    Write-Host "[CI/CD] Connected: Chroma Audio Suite v$($manifest.suite_version)" -ForegroundColor Green
} catch {
    Write-Host '[!] Could not read version_manifest.json (continuing with direct precompiled sync)...' -ForegroundColor Yellow
}

# 2. Scan system for saved/common/super-legacy VST2 & VST3 locations
$savedVst2 = Get-IniSetting 'VstDir' ''
$savedVst3 = Get-IniSetting 'Vst3Dir' ''

$probeVst2 = @($savedVst2, 'C:\Program Files\VstPlugins', 'C:\Program Files\Steinberg\VstPlugins', 'C:\Program Files\Common Files\VST2') | Where-Object { $_ } | Select-Object -Unique
$detectedVst2 = ''
foreach ($cand in $probeVst2) {
    if ((Test-Path $cand) -and ((Get-ChildItem $cand -Filter 'Chroma*.dll' -ErrorAction SilentlyContinue).Count -gt 0)) {
        $detectedVst2 = $cand
        break
    }
}
$defaultVst2 = if ($savedVst2) { $savedVst2 } elseif ($detectedVst2) { $detectedVst2 } else { 'C:\Program Files\VstPlugins' }
$defaultVst3 = if ($savedVst3) { $savedVst3 } else { 'C:\Program Files\Common Files\VST3' }

$plugins = @(
    @{ bin='ChromaCoreVST';        key='ChromaCore' },
    @{ bin='ChromaDeep';           key='ChromaDeep' },
    @{ bin='ChromaDelay';          key='ChromaDelay' },
    @{ bin='ChromaScramble';       key='ChromaScramble' },
    @{ bin='ChromaWidener';        key='ChromaWidener' },
    @{ bin='ChromaVerb';           key='ChromaVerb' },
    @{ bin='ChromaPulse';          key='ChromaPulse' },
    @{ bin='ChromaSlice';          key='ChromaSlice' },
    @{ bin='ChromaComp';           key='ChromaComp' },
    @{ bin='ChromaTransientShaper';key='ChromaTransientShaper' },
    @{ bin='ChromaDesigner';       key='ChromaDesigner' },
    @{ bin='ChromaFhaser';         key='ChromaFhaser' },
    @{ bin='ChromaVoice';          key='ChromaVoice' },
    @{ bin='ChromaX';              key='ChromaX' },
    @{ bin='ChromaMaster';         key='ChromaMaster' }
)

# Check license.dat and legacy folders cleanly
$licPath = Join-Path $chromaAppDir 'Licenses\license.dat'
$legacyDev = 'C:\Program Files\VstPlugins\Dev'
$legacyX64 = Join-Path $defaultVst2 'x64'

if (-not $env:CHROMA_TARGET_OVERRIDE) {
    Write-Host ''
    Write-Host '--- SYSTEM AUDIT & CI/CD CHECK ---' -ForegroundColor Cyan
    Write-Host ("  License file : {0}" -f ($(if (Test-Path $licPath) { "FOUND ($licPath)" } else { "NOT FOUND (enter 30-day key after install)" })))
    if (Test-Path $legacyDev) { Write-Host "  Legacy folder: FOUND $legacyDev (will migrate cleanly)" -ForegroundColor Yellow }
    if (Test-Path (Join-Path $defaultVst2 'ChromaCorePro.dll')) { Write-Host '  Legacy plugin: FOUND ChromaCorePro (will upgrade -> ChromaCoreVST)' -ForegroundColor Yellow }
    if ((Test-Path $legacyX64) -and ((Get-ChildItem $legacyX64 -Filter 'Chroma*.dll' -ErrorAction SilentlyContinue).Count -gt 0)) {
        Write-Host "  Nested dupes : FOUND $legacyX64\Chroma* (will clean stale duplicates)" -ForegroundColor Yellow
    }

    $missingCount = 0
    Write-Host ''
    for ($i = 0; $i -lt $plugins.Count; $i++) {
        $p = $plugins[$i]
        $latestVer = if ($manifest -and $manifest.plugins.($p.key)) { "v$($manifest.plugins.($p.key).version)" } else { 'latest' }
        $hasV2 = Test-Path (Join-Path $defaultVst2 "$($p.bin).dll")
        $hasV3 = Test-Path (Join-Path $defaultVst3 "$($p.bin).vst3")
        $state = if ($hasV2 -and $hasV3) { 'UPDATE READY' } elseif ($hasV2 -or $hasV3) { 'PARTIAL -> SYNC' } else { $missingCount++; 'MISSING -> INSTALL' }
        $col = if ($hasV2 -and $hasV3) { 'Gray' } else { 'Yellow' }
        Write-Host ("  [{0,2}] {1,-22} CI={2,-7} ({3})" -f ($i + 1), $p.bin, $latestVer, $state) -ForegroundColor $col
    }
    Write-Host ''
    Write-Host "  Target VST2 folder : $defaultVst2" -ForegroundColor White
    Write-Host "  Target VST3 folder : $defaultVst3" -ForegroundColor White
    Write-Host ''
    Write-Host 'Options:' -ForegroundColor Cyan
    Write-Host '  [Enter] Install / Update ALL 15 plugins to the folders above'
    Write-Host '  [C]     Change VST2 / VST3 target folders first'
    Write-Host '  [P]     Pick specific plugins (comma numbers, e.g. 1,15)'
    $choice = Read-Host 'Select action [Enter / C / P]'

    $vst2Dir = $defaultVst2
    $vst3Dir = $defaultVst3
    $selectedIndices = 0..($plugins.Count - 1)

    if ($choice -match '[cC]') {
        $canGuiDlg = ([System.Threading.Thread]::CurrentThread.ApartmentState -eq 'STA')
        if ($canGuiDlg) {
            try {
                Add-Type -AssemblyName System.Windows.Forms | Out-Null
                $dlg2 = New-Object System.Windows.Forms.FolderBrowserDialog
                $dlg2.Description = 'Select your VST2 (.dll) install folder'
                $dlg2.SelectedPath = $defaultVst2
                if ($dlg2.ShowDialog() -eq 'OK' -and $dlg2.SelectedPath) { $vst2Dir = $dlg2.SelectedPath }

                $dlg3 = New-Object System.Windows.Forms.FolderBrowserDialog
                $dlg3.Description = 'Select your VST3 (.vst3) install folder'
                $dlg3.SelectedPath = $defaultVst3
                if ($dlg3.ShowDialog() -eq 'OK' -and $dlg3.SelectedPath) { $vst3Dir = $dlg3.SelectedPath }
            } catch {
                $canGuiDlg = $false
            }
        }
        if (-not $canGuiDlg) {
            $in2 = Read-Host "Enter VST2 (.dll) folder [Enter keeps $vst2Dir]"
            if ($in2) { $vst2Dir = $in2.Trim().Trim('"') }
            $in3 = Read-Host "Enter VST3 (.vst3) folder [Enter keeps $vst3Dir]"
            if ($in3) { $vst3Dir = $in3.Trim().Trim('"') }
        }
        Write-Host "  New VST2 folder: $vst2Dir" -ForegroundColor Green
        Write-Host "  New VST3 folder: $vst3Dir" -ForegroundColor Green
    }

    if ($choice -match '[pP]' -or ($choice -match '[cC]' -and (Read-Host 'Install ALL 15 [Enter] or pick specific numbers [P]') -match '^[pP]')) {
        $rawPick = Read-Host 'Enter plugin numbers separated by commas (e.g. 1,9,15)'
        $parsed = @()
        foreach ($tok in ($rawPick -split '[,\s]+')) {
            $num = 0
            if ([int]::TryParse($tok, [ref]$num) -and $num -ge 1 -and $num -le $plugins.Count) {
                $parsed += ($num - 1)
            }
        }
        if ($parsed.Count -gt 0) { $selectedIndices = $parsed | Select-Object -Unique }
    }

    Set-IniSetting 'Updates' 'VstDir' $vst2Dir
    Set-IniSetting 'Updates' 'Vst3Dir' $vst3Dir
} else {
    $vst2Dir = Join-Path $env:CHROMA_TARGET_OVERRIDE 'VST2'
    $vst3Dir = Join-Path $env:CHROMA_TARGET_OVERRIDE 'VST3'
    $selectedIndices = 0..($plugins.Count - 1)
}

New-Item -ItemType Directory -Force -Path $vst2Dir | Out-Null
New-Item -ItemType Directory -Force -Path $vst3Dir | Out-Null

# Migrate & clean up legacy C:\Program Files\VstPlugins\Dev folder if present
if (-not $env:CHROMA_TARGET_OVERRIDE -and (Test-Path $legacyDev)) {
    Write-Host "[*] Legacy VstPlugins\Dev detected -- migrating out and removing Dev folder..." -ForegroundColor Yellow
    Get-ChildItem $legacyDev -File -ErrorAction SilentlyContinue | ForEach-Object {
        $ext = $_.Extension.ToLower()
        if ($ext -eq '.dll') {
            $dst = Join-Path $vst2Dir $_.Name
            if (-not (Test-Path $dst)) { Move-Item $_.FullName $dst -Force -ErrorAction SilentlyContinue }
            else { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
        } elseif ($ext -eq '.vst3') {
            $dst = Join-Path $vst3Dir $_.Name
            if (-not (Test-Path $dst)) { Move-Item $_.FullName $dst -Force -ErrorAction SilentlyContinue }
            else { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
        } else {
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }
    Remove-Item $legacyDev -Recurse -Force -ErrorAction SilentlyContinue
}

# Remove legacy duplicate ChromaCorePro and stale nested x64 copies
$nestedX64 = Join-Path $vst2Dir 'x64'
foreach ($d in @($vst2Dir, $vst3Dir, $nestedX64)) {
    if (Test-Path $d) {
        Remove-Item (Join-Path $d 'ChromaCorePro.*') -Force -ErrorAction SilentlyContinue
    }
}
if (-not $env:CHROMA_TARGET_OVERRIDE -and (Test-Path $nestedX64)) {
    Remove-Item (Join-Path $nestedX64 'Chroma*.dll') -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $nestedX64 'Chroma*.vst3') -Force -ErrorAction SilentlyContinue
}

$supportDlls = @('onnxruntime.dll', 'onnxruntime_providers_shared.dll')
function Download-WithRetry([string]$url, [string]$dest, [bool]$optional = $false) {
    for ($attempt = 1; $attempt -le 2; $attempt++) {
        try {
            $tmp = "$dest.download"
            $wc.DownloadFile($url, $tmp)
            if ((Get-Item $tmp).Length -lt 50000) {
                throw "Downloaded file too small: $dest"
            }
            Move-Item -Force $tmp $dest
            return $true
        } catch {
            Remove-Item "$dest.download" -Force -ErrorAction SilentlyContinue
            if ($attempt -eq 1) { Start-Sleep -Milliseconds 900 }
            elseif (-not $optional) { throw }
        }
    }
    return $false
}

$selTotal = $selectedIndices.Count
for ($idx = 0; $idx -lt $selTotal; $idx++) {
    $p = $plugins[$selectedIndices[$idx]].bin
    Write-Host ("[{0,2}/{1}] Syncing {2} (VST2 + Native VST3 Bundle)..." -f ($idx + 1), $selTotal, $p) -ForegroundColor White
    Download-WithRetry "$RepoRawBase/${p}.dll?t=$CacheBust" (Join-Path $vst2Dir "${p}.dll") $false | Out-Null

    # Install genuine Steinberg VST 3.8 bundle directory (<Plugin>.vst3/Contents/x86_64-win/<Plugin>.vst3 + moduleinfo.json)
    $bundleRoot = Join-Path $vst3Dir "${p}.vst3"
    if (Test-Path -Path $bundleRoot -PathType Leaf) {
        Remove-Item -Path $bundleRoot -Force -ErrorAction SilentlyContinue
    }
    $bundleBinDir = Join-Path $bundleRoot 'Contents\x86_64-win'
    $bundleResDir = Join-Path $bundleRoot 'Contents\Resources'
    New-Item -ItemType Directory -Force -Path $bundleBinDir | Out-Null
    New-Item -ItemType Directory -Force -Path $bundleResDir | Out-Null
    Download-WithRetry "$RepoRawBase/${p}.vst3?t=$CacheBust" (Join-Path $bundleBinDir "${p}.vst3") $false | Out-Null
    try {
        $wc.DownloadFile("$RepoRawBase/vst3_moduleinfo/${p}.moduleinfo.json?t=$CacheBust", (Join-Path $bundleResDir 'moduleinfo.json'))
    } catch { }
}
foreach ($sup in $supportDlls) {
    Write-Host "  [+] Runtime: $sup" -ForegroundColor Gray
    Download-WithRetry "$RepoRawBase/${sup}?t=$CacheBust" (Join-Path $vst2Dir $sup) $true | Out-Null
}

Write-Host ''
Write-Host '================================================================' -ForegroundColor Green
Write-Host "  [SUCCESS] Synced $selTotal plugin(s) cleanly from CI/CD!" -ForegroundColor Green
Write-Host "  VST2: $vst2Dir" -ForegroundColor Green
Write-Host "  VST3: $vst3Dir" -ForegroundColor Green
Write-Host '  Presets & License preserved in %APPDATA%\ChromaAudio.' -ForegroundColor Gray
Write-Host '================================================================' -ForegroundColor Green
