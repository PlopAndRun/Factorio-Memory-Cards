$json = Get-Content .\info.json | ConvertFrom-Json
$version = $json.version
$full_name = "memory-cards_$version"
$publish_dir = ".\publish"
$out_archive = "$publish_dir\$full_name.zip"
$excludes = @(".gitignore", ".vscode", ".git", "publish.ps1")

Write-Output "Preparing directory"
if (!(Test-Path $publish_dir)) {
    New-Item -ItemType Directory -Path $publish_dir
}
if (Test-Path $out_archive) {
    Write-Output "Deleting existing archive"
    Remove-Item -Force $out_archive
}

$items = Get-ChildItem . -Exclude @(".gitignore", ".git", ".vscode", ".github", "Publish", "publish.ps1", "readme.md")

Write-Output "Creating archive $out_archive"
Compress-Archive -Path $items -CompressionLevel Optimal -DestinationPath $out_archive
