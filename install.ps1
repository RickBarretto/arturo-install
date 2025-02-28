# Arturo
# Programming Language + Bytecode VM compiler
# (c) 2019-2022 Yanis Zafirópulos

$ErrorActionPreference = "Stop"

function Show-Header {
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "               _                    " -ForegroundColor Green
    Write-Host "              | |                   " -ForegroundColor Green
    Write-Host "     __ _ _ __| |_ _   _ _ __ ___   " -ForegroundColor Green
    Write-Host "    / _\` | '__| __| | | | '__/ _ \ " -ForegroundColor Green
    Write-Host "   | (_| | |  | |_| |_| | | | (_) | " -ForegroundColor Green
    Write-Host "    \__,_|_|   \__|\__,_|_|  \___/  " -ForegroundColor Green
    Write-Host "                                    " -ForegroundColor Green
    Write-Host "     Arturo Programming Language" -ForegroundColor Green
    Write-Host "      (c)2024 Yanis Zafirópulos" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host " ► $($args[0])" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
}

function Show-Footer {
    Write-Host ""
    Write-Host " :---------------------------------------------------------" -ForegroundColor Gray
    Write-Host " : Arturo has been successfully installed!" -ForegroundColor Gray
    Write-Host " :" -ForegroundColor Gray
    Write-Host " : To be able to run it," -ForegroundColor Gray
    Write-Host " : first make sure its in your \$PATH:" -ForegroundColor Gray
    Write-Host " :" -ForegroundColor Gray
    Write-Host " :    \$env:Path += \";$HOME\.arturo\bin\"" -ForegroundColor Gray
    Write-Host " :" -ForegroundColor Gray
    Write-Host " : and add it to your profile," -ForegroundColor Gray
    Write-Host " : so that it's set automatically every time." -ForegroundColor Gray
    Write-Host " :" -ForegroundColor Gray
    Write-Host " : Rock on! :)" -ForegroundColor Gray
    Write-Host " :---------------------------------------------------------" -ForegroundColor Gray
    Write-Host ""
}

function Section {
    Write-Host ""
    Write-Host " ● $($args[0])" -ForegroundColor Magenta
}

function Info {
    Write-Host "   $($args[0])" -ForegroundColor Gray
}

function Create-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }
}

function Create-TempDirectory {
    $global:ARTURO_TMP_DIR = New-TemporaryFile
    Remove-Item $global:ARTURO_TMP_DIR
    New-Item -ItemType Directory -Force -Path $global:ARTURO_TMP_DIR | Out-Null
}

function Cleanup-TempDirectory {
    if ($global:ARTURO_TMP_DIR) {
        Remove-Item -Recurse -Force -Path $global:ARTURO_TMP_DIR
        $global:ARTURO_TMP_DIR = $null
    }
}

function Get-DownloadUrl {
    param (
        [string]$apiUrl
    )
    $downloadUrl = (Invoke-RestMethod -Uri $apiUrl).assets | Where-Object { $_.name -like "*windows*" } | Select-Object -First 1 -ExpandProperty browser_download_url
    return $downloadUrl
}

function Download-Arturo {
    param (
        [string]$url,
        [string]$output
    )
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
}

function Unpack-Arturo {
    param (
        [string]$archive,
        [string]$destination
    )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($archive, $destination)
}

function Install-Arturo {
    param (
        [string]$source,
        [string]$destination
    )
    Create-Directory -path $destination
    Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force
}

function Main {
    Show-Header "Installer"

    Section "Checking environment..."
    Info "os: Windows"
    Info "shell: PowerShell"

    Section "Downloading..."
    $apiUrl = "https://api.github.com/repos/arturo-lang/arturo/releases"
    $downloadUrl = Get-DownloadUrl -apiUrl $apiUrl
    $archivePath = "$global:ARTURO_TMP_DIR\arturo.zip"
    Download-Arturo -url $downloadUrl -output $archivePath

    Section "Installing..."
    Unpack-Arturo -archive $archivePath -destination $global:ARTURO_TMP_DIR
    Install-Arturo -source "$global:ARTURO_TMP_DIR\arturo-*" -destination "$HOME\.arturo\bin"

    Section "Cleaning up..."
    Cleanup-TempDirectory

    Section "Done!"
    Show-Footer
}

Main
