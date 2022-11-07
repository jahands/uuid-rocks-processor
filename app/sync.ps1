$dest = "/tmp/data/r2/uuids"
$uuidsAllCsv = "$dest/uuids-all.csv"
$rcloneConfig = "/tmp/rclone.conf"

# Set up rclone.conf (base64 encoded in env because I'm lazy)
if (-not (Test-Path $rcloneConfig)) {
    [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($env:RCLONE_CONFIG)).
    Replace("{N}", "`n") | 
        Out-File -Encoding utf8 $rcloneConfig
}

rclone --config=$rcloneConfig `
    sync r2:uuids $dest `
    --fast-list --size-only --transfers=20

# Check if rclone succeeded
if ($LASTEXITCODE -ne 0) {
    Write-Error "rclone failed to download from r2"
    exit 1
}

# Combine all uuids into one file
(@('uuids', 'uuids_workdir')
| ForEach-Object { Get-ChildItem -Recurse -File "$dest\$_" })
| ForEach-Object { Import-Csv $_ }
| ForEach-Object { [Ordered]@{ts = $_.ts; id_type = $_.id_type; id = $_.id } }
| Export-Csv -Encoding utf8 $uuidsAllCsv -UseQuotes Never

$uploadFailure = $false
# Copy to gcs for BigQuery
rclone --config=$rcloneConfig copy $uuidsAllCsv gcs-play:uuids
if ($LASTEXITCODE -ne 0) {
    Write-Error "rclone failed to upload to gcs"
    $uploadFailure = $true
}

# Copy to R2 just in case we want it elsewhere
rclone --config=$rcloneConfig copy $uuidsAllCsv r2:uuids
if ($LASTEXITCODE -ne 0) {
    Write-Error "rclone failed to upload to r2"
    $uploadFailure = $true
}

if ($uploadFailure) {
    exit 1
}
