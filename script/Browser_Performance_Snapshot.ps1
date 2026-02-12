# Browser Performance Mini-Lab Snapshot Script
# Captures: system baseline, per-process stats, aggregated totals
# Saves: TXT + CSV outputs to Desktop (works even if Desktop is OneDrive redirected)

$ErrorActionPreference = "Stop"

# Target browsers (process names)
$targets = @("chrome","msedge")

# Output folder on Desktop
$desktop = [Environment]::GetFolderPath("Desktop")
$stamp   = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outDir  = Join-Path $desktop "BrowserPerfLab_$stamp"
New-Item -ItemType Directory -Path $outDir | Out-Null

# 1) System baseline
$baseline = Get-ComputerInfo |
  Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, CsTotalPhysicalMemory

$baselineTxt = @"
=== System Baseline ===
WindowsProductName    : $($baseline.WindowsProductName)
WindowsVersion        : $($baseline.WindowsVersion)
OsBuildNumber         : $($baseline.OsBuildNumber)
CsTotalPhysicalMemory : $($baseline.CsTotalPhysicalMemory)
Timestamp             : $(Get-Date)
"@

$baselineTxt | Out-File (Join-Path $outDir "01_SystemBaseline.txt") -Encoding utf8

# 2) Per-process capture (RAM in MB)
$procs = Get-Process -Name $targets -ErrorAction SilentlyContinue |
  Select-Object ProcessName, Id,
    @{Name="RAM_MB";Expression={[math]::Round($_.WorkingSet/1MB,2)}},
    CPU, StartTime -ErrorAction SilentlyContinue |
  Sort-Object RAM_MB -Descending

if (-not $procs) {
  "No target processes found. Open Chrome and/or Edge and rerun." |
    Out-File (Join-Path $outDir "02_PerProcess.txt") -Encoding utf8
  Write-Host "No processes found. Saved note to $outDir"
  return
}

$procs | Format-Table -AutoSize |
  Out-String | Out-File (Join-Path $outDir "02_PerProcess.txt") -Encoding utf8

$procs | Export-Csv (Join-Path $outDir "02_PerProcess.csv") -NoTypeInformation -Encoding utf8

# 3) Aggregated totals by browser
$totals = $procs |
  Group-Object ProcessName |
  ForEach-Object {
    $ramSum = ($_.Group | Measure-Object RAM_MB -Sum).Sum
    $cpuSum = ($_.Group | Measure-Object CPU    -Sum).Sum
    [pscustomobject]@{
      Browser     = $_.Name
      ProcCount   = $_.Count
      TotalCPU    = [math]::Round($cpuSum, 2)
      TotalRAM_MB = [math]::Round($ramSum, 2)
    }
  } | Sort-Object TotalRAM_MB -Descending

# Calculate % of RAM for each browser (using baseline bytes)
$ramTotalMB = [math]::Round($baseline.CsTotalPhysicalMemory / 1MB, 2)

$totalsWithPct = $totals | ForEach-Object {
  [pscustomobject]@{
    Browser       = $_.Browser
    ProcCount     = $_.ProcCount
    TotalCPU      = $_.TotalCPU
    TotalRAM_MB   = $_.TotalRAM_MB
    RAM_PctOfSys  = [math]::Round(($_.TotalRAM_MB / $ramTotalMB) * 100, 2)
  }
}

$totalsWithPct | Format-Table -AutoSize |
  Out-String | Out-File (Join-Path $outDir "03_TotalsByBrowser.txt") -Encoding utf8

$totalsWithPct | Export-Csv (Join-Path $outDir "03_TotalsByBrowser.csv") -NoTypeInformation -Encoding utf8

# 4) Simple “headline” summary
$summary = @()
$summary += "=== Headline Summary ==="
$summary += "Output Folder: $outDir"
$summary += "System RAM (MB): $ramTotalMB"
$summary += ""
$summary += ($totalsWithPct | Format-Table -AutoSize | Out-String)

$summary -join "`r`n" | Out-File (Join-Path $outDir "00_Summary.txt") -Encoding utf8

Write-Host "Saved all artifacts to: $outDir"
Write-Host "Files: 00_Summary.txt, 01_SystemBaseline.txt, 02_PerProcess.txt/.csv, 03_TotalsByBrowser.txt/.csv"
