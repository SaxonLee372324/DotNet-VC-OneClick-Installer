# =========================================
# DotNet + VC++ OneClick Installer
# Chinese Output via [char] Unicode
# ASCII SAFE / PS 5.1+ COMPATIBLE
# =========================================

function CN {
    param([int[]]$Codes)
    return -join ($Codes | ForEach-Object { [char]$_ })
}

Write-Host "========================================="
Write-Host ("DotNet + VC++ " + (CN 0x4E00,0x952E,0x5B89,0x88C5,0x5668))
Write-Host "========================================="

$psMajor = $PSVersionTable.PSVersion.Major
Write-Host ("{0}: {1}" -f (CN 0x5F53,0x524D,0x20,0x50,0x6F,0x77,0x65,0x72,0x53,0x68,0x65,0x6C,0x6C), $psMajor)
Write-Host ""

# -----------------------------
# Check winget
# -----------------------------
$WingetAvailable = $true
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host (CN 0x672A,0x68C0,0x6D4B,0x5230,0x20,0x77,0x69,0x6E,0x67,0x65,0x74) -ForegroundColor Yellow
    Write-Host (CN 0x5C06,0x8DF3,0x8FC7,0x20,0x6240,0x6709,0x20,0x5B89,0x88C5,0x9879) -ForegroundColor Yellow
    $WingetAvailable = $false
} else {
    Write-Host (CN 0x5DF2,0x68C0,0x6D4B,0x5230,0x20,0x77,0x69,0x6E,0x67,0x65,0x74)
}
Write-Host ""

# -----------------------------
# Enable .NET Framework
# -----------------------------
function Enable-NetFrameworkFeature {
    param([string]$Name)

    Write-Host ("{0} .NET Framework {1}" -f (CN 0x6B63,0x5728,0x68C0,0x67E5), $Name)

    if (-not (Get-Command Get-WindowsOptionalFeature -ErrorAction SilentlyContinue)) {
        Write-Host (CN 0x5F53,0x524D,0x7CFB,0x7EDF,0x4E0D,0x652F,0x6301,0x53EF,0x9009,0x529F,0x80FD) -ForegroundColor Yellow
        Write-Host ""
        return
    }

    try {
        if ($Name -eq "3.5") {
            $feature = Get-WindowsOptionalFeature -Online -FeatureName NetFx3 -ErrorAction SilentlyContinue
            if ($feature -and $feature.State -eq "Enabled") {
                Write-Host (CN 0x2E,0x4E,0x45,0x54,0x20,0x33,0x2E,0x35,0x20,0x5DF2,0x542F,0x7528)
            } elseif ($feature) {
                Write-Host (CN 0x672A,0x542F,0x7528,0x20,0x2E,0x4E,0x45,0x54,0x20,0x33,0x2E,0x35,0xFF0C,0x6B63,0x5728,0x542F,0x7528)
                Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart
            }
        }

        if ($Name -eq "4.8") {
            $reg = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
            $release = (Get-ItemProperty $reg -ErrorAction SilentlyContinue).Release
            if ($release -ge 528040) {
                Write-Host (CN 0x2E,0x4E,0x45,0x54,0x20,0x34,0x2E,0x38,0x20,0x6216,0x66F4,0x9AD8,0x7248,0x672C,0x5DF2,0x5B89,0x88C5)
            } else {
                Write-Host (CN 0x2E,0x4E,0x45,0x54,0x20,0x34,0x2E,0x38,0x20,0x672A,0x68C0,0x6D4B,0x5230) -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host (CN 0x68C0,0x67E5,0x65F6,0x53D1,0x751F,0x9519,0x8BEF) -ForegroundColor Red
    }

    Write-Host ""
}

Enable-NetFrameworkFeature "3.5"
Enable-NetFrameworkFeature "4.8"

# -----------------------------
# winget install wrapper
# -----------------------------
function Install-WithWinget {
    param(
        [string]$DisplayName,
        [string]$PackageId
    )

    if (-not $WingetAvailable) {
        Write-Host ("{0} {1}" -f $DisplayName, (CN 0x5DF2,0x8DF3,0x8FC7)) -ForegroundColor Yellow
        Write-Host ""
        return
    }

    Write-Host ("{0}: {1}" -f (CN 0x6B63,0x5728,0x5904,0x7406), $DisplayName)

    try {
        winget install `
            --id $PackageId `
            --source winget `
            --silent `
            --accept-package-agreements `
            --accept-source-agreements

        Write-Host ("{0} {1}" -f $DisplayName, (CN 0x5904,0x7406,0x5B8C,0x6210))
    }
    catch {
        Write-Host ("{0} {1}" -f $DisplayName, (CN 0x5904,0x7406,0x5931,0x8D25)) -ForegroundColor Red
    }

    Write-Host ""
}

# -----------------------------
# Packages
# -----------------------------
$DotNetRuntimes = @{
    "6"  = "Microsoft.DotNet.DesktopRuntime.6"
    "8"  = "Microsoft.DotNet.DesktopRuntime.8"
    "10" = "Microsoft.DotNet.DesktopRuntime.10"
}

$VCPackages = @{
    "2005.x86"  = "Microsoft.VCRedist.2005.x86"
    "2005.x64"  = "Microsoft.VCRedist.2005.x64"
    "2008.x86"  = "Microsoft.VCRedist.2008.x86"
    "2008.x64"  = "Microsoft.VCRedist.2008.x64"
    "2010.x86"  = "Microsoft.VCRedist.2010.x86"
    "2010.x64"  = "Microsoft.VCRedist.2010.x64"
    "2012.x86"  = "Microsoft.VCRedist.2012.x86"
    "2012.x64"  = "Microsoft.VCRedist.2012.x64"
    "2013.x86"  = "Microsoft.VCRedist.2013.x86"
    "2013.x64"  = "Microsoft.VCRedist.2013.x64"
    "2015+.x86" = "Microsoft.VCRedist.2015+.x86"
    "2015+.x64" = "Microsoft.VCRedist.2015+.x64"
}

foreach ($ver in $DotNetRuntimes.Keys) {
    Install-WithWinget (".NET $ver " + (CN 0x8FD0,0x884C,0x65F6)) $DotNetRuntimes[$ver]
}

foreach ($ver in $VCPackages.Keys) {
    Install-WithWinget ("Visual C++ $ver " + (CN 0x8FD0,0x884C,0x65F6)) $VCPackages[$ver]
}

Write-Host "========================================="
Write-Host (CN 0x6240,0x6709,0x7EC4,0x4EF6,0x5904,0x7406,0x5DF2,0x5B8C,0x6210)
Write-Host (CN 0x6309,0x20,0x45,0x6E,0x74,0x65,0x72,0x20,0x952E,0x9000,0x51FA)
Read-Host
