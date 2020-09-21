#Allow Powershell Scripts to run.
Set-ExecutionPolicy Unrestricted

# Create Temperary Directory if none exsists.
New-Item -ItemType directory -Path C:\temp\

# Download .zip file with beats already compiled for deployment. (merrimac-internal)
Invoke-WebRequest "https://merrimac-elastic.s3.us-east-2.amazonaws.com/beats_modified_uncompressed.zip" -OutFile "C:\temp\modified_uncompressed.zip"

# Invoke and use unzip to decompress zip file from previous step.
Add-Type -AssemblyName System.IO.Compression.FileSystem
function unzip {
	param( [string]$ziparchive, [string]$extractpath )
	[System.IO.Compression.ZipFile]::ExtractToDirectory( $ziparchive, $extractpath )
}

unzip "C:\temp\modified_uncompressed.zip" "C:\temp\modified_uncompressed"

# Metricbeat installation.
Set-Location "C:\temp\modified_uncompressed\modified_uncompressed\Metricbeat"
Copy-Item -Path "C:\temp\modified_uncompressed\modified_uncompressed\Metricbeat\" -Destination "C:\Program Files\Metricbeat" -Recurse
Set-Location "C:\Program Files\Metricbeat"
Invoke-expression -Command ".\install-service-metricbeat.ps1"
Start-Service metricbeat

# Winlogbeat installation.
Set-Location "C:\temp\modified_uncompressed\modified_uncompressed\Winlogbeat"
Copy-Item "C:\temp\modified_uncompressed\modified_uncompressed\Winlogbeat" -Destination "C:\Program Files\Winlogbeat" -Recurse
Set-Location "C:\Program Files\Winlogbeat"
Invoke-expression -Command ".\install-service-winlogbeat.ps1"
Start-Service winlogbeat

# Auditbeat installation.
Set-Location "C:\temp\modified_uncompressed\modified_uncompressed\Auditbeat"
Copy-Item "C:\temp\modified_uncompressed\modified_uncompressed\Auditbeat" -Destination "C:\Program Files\Auditbeat" -Recurse
Set-Location "C:\Program Files\Auditbeat"
Invoke-expression -Command ".\install-service-Auditbeat.ps1"
Start-Service auditbeat

# Packetbeat installation
Invoke-WebRequest "https://nmap.org/npcap/dist/npcap-0.9997.exe" -OutFile "C:\temp\npcap-0.9997.exe"
Set-Location "C:\temp\"
Start-Process .\npcap-0.9997.exe
Start-Sleep -s 60
Set-Location "C:\temp\modified_uncompressed\modified_uncompressed\Packetbeat"
Copy-Item "C:\temp\modified_uncompressed\modified_uncompressed\Packetbeat" -Destination "C:\Program Files\Packetbeat" -Recurse
Set-Location "C:\Program Files\Packetbeat"
Invoke-expression -Command ".\install-service-packetbeat.ps1"
Start-Service packetbeat

# Clean-up and file removal.
Set-Location "C:\temp\"
Remove-Item "C:\temp\modified_uncompressed.zip"
Remove-Item -LiteralPath "C:\temp\modified_uncompressed" -Force -Recurse
Remove-Item "C:\temp\npcap-0.9997.exe"
