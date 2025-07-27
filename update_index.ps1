# Semester VII Repository Index Updater
# This script helps maintain the repository index when new files are added

param(
    [switch]$Force,
    [switch]$Verbose
)

Write-Host "Semester VII Repository Index Updater" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Get current directory structure
$rootPath = Get-Location
$subjects = @("DEVOPS", "FC", "MLBC", "OSINT")

Write-Host "`nScanning repository structure..." -ForegroundColor Yellow

$stats = @{
    TotalFiles = 0
    TotalDirectories = 0
    Subjects = $subjects.Count
    Experiments = 0
    Assignments = 0
    MiniProjects = 0
}

$fileList = @()

foreach ($subject in $subjects) {
    $subjectPath = Join-Path $rootPath $subject
    if (Test-Path $subjectPath) {
        Write-Host "`nProcessing $subject..." -ForegroundColor Cyan
        
        # Get all files in subject directory
        $files = Get-ChildItem -Path $subjectPath -Recurse -File
        $stats.TotalFiles += $files.Count
        $stats.TotalDirectories += (Get-ChildItem -Path $subjectPath -Recurse -Directory).Count
        
        foreach ($file in $files) {
            $relativePath = $file.FullName.Replace($rootPath.Path, "").TrimStart("\")
            $fileList += [PSCustomObject]@{
                Subject = $subject
                Path = $relativePath
                Name = $file.Name
                Size = $file.Length
                Extension = $file.Extension
                LastModified = $file.LastWriteTime
            }
            
            # Count by type
            if ($file.Name -match "Experiment|Practical") {
                $stats.Experiments++
            }
            if ($file.Name -match "Assignment") {
                $stats.Assignments++
            }
            if ($file.Name -match "Mini.*Project|Project") {
                $stats.MiniProjects++
            }
        }
    }
}

Write-Host "`nRepository Statistics:" -ForegroundColor Green
Write-Host "Total Files: $($stats.TotalFiles)" -ForegroundColor White
Write-Host "Total Directories: $($stats.TotalDirectories)" -ForegroundColor White
Write-Host "Subjects: $($stats.Subjects)" -ForegroundColor White
Write-Host "Experiments: $($stats.Experiments)" -ForegroundColor White
Write-Host "Assignments: $($stats.Assignments)" -ForegroundColor White
Write-Host "Mini Projects: $($stats.MiniProjects)" -ForegroundColor White

if ($Verbose) {
    Write-Host "`nFile Details:" -ForegroundColor Green
    foreach ($file in $fileList | Sort-Object Subject, Path) {
        $sizeKB = [math]::Round($file.Size / 1KB, 2)
        Write-Host "$($file.Path) - $($sizeKB) KB" -ForegroundColor Gray
    }
}

Write-Host "`nIndex update completed!" -ForegroundColor Green
Write-Host "Tip: Run this script whenever you add new files to keep the index current." -ForegroundColor Yellow

# Optional: Update README.md with new statistics
if ($Force) {
    Write-Host "`nUpdating README.md with new statistics..." -ForegroundColor Yellow
    # This would update the README.md file with new statistics
    # Implementation can be added here if needed
} 