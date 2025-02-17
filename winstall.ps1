# winstall.ps1 - Winget Wrapper with Install, Uninstall, and List Installed Packages

param (
    [string]$Action,          # "install", "uninstall", "list"
    [string]$PackageName,     # Package name (for install/uninstall)
    [string]$Category,        # Category (optional, for install)
    [string]$CustomPath       # Optional custom install path
)

# Load Config and Database
$ConfigPath = "D:\Tools&Misc\Tools\winstall_config.json"
$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

$DatabasePath = $Config.DatabasePath
$Database = Get-Content $DatabasePath -Raw | ConvertFrom-Json

$LogFile = $Config.LogFile

# Function to log actions
function Log-Action {
    param ([string]$Message)
    Add-Content -Path $LogFile -Value "$(Get-Date) - $Message"
}

# Function to get install location based on category
function Get-InstallPath {
    param ([string]$Category)
    
    if ($CustomPath) {
        return $CustomPath  # Override if user provides a custom path
    }

    if ($Category -and $Config.InstallLocations.$Category) {
        return $Config.InstallLocations.$Category
    }

    return $Config.InstallLocations.Default  # Fallback to default location
}

# Function to install a package
function Install-Package {
    param ([string]$PackageName, [string]$Category)

    $Package = $Database.$PackageName
    if ($Package) {
        $PackageID = $Package.ID
        $Version = $Package.Version[-1]  # Latest version
        $InstallPath = Get-InstallPath -Category $Category

        Write-Output "Installing $PackageName ($PackageID) version $Version..."
        Write-Output "Install Path: $InstallPath"

        winget install --id $PackageID  --silent --location "$InstallPath"

        Log-Action "Installed $PackageName at $InstallPath"
    } else {
        Write-Output "Package not found!"
    }
}

# Function to uninstall a package
function Uninstall-Package {
    param ([string]$PackageName)

    $Package = $Database.$PackageName
    if ($Package) {
        $PackageID = $Package.ID
        Write-Output "Uninstalling $PackageName ($PackageID)..."
        
        winget uninstall --id $PackageID --silent
        
        Log-Action "Uninstalled $PackageName"
    } else {
        Write-Output "Package not found!"
    }
}

# Function to list installed packages
function List-Installed {
    Write-Output "Fetching installed packages..."
    
    $InstalledPackages = winget list | ForEach-Object { $_ -replace '\s+', ',' } | ConvertFrom-Csv
    $InstalledPackages | Format-Table -AutoSize
    
    Log-Action "Listed installed packages"
}

function Search-Package {
    param ([string]$keyword)

    Write-Host "Searching for '$keyword'..."

    $results = @()
    foreach ($package in $database.PSObject.Properties) {
        $packageName = $package.Name
        $packageID = $package.Value.ID
        
        # Convert both to lowercase for case-insensitive matching
        if ($packageName.ToLower() -like "*$($keyword.ToLower())*" -or $packageID.ToLower() -like "*$($keyword.ToLower())*") {
            $results += @{ Name = $packageName; ID = $packageID }
        }
    }

    if ($results.Count -eq 0) {
        Write-Host "No matching packages found."
        return
    }

    Write-Host "`nFound Packages:"
    foreach ($package in $results) {
        Write-Host "- $($package.Name) [ID: $($package.ID)]"
    }
}
# Determine action
if ($Action -eq "install" -and $PackageName) {
    Install-Package -PackageName $PackageName -Category $Category
} elseif ($Action -eq "uninstall" -and $PackageName) {
    Uninstall-Package -PackageName $PackageName
} elseif ($Action -eq "list") {
    List-Installed
}
elseif ($Action -eq "search" -and $PackageName) {
    Search-Package -keyword $PackageName
} else {
    Write-Output "Usage:"
    Write-Output "  winstall install <PackageName> <Category> [--path <CustomPath>]"
    Write-Output "  winstall uninstall <PackageName>"
    Write-Output "  winstall list"
    Write-Output "  winstall search <PackageName>"
}




