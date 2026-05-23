# ============================================================================
# File: Deploy-RegistryHardening.ps1
# Description: Applies Windows hardening registry settings from a JSON file.
# ============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Path to the JSON configuration file.")]
    [ValidateNotNullOrEmpty()]
    [string]$JsonConfigPath,

    [Parameter(Mandatory = $true, HelpMessage = "The hardening level to apply (e.g., Level1, Level2, Level3).")]
    [ValidateSet('Level1', 'Level2', 'Level3')]
    [string]$TargetLevel,

    [Parameter(Mandatory = $false, HelpMessage = "If set, the script will only output what would be changed without applying it.")]
    [switch]$DryRun
)

# ----------------------------------------------------------------------------
# Helper Function: Set-RegistryKey
# ----------------------------------------------------------------------------
function Set-RegistryKey {
    param (
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type,
        [string]$Description,
        [switch]$DryRun
    )

    Write-Host "Evaluating: $Description" -ForegroundColor Cyan
    Write-Host "  Path:  $Path"
    Write-Host "  Name:  $Name"
    Write-Host "  Value: $Value ($Type)"

    if ($DryRun) {
        Write-Host "  [DryRun] Would set registry key." -ForegroundColor Yellow
        Write-Host ""
        return
    }

    try {
        # Create the registry path if it does not exist
        if (-not (Test-Path -Path $Path)) {
            Write-Host "  Path does not exist. Creating: $Path" -ForegroundColor Gray
            New-Item -Path $Path -Force | Out-Null
        }

        # Apply the registry setting
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
        Write-Host "  [Success] Setting applied." -ForegroundColor Green
    }
    catch {
        Write-Host "  [Error] Failed to apply setting: $_" -ForegroundColor Red
    }
    Write-Host ""
}

# ----------------------------------------------------------------------------
# Main Execution
# ----------------------------------------------------------------------------

if (-not (Test-Path $JsonConfigPath)) {
    Write-Error "Configuration file not found at: $JsonConfigPath"
    exit 1
}

try {
    $configContent = Get-Content -Path $JsonConfigPath -Raw | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse JSON configuration: $_"
    exit 1
}

# Determine which levels to apply based on the target level (cumulative)
$levelsToApply = @()
if ($TargetLevel -eq 'Level1') {
    $levelsToApply += 'Level1'
}
elseif ($TargetLevel -eq 'Level2') {
    $levelsToApply += 'Level1', 'Level2'
}
elseif ($TargetLevel -eq 'Level3') {
    $levelsToApply += 'Level1', 'Level2', 'Level3'
}

Write-Host "Starting Windows Hardening Deployment" -ForegroundColor Magenta
Write-Host "Target Level: $TargetLevel"
Write-Host "Applying settings for: $($levelsToApply -join ', ')"
Write-Host "======================================================`n"

foreach ($level in $levelsToApply) {

    $settings = $configContent.$level

    if ($null -eq $settings -or $settings.Count -eq 0) {
        Write-Host "No settings found for $level. Skipping." -ForegroundColor DarkGray
        continue
    }

    Write-Host "--- Applying $level ---" -ForegroundColor Yellow

    foreach ($setting in $settings) {
        Set-RegistryKey -Path $setting.Path `
                        -Name $setting.Name `
                        -Value $setting.Value `
                        -Type $setting.Type `
                        -Description $setting.Description `
                        -DryRun:$DryRun
    }
}

Write-Host "Hardening deployment complete." -ForegroundColor Magenta
