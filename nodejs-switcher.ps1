[CmdletBinding()]
param (
    [Parameter()]
    [switch]$install = $false,
    [string]$basePath = "C:\Node",
    [string[]]$v = @("8.16.2"),
    $ParameterName
)

$start_time = Get-Date

if ($install) {
    foreach ($version in $v) {
        $folderName = "node-v$version-win-x64"
        $fileName = "$folderName.zip"
        $url = "https://nodejs.org/download/release/v$version/$fileName"
        $outputFile = "$basePath\$fileName"
        Invoke-WebRequest -Uri $url -OutFile $outputFile
        # (New-Object System.Net.WebClient).DownloadFile($url, $outputFile)

        # https://nodejs.org/en/download/releases/
        # https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
        # https://stackoverflow.com/questions/41895772/powershell-script-to-download-a-zip-file-and-unzip-it
        # https://gallery.technet.microsoft.com/scriptcenter/a6b10a18-c4e4-46cc-b710-4bd7fa606f95
        # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-6
        # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-6

        Expand-Archive $outputFile -DestinationPath $basePath -Force
        Remove-Item $outputFile

        Write-Output $url
    }
}
else {
    Write-Output $install
}

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"