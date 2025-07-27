# Advanced README Update Script
# This script can automatically add new experiments to the detailed index

param(
    [switch]$AddNewExperiment,
    [string]$Subject = "",
    [string]$ExperimentNumber = "",
    [string]$ExperimentTitle = "",
    [switch]$Verbose
)

Write-Host "Advanced README Update Script" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

$readmePath = "README.md"

if (-not (Test-Path $readmePath)) {
    Write-Host "README.md not found!" -ForegroundColor Red
    exit 1
}

$content = Get-Content $readmePath -Raw

if ($AddNewExperiment) {
    if (-not $Subject -or -not $ExperimentNumber -or -not $ExperimentTitle) {
        Write-Host "Error: Please provide Subject, ExperimentNumber, and ExperimentTitle" -ForegroundColor Red
        Write-Host "Usage: .\update_readme_advanced.ps1 -AddNewExperiment -Subject 'MLBC' -ExperimentNumber '03' -ExperimentTitle 'Advanced Blockchain Implementation'" -ForegroundColor Yellow
        exit 1
    }
    
    # Map subject codes to full names
    $subjectMap = @{
        'MLBC' = 'Machine Learning and Blockchain'
        'FC' = 'Edge and Fog Computing'
        'DEVOPS' = 'DevOps & Cloud Computing'
        'OSINT' = 'Open Source Intelligence'
    }
    
    $fullSubjectName = $subjectMap[$Subject]
    if (-not $fullSubjectName) {
        Write-Host "Error: Invalid subject code. Use MLBC, FC, DEVOPS, or OSINT" -ForegroundColor Red
        exit 1
    }
    
    # Determine file name based on subject
    $fileName = if ($Subject -eq 'MLBC') { "Practical $ExperimentNumber" } else { "Experiment $ExperimentNumber" }
    
    # Create new experiment entry
    $newExperiment = @"

- **Experiment $ExperimentNumber**: $ExperimentTitle
  - 📄 [$fileName.pdf]($Subject/Experiment%20$ExperimentNumber/$fileName.pdf)
"@
    
    # Find the subject section and add the new experiment
    $subjectPattern = "### $fullSubjectName - IoTCSBCL\d+"
    $subjectMatch = [regex]::Match($content, $subjectPattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    
    if ($subjectMatch.Success) {
        $subjectStart = $subjectMatch.Index
        $subjectEnd = $content.IndexOf("### ", $subjectStart + 1)
        if ($subjectEnd -eq -1) {
            $subjectEnd = $content.Length
        }
        
        $subjectSection = $content.Substring($subjectStart, $subjectEnd - $subjectStart)
        
        # Find where to insert the new experiment (before the rubrics)
        $rubricPattern = "  - 📋 \[Experiment Rubric\]"
        $rubricMatch = [regex]::Match($subjectSection, $rubricPattern)
        
        if ($rubricMatch.Success) {
            $insertPosition = $subjectStart + $rubricMatch.Index
            $content = $content.Insert($insertPosition, $newExperiment)
            Write-Host "Added new experiment: $ExperimentTitle" -ForegroundColor Green
        } else {
            # If no rubrics found, add at the end of subject section
            $content = $content.Insert($subjectEnd, $newExperiment)
            Write-Host "Added new experiment: $ExperimentTitle" -ForegroundColor Green
        }
        
        # Update the content
        $content | Set-Content $readmePath -NoNewline
        Write-Host "README.md updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "Error: Could not find subject section for $fullSubjectName" -ForegroundColor Red
    }
} else {
    # Just update date and statistics (same as basic script)
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $content = $content -replace "\*\*Last Updated\*\*: .*", "**Last Updated**: $currentDate"
    $content | Set-Content $readmePath -NoNewline
    Write-Host "README.md date updated to: $currentDate" -ForegroundColor Green
}

if ($Verbose) {
    Write-Host "`nAvailable commands:" -ForegroundColor Cyan
    Write-Host "1. Update date only: .\update_readme_advanced.ps1" -ForegroundColor White
    Write-Host "2. Add new experiment: .\update_readme_advanced.ps1 -AddNewExperiment -Subject 'MLBC' -ExperimentNumber '03' -ExperimentTitle 'Your Title'" -ForegroundColor White
    Write-Host "3. With verbose output: .\update_readme_advanced.ps1 -Verbose" -ForegroundColor White
} 