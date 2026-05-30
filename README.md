# Windows & Office Hardening Framework

This repository provides an enterprise-grade framework for automating the deployment of Windows and Microsoft Office hardening settings via the registry. It uses a tiered, cumulative approach (Level 1, Level 2, and Level 3) to balance security and operational impact.

## Project Structure

- `Deploy-RegistryHardening.ps1`: The core PowerShell script used to apply settings from JSON configuration files.
- `WindowsBaseline.json`: A comprehensive collection of Windows OS hardening settings, including UAC, SMBv1 disablement, Credential Guard, and ASR rules.
- `OfficeBaseline.json`: Targeted security settings for Microsoft Office (Word, Excel, PowerPoint), focusing on macro protection, DDE mitigation, and OLE blocking.
- `CIS_GoogleChrome.json`: Security configuration for Google Chrome based on CIS benchmarks, covering privacy, extension controls, and browser security.

## Hardening Levels

- **Level 1 (Essential Baseline)**: High-security, low-impact settings that should be applied to all systems.
- **Level 2 (Intermediate)**: Advanced security settings that may have minor operational impact or require compatible hardware (e.g., Credential Guard).
- **Level 3 (Strict)**: Maximum security controls for high-risk environments, which may introduce friction for some workflows.

## Usage

The `Deploy-RegistryHardening.ps1` script requires two mandatory parameters: the path to a JSON configuration file and the target hardening level.

### Examples

#### Applying the Windows Baseline (Level 1)
To preview the changes without applying them (Dry Run):
```powershell
.\Deploy-RegistryHardening.ps1 -JsonConfigPath ".\WindowsBaseline.json" -TargetLevel "Level1" -DryRun
```

To apply the settings:
```powershell
.\Deploy-RegistryHardening.ps1 -JsonConfigPath ".\WindowsBaseline.json" -TargetLevel "Level1"
```

#### Applying the Office Baseline (Level 2)
```powershell
.\Deploy-RegistryHardening.ps1 -JsonConfigPath ".\OfficeBaseline.json" -TargetLevel "Level2"
```

#### Applying the Google Chrome Baseline (Level 1)
```powershell
.\Deploy-RegistryHardening.ps1 -JsonConfigPath ".\CIS_GoogleChrome.json" -TargetLevel "Level1"
```

### Cumulative Nature
Applying a higher level automatically includes all settings from the lower levels. For example, selecting `-TargetLevel "Level3"` will apply Level 1, Level 2, and Level 3 settings.

## Prerequisites

- Windows 10/11 or Windows Server 2016/2019/2022.
- PowerShell 5.1 or PowerShell Core.
- Administrative privileges are required to modify `HKLM` (Windows Baseline).
- User context is required for `HKCU` (Office Baseline).

## Safety Features

- **-DryRun Support**: Always use `-DryRun` first to see exactly which registry keys will be modified.
- **Automated Path Creation**: The script automatically creates missing registry paths if they do not exist.
- **Error Handling**: Failed settings are logged without interrupting the rest of the deployment.
