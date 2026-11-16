# Chroma Audio Suite - One-Line Zero-EXE Installer & Updater
# Hosted at: https://raw.githubusercontent.com/haidood/chroma-release/main/update.ps1
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoRawBase = 'https://raw.githubusercontent.com/haidood/chroma-release/main/precompiled'
$CacheBust = [int][double]::Parse((Get-Date -UFormat %s))

Write-Host ''
Write-Host '================================================================' -ForegroundColor Cyan
Write-Host '  CHROMA AUDIO SUITE // ZERO-EXE INSTALLER & UPDATER (ALL 15)' -ForegroundColor Cyan
Write-Host '================================================================' -ForegroundColor Cyan

# Check if running as Administrator; self-elevate if needed for C:\Program Files access
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin -and -not $env:CHROMA_TARGET_OVERRIDE) {
    Write-Host '[*] Requesting Administrator permission for Program Files access...' -ForegroundColor Yellow
    $cmd = "irm https://raw.githubusercontent.com/haidood/chroma-release/main/update.ps1 | iex"
    Start-Process powershell -Verb RunAs -ArgumentList @('-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $cmd)
    return
}

# Warn if any DAW is open (exact process names so unrelated apps like f.lux don't match)
$daws = @('Ableton Live 10 Suite', 'Ableton Live 11 Suite', 'Ableton Live 12 Suite', 'Live', 'FL64', 'FL', 'reaper', 'Bitwig Studio', 'Cubase', 'Studio One')
$runningDaws = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $n = $_.ProcessName
    ($daws | Where-Object { $n -ieq $_ }).Count -gt 0
} | Select-Object -ExpandProperty ProcessName -Unique
if ($runningDaws -and -not $env:CHROMA_TARGET_OVERRIDE) {
    Write-Host "[!] Running DAW detected: $($runningDaws -join ', ')" -ForegroundColor Yellow
    Write-Host '    Close your DAW first so VST files are not locked, then press Enter to continue (or Ctrl+C to cancel)...' -ForegroundColor Yellow
    Read-Host | Out-Null
}

# Read saved folder prefs from %APPDATA%\ChromaAudio\settings.ini
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
    $lines = if (Test-Path $iniPath) { [System.Collections.Generic.List[string]](Get-Content $iniPath) } else { New-Object System.Collections.Generic.List[string] }
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
        if ($secIdx -lt 0) { $lines.Add("[$section]"); $lines.Add("$key=$val") }
        else { $lines.Insert($secIdx + 1, "$key=$val") }
    }
    Set-Content -Path $iniPath -Value $lines -Encoding ASCII
}

$defaultVst2 = Get-IniSetting 'VstDir' 'C:\Program Files\VstPlugins'
$defaultVst3 = Get-IniSetting 'Vst3Dir' 'C:\Program Files\Common Files\VST3'

if ($env:CHROMA_TARGET_OVERRIDE) {
    $vst2Dir = Join-Path $env:CHROMA_TARGET_OVERRIDE 'VST2'
    $vst3Dir = Join-Path $env:CHROMA_TARGET_OVERRIDE 'VST3'
} else {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    Write-Host ''
    Write-Host "Current VST2 folder: $defaultVst2" -ForegroundColor Gray
    Write-Host "Current VST3 folder: $defaultVst3" -ForegroundColor Gray
    $pick = Read-Host 'Press ENTER to install to those folders, or type C to choose custom folders'
    if ($pick -match '^[cC]') {
        $dlg2 = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg2.Description = 'Select your VST2 (.dll) install folder'
        $dlg2.SelectedPath = $defaultVst2
        $vst2Dir = if ($dlg2.ShowDialog() -eq 'OK' -and $dlg2.SelectedPath) { $dlg2.SelectedPath } else { $defaultVst2 }

        $dlg3 = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg3.Description = 'Select your VST3 (.vst3) install folder'
        $dlg3.SelectedPath = $defaultVst3
        $vst3Dir = if ($dlg3.ShowDialog() -eq 'OK' -and $dlg3.SelectedPath) { $dlg3.SelectedPath } else { $defaultVst3 }
    } else {
        $vst2Dir = $defaultVst2
        $vst3Dir = $defaultVst3
    }
    Set-IniSetting 'Updates' 'VstDir' $vst2Dir
    Set-IniSetting 'Updates' 'Vst3Dir' $vst3Dir
}

New-Item -ItemType Directory -Force -Path $vst2Dir | Out-Null
New-Item -ItemType Directory -Force -Path $vst3Dir | Out-Null

# Migrate & clean up legacy C:\Program Files\VstPlugins\Dev folder if present
$legacyDev = 'C:\Program Files\VstPlugins\Dev'
if (-not $env:CHROMA_TARGET_OVERRIDE -and (Test-Path $legacyDev)) {
    Write-Host "[*] Legacy VstPlugins\Dev detected -- moving files out and removing Dev folder..." -ForegroundColor Yellow
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

# Remove legacy duplicate ChromaCorePro
foreach ($d in @($vst2Dir, $vst3Dir)) {
    Remove-Item (Join-Path $d 'ChromaCorePro.*') -Force -ErrorAction SilentlyContinue
}

$plugins = @(
    'ChromaCoreVST', 'ChromaDeep', 'ChromaDelay', 'ChromaScramble', 'ChromaWidener',
    'ChromaVerb', 'ChromaPulse', 'ChromaSlice', 'ChromaComp', 'ChromaTransientShaper',
    'ChromaDesigner', 'ChromaFhaser', 'ChromaVoice', 'ChromaX', 'ChromaMaster'
)
$supportDlls = @('onnxruntime.dll', 'onnxruntime_providers_shared.dll', 'ChromaUpdater.exe')

$wc = New-Object System.Net.WebClient
$total = $plugins.Count
for ($i = 0; $i -lt $total; $i++) {
    $p = $plugins[$i]
    Write-Host ("[{0,2}/{1}] Installing {2}..." -f ($i + 1), $total, $p) -ForegroundColor White
    $wc.DownloadFile("$RepoRawBase/$p.dll?t=$CacheBust", (Join-Path $vst2Dir "$p.dll"))
    $wc.DownloadFile("$RepoRawBase/$p.vst3?t=$CacheBust", (Join-Path $vst3Dir "$p.vst3"))
}
foreach ($sup in $supportDlls) {
    Write-Host "  [+] Runtime / Updater: $sup" -ForegroundColor Gray
    $wc.DownloadFile("$RepoRawBase/$sup?t=$CacheBust", (Join-Path $vst2Dir $sup))
}

Write-Host ''
Write-Host '================================================================' -ForegroundColor Green
Write-Host '  [SUCCESS] All 15 Chroma Audio Suite plugins updated cleanly!' -ForegroundColor Green
Write-Host "  VST2: $vst2Dir" -ForegroundColor Green
Write-Host "  VST3: $vst3Dir" -ForegroundColor Green
Write-Host '  Tip: If Ableton points to ...\VstPlugins\Dev, switch it to your VST2 folder above & Rescan.' -ForegroundColor Gray
Write-Host '================================================================' -ForegroundColor Green
