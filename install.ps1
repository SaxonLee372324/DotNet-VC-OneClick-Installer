# =========================================
# DotNet + VC++ OneClick Installer
# =========================================

Write-Host "========================================="
Write-Host "DotNet + VC++ OneClick Installer"
Write-Host "========================================="

# 检查 winget
$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Host "winget is not installed. Please install winget manually." -ForegroundColor Red
    exit 1
} else {
    Write-Host "winget is installed."
}

# 启用 .NET Framework 功能
Function Enable-NetFrameworkFeature {
    param($name)
    try {
        if ($name -eq "3.5") {
            $feature = Get-WindowsOptionalFeature -Online -FeatureName NetFx3
            if ($feature.State -eq "Enabled") {
                Write-Host ".NET Framework 3.5 is already installed."
            } else {
                Write-Host ".NET Framework 3.5 not installed, enabling..."
                Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart
                Write-Host ".NET Framework 3.5 enabled."
            }
        } elseif ($name -eq "4.8") {
            $regPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
            $releaseValue = (Get-ItemProperty $regPath -ErrorAction SilentlyContinue).Release
            if ($releaseValue -ge 528040) {
                Write-Host ".NET Framework 4.8 or higher is already installed."
            } else {
                Write-Host ".NET Framework 4.8 not installed, enabling..."
                Enable-WindowsOptionalFeature -Online -FeatureName NetFx4 -All -NoRestart
                Write-Host ".NET Framework 4.8 enabled."
            }
        }
    } catch {
        Write-Host "Error checking .NET Framework ${name}: $_"
    }
    Write-Host ""
}

Enable-NetFrameworkFeature -name "3.5"
Enable-NetFrameworkFeature -name "4.8"

# 定义所有 .NET Runtime 与 VC++ 包信息
$dotNetRuntimes = @{
    "6"  = "Microsoft.DotNet.DesktopRuntime.6"
    "8"  = "Microsoft.DotNet.DesktopRuntime.8"
    "10" = "Microsoft.DotNet.DesktopRuntime.10"
}

$vcPackages = @{
    "2005.x86" = "Microsoft.VCRedist.2005.x86"
    "2005.x64" = "Microsoft.VCRedist.2005.x64"
    "2008.x86" = "Microsoft.VCRedist.2008.x86"
    "2008.x64" = "Microsoft.VCRedist.2008.x64"
    "2010.x86" = "Microsoft.VCRedist.2010.x86"
    "2010.x64" = "Microsoft.VCRedist.2010.x64"
    "2012.x86" = "Microsoft.VCRedist.2012.x86"
    "2012.x64" = "Microsoft.VCRedist.2012.x64"
    "2013.x86" = "Microsoft.VCRedist.2013.x86"
    "2013.x64" = "Microsoft.VCRedist.2013.x64"
    "2015+.x86" = "Microsoft.VCRedist.2015+.x86"
    "2015+.x64" = "Microsoft.VCRedist.2015+.x64"
}

# 统一检测和安装函数
Function Install-WithWinget {
    param($displayName, $packageId)

    try {
        $installed = winget list --id $packageId --source winget | Select-String $packageId
        if ($installed) {
            Write-Host "${displayName} is already installed, checking upgrades..."
        } else {
            Write-Host "${displayName} not installed, installing..."
        }

        # 执行安装，不打印命令本身
        winget install --id $packageId --source winget --silent --accept-package-agreements --accept-source-agreements
        Write-Host "${displayName} install command completed."
    } catch {
        Write-Host "Error installing ${packageId}: $_"
    }
    Write-Host ""  # 包之间增加空行
}

# 安装 .NET Runtime
foreach ($ver in $dotNetRuntimes.Keys) {
    Install-WithWinget "NET ${ver} Runtime" $dotNetRuntimes[$ver]
}

# 安装 VC++ 包
foreach ($ver in $vcPackages.Keys) {
    Install-WithWinget "Visual C++ ${ver}" $vcPackages[$ver]
}

Write-Host "All runtime checks and installations completed successfully."
Write-Host "========================================="
Write-Host "Script finished. Press any key to exit."
Read-Host
