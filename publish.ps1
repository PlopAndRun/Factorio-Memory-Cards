$json = Get-Content .\info.json | ConvertFrom-Json
$version = $json.version
$full_name = "memory-cards_$version"
$publish_dir = ".\publish"
$out_archive = "$publish_dir\$full_name.zip"
$out_dir = "$publish_dir\$full_name"
$excludes = @(".gitignore", ".vscode", ".git", "publish.ps1")

Write-Output "Preparing directory"
if (!(Test-Path $publish_dir)) {
    New-Item -ItemType Directory -Path $publish_dir
}
if (Test-Path $out_dir) {
    Remove-Item -Path $out_dir -Recurse
}
if (Test-Path $out_archive) {
    Write-Output "Deleting existing archive"
    Remove-Item -Force $out_archive
}

$items = Get-ChildItem -Recurse . -Exclude @(".editorconfig", ".gitignore", ".git", ".vscode", ".github", "Publish", "publish.ps1", "readme.md", "*.xcf")

Write-Output "Creating archive $out_archive"
robocopy . "$out_dir" /XD ".vscode" ".git" ".github" "publish" /XF ".gitignore" "readme.md" "*.xcf" "publish.ps1" /S
Compress-Archive -Path $out_dir -CompressionLevel Optimal -DestinationPath $out_archive
