[CmdletBinding()]
param (
    [Parameter()]
    [switch]$install = $false,
    [string]$basePath = "C:\Node",
    [string[]]$v = @("8.16.2", "10.17.0", "12.13.1"),
    $ParameterName
)

if (!(Test-Path -Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force
}

if ($install) {
    Add-Type -assembly "System.IO.Compression.Filesystem";

    foreach ($version in $v) {
        $folderName = "node-v$version-win-x64"
        $fileName = "$folderName.zip"
        $url = "https://nodejs.org/download/release/v$version/$fileName"
        $outputFile = "$basePath\$fileName"
        $envName = "NODE_${version}"
        $envValue = "$basePath\$folderName"

        if (Test-Path -Path $outputFile) {
            Remove-Item -Path $outputFile -Recurse
        }

        if (Test-Path -Path $envValue) {
            Remove-Item -Path $envValue -Recurse
        }

        # Invoke-WebRequest -Uri $url -OutFile $outputFile
        (New-Object System.Net.WebClient).DownloadFile($url, $outputFile)
        # Expand-Archive $outputFile -DestinationPath $basePath -Force
        [IO.Compression.Zipfile]::ExtractToDirectory($outputFile, $basePath);

        Remove-Item $outputFile

        # Copy-Item .\nodejs-switcher.ps1 -Destination $envValue

        [System.Environment]::SetEnvironmentVariable($envName, $envValue, [System.EnvironmentVariableTarget]::User);
        [System.Environment]::SetEnvironmentVariable("NODE_HOME", "%$envName%", [System.EnvironmentVariableTarget]::User);

        Write-Host $url
    }
}
else {
    $nodeHome = [System.Environment]::GetEnvironmentVariable("NODE_HOME", [System.EnvironmentVariableTarget]::User);
    $userVariables = [System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User);
    $nodeVariables = @();

    $i = 0;
    foreach ($key in $userVariables.Keys) {
        if ($key -cmatch "^NODE_\d{1,2}\.\d{1,2}\.\d{1,2}$") {
            $nodeVariables += $key;
            $i++;
        }
    }

    if ($i -gt 0) {
        Write-Host "Active version of Node.js: $nodeHome"
        Write-Host "Select you Node.js:"

        $i = 0;
        foreach ($key in $nodeVariables) {
            Write-Host "$i - $key"
            $i++;
        }

        $selection = Read-Host "Please make a selection"

        if ($selection -le ($nodeVariables.Count - 1)) {
            $newNodeHome = $nodeVariables[$selection]
            [System.Environment]::SetEnvironmentVariable("NODE_HOME", "%$newNodeHome%", [System.EnvironmentVariableTarget]::User);
        }

        Write-Host "Exiting..."
    }
    else {
        Write-Host "You have no version of Node.js installed."
    }
}

$pathVariable = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User);

if (!($pathVariable.Contains("%NODE_HOME%"))) {
    [System.Environment]::SetEnvironmentVariable("Path", "$pathVariable%NODE_HOME%;", [System.EnvironmentVariableTarget]::User);
}