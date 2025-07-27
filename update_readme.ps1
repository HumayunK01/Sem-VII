# Update README.md with current date
$currentDate = Get-Date -Format "yyyy-MM-dd"
$readmePath = "README.md"

# Read the current README content
$content = Get-Content $readmePath -Raw

# Replace the date line
$content = $content -replace "\*\*Last Updated\*\*: .*", "**Last Updated**: $currentDate"

# Write back to file
$content | Set-Content $readmePath -NoNewline

Write-Host "README.md updated with current date: $currentDate" -ForegroundColor Green 