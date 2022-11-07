$dest = "/tmp/data/r2/uuids"
$uuidsAllCsv = "/tmp/data/uuids-all.csv"
$rcloneConfig = "/tmp/rclone.conf"
$gcpKeyfile = "/tmp/gcp-keyfile.json"

# Set up rclone.conf (base64 encoded in env because I'm lazy)
if (-not (Test-Path $rcloneConfig)) {
    [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($env:RCLONE_CONFIG)).
    Replace("{N}", "`n") | 
        Out-File -Encoding utf8 $rcloneConfig
}
# Set up gcp keyfile
if (-not (Test-Path $gcpKeyfile)) {
    $env:GCP_KEYFILE | 
        Out-File -Encoding utf8 $gcpKeyfile
}

rclone --config=$rcloneConfig `
    sync r2:uuids $dest `
    --include=/uuids/** --include=/uuids_workdir/** `
    --fast-list --size-only --transfers=20

# Check if rclone succeeded
if ($LASTEXITCODE -ne 0) {
    Write-Error "rclone failed to download from r2"
    exit 1
}

# Combine all uuids into one file
bash -c "$PSScriptRoot/combine.sh"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to combine uuids!"
    exit 1
}

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
