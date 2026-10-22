param(
    [string]$BackupPath,
    [string]$AdbPath = (Join-Path $PSScriptRoot '../../../_tools/android/platform-tools/adb.exe')
)

$ErrorActionPreference = 'Stop'
if (-not $BackupPath) { $BackupPath = (Read-Host 'Backup folder').Trim('"') }
$state = Get-Content -LiteralPath (Join-Path $BackupPath 'restore-state.json') -Raw | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $AdbPath)) { $AdbPath = (Get-Command adb -ErrorAction Stop).Source }

function Invoke-TvAdb {
    param([string[]]$Arguments)
    $result = & $AdbPath -s $state.serial @Arguments
    if ($LASTEXITCODE -ne 0) { throw "ADB failed: $($Arguments -join ' ')" }
    $result
}

Write-Host "TV: $($state.model) at $($state.serial)"
Write-Host "Restore Home: $($state.home)"
Write-Host 'No app is uninstalled and no app data is cleared.'
if ((Read-Host 'Continue? [y/N]') -notmatch '^(y|yes)$') { return }
& $AdbPath connect $state.serial
if ($LASTEXITCODE -ne 0) { throw 'Cannot connect to TV. Enable debugging and authorize this computer.' }
$operations = @{ 0 = 'default-state'; 1 = 'enable'; 2 = 'disable'; 3 = 'disable-user'; 4 = 'disable-until-used' }
foreach ($package in $state.packages) {
    if ($state.changedPackages -contains $package.name) {
        $operation = $operations[[int]$package.enabled]
        if (-not $operation) { throw "Unknown package state: $($package.enabled)" }
        Invoke-TvAdb @('shell', "pm $operation --user $($state.user) $($package.name)")
    }
}
Invoke-TvAdb @('shell', "cmd package set-home-activity --user $($state.user) $($state.home)")
Invoke-TvAdb @('shell', 'input keyevent KEYCODE_HOME')
Invoke-TvAdb @('shell', 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME')
