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
        
        # Count folders by type (not files)
        $directories = Get-ChildItem -Path $subjectPath -Recurse -Directory
        foreach ($dir in $directories) {
            if ($dir.Name -match "^Experiment \d+|^Practical \d+") {
                $stats.Experiments++
            }
            if ($dir.Name -match "^Assignment \d+") {
                $stats.Assignments++
            }
            if ($dir.Name -match "^Mini Project \d+|^Project \d+") {
                $stats.MiniProjects++
            }
        }
        
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

# Update README.md with current date and statistics
$currentDate = Get-Date -Format "yyyy-MM-dd"
$readmePath = "README.md"

if (Test-Path $readmePath) {
    $content = Get-Content $readmePath -Raw
    
    # Update date
    $content = $content -replace "\*\*Last Updated\*\*: .*", "**Last Updated**: $currentDate"
    
    # Update total experiments count
    $content = $content -replace "(\*\*Total Experiments\*\*: ).*", "`$1$($stats.Experiments)"
    
    # Update total assignments count
    $content = $content -replace "(\*\*Total Assignments\*\*: ).*", "`$1$($stats.Assignments)"
    
    # Update total mini projects count
    $content = $content -replace "(\*\*Total Mini Projects\*\*: ).*", "`$1$($stats.MiniProjects)"
    
    # Update subject-specific experiment counts
    $subjectStats = @{}
    foreach ($subject in $subjects) {
        $subjectStats[$subject] = @{
            Experiments = 0
            Assignments = 0
            MiniProjects = 0
        }
    }
    
    # Count experiments per subject
    foreach ($subject in $subjects) {
        $subjectPath = Join-Path $rootPath $subject
        if (Test-Path $subjectPath) {
            $directories = Get-ChildItem -Path $subjectPath -Recurse -Directory
            foreach ($dir in $directories) {
                if ($dir.Name -match "^Experiment \d+|^Practical \d+") {
                    $subjectStats[$subject].Experiments++
                }
                if ($dir.Name -match "^Assignment \d+") {
                    $subjectStats[$subject].Assignments++
                }
                if ($dir.Name -match "^Mini Project \d+|^Project \d+") {
                    $subjectStats[$subject].MiniProjects++
                }
            }
        }
    }
    
    # Update subject overviews
    $content = $content -replace "(\*\*Experiments\*\*: )1(\s*\*\*Assignments\*\*: )0(\s*\*\*Mini Projects\*\*: )0", "`$1$($subjectStats['MLBC'].Experiments)`$2$($subjectStats['MLBC'].Assignments)`$3$($subjectStats['MLBC'].MiniProjects)"
    $content = $content -replace "(\*\*Experiments\*\*: )1(\s*\*\*Assignments\*\*: )0", "`$1$($subjectStats['FC'].Experiments)`$2$($subjectStats['FC'].Assignments)"
    $content = $content -replace "(\*\*Experiments\*\*: )1", "`$1$($subjectStats['DEVOPS'].Experiments)"
    $content = $content -replace "(\*\*Experiments\*\*: )2(\s*\*\*Assignments\*\*: )0(\s*\*\*Mini Projects\*\*: )0", "`$1$($subjectStats['OSINT'].Experiments)`$2$($subjectStats['OSINT'].Assignments)`$3$($subjectStats['OSINT'].MiniProjects)"
    
    # Update navigation table
    $content = $content -replace "(\[Machine Learning & Blockchain\]\(MLBC/\) \| )1", "`$1$($subjectStats['MLBC'].Experiments)"
    $content = $content -replace "(\[Edge and Fog Computing\]\(FC/\) \| )1", "`$1$($subjectStats['FC'].Experiments)"
    $content = $content -replace "(\[DevOps & Cloud Computing\]\(DEVOPS/\) \| )1", "`$1$($subjectStats['DEVOPS'].Experiments)"
    $content = $content -replace "(\[Open Source Intelligence\]\(OSINT/\) \| )2", "`$1$($subjectStats['OSINT'].Experiments)"
    
    $content | Set-Content $readmePath -NoNewline
    Write-Host "README.md updated - Date: $currentDate, Experiments: $($stats.Experiments), Assignments: $($stats.Assignments), Mini Projects: $($stats.MiniProjects)" -ForegroundColor Green
}

# Optional: Update README.md with new statistics
if ($Force) {
    Write-Host "`nUpdating README.md with new statistics..." -ForegroundColor Yellow
    # This would update the README.md file with new statistics
    # Implementation can be added here if needed
} 