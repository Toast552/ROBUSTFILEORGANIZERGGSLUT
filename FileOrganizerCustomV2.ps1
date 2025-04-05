# Define the source directories on Volume C
$MainSourceDir = "C:\Users\PLACEHOLDERCUNT\Documents"  # Main folder
$DesktopSourceDir = "C:\Users\PLACEHOLDERCUNT\Desktop"  # Desktop folder

# Define email addresses and keywords for categorization
$UniEmail = "PLACEHOLDER@CUNT.COM"
$PersonalEmail = "PLACEHOLDER@CUNT.COM"
$BusinessEmail = "PLACEHOLDER@CUNT.COM"

# Keywords for each category
$UniKeywords = @("pace", "edu", "course", "assignment", "syllabus", "university")
$BusinessKeywords = @("ggholdings", "invoice", "contract", "business", "client", "outlook", "report", "meeting", "deal")
$PersonalKeywords = @("yahoo", "personal", "photo", "family", "GeoffreyGeltrman", "vacation")

# File extensions for Notepad files and Pictures
$NotepadExtensions = @(".rtf", ".txt")
$PictureExtensions = @(".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tiff")
$ScreenshotKeywords = @("screenshot", "capture", "screen", "printscreen")

# Function to determine category and year
function Get-FileCategory {
    param (
        [string]$FilePath,
        [string]$BaseDir
    )
    $file = Get-Item $FilePath
    $year = $file.CreationTime.Year.ToString()  # Using CreationTime; switch to LastWriteTime if preferred
    $category = "Business"  # Default to Business

    # Convert file name to lowercase for matching
    $fileName = $file.Name.ToLower()

    # Check if it's a picture or screenshot
    if ($PictureExtensions -contains $file.Extension) {
        if ($ScreenshotKeywords | Where-Object { $fileName -match $_ } -or -not ($UniKeywords + $BusinessKeywords + $PersonalKeywords | Where-Object { $fileName -match $_ })) {
            return @{ Category = "Pictures"; Year = $year }
        }
    }

    # Check file name for email addresses or keywords
    if ($fileName -match [regex]::Escape($UniEmail) -or $UniKeywords | Where-Object { $fileName -match $_ }) {
        $category = "School"
    } elseif ($fileName -match [regex]::Escape($PersonalEmail) -or $PersonalKeywords | Where-Object { $fileName -match $_ }) {
        $category = "Personal"
    } elseif ($fileName -match [regex]::Escape($BusinessEmail) -or $BusinessKeywords | Where-Object { $fileName -match $_ }) {
        $category = "Business"
    }

    # Simplified content check (no .docx for speed)
    $textExtensions = @(".txt", ".rtf")
    if ($textExtensions -contains $file.Extension) {
        try {
            $content = Get-Content $FilePath -Raw
            if ($content) {
                $contentLower = $content.ToLower()
                if ($contentLower -match [regex]::Escape($UniEmail) -or $UniKeywords | Where-Object { $contentLower -match $_ }) {
                    $category = "School"
                } elseif ($contentLower -match [regex]::Escape($PersonalEmail) -or $PersonalKeywords | Where-Object { $contentLower -match $_ }) {
                    $category = "Personal"
                } elseif ($contentLower -match [regex]::Escape($BusinessEmail) -or $BusinessKeywords | Where-Object { $contentLower -match $_ }) {
                    $category = "Business"
                }
            }
        } catch {
            Write-Host "Could not read content of $($fileName): $_" -ForegroundColor Yellow
        }
    }

    return @{ Category = $category; Year = $year }
}

# Function to process a directory
function Organize-Files {
    param (
        [string]$SourceDir
    )
    Write-Host "Validating source directory: $SourceDir" -ForegroundColor Green
    while (-not (Test-Path $SourceDir)) {
        Write-Host "Error: Directory '$SourceDir' does not exist or is inaccessible." -ForegroundColor Red
        $SourceDir = Read-Host "Please enter a valid directory path (e.g., $SourceDir)"
        if ([string]::IsNullOrWhiteSpace($SourceDir)) {
            Write-Host "No path provided. Skipping this directory." -ForegroundColor Yellow
            return 0
        }
    }

    Write-Host "Organizing all files in: $SourceDir (covering all years of data)" -ForegroundColor Green
    $files = Get-ChildItem -Path $SourceDir -File
    $totalFiles = $files.Count
    $movedFiles = 0
    $counter = 0

    foreach ($file in $files) {
        $counter++
        Write-Progress -Activity "Processing files in $SourceDir" -Status "$counter of $totalFiles" -PercentComplete (($counter / $totalFiles) * 100)

        $result = Get-FileCategory -FilePath $file.FullName -BaseDir $SourceDir
        $category = $result.Category
        $year = $result.Year

        # Define destination path
        if ($NotepadExtensions -contains $file.Extension) {
            $destFolder = Join-Path -Path $SourceDir -ChildPath "$category\NotepadFiles\$year"
        } elseif ($category -eq "Pictures") {
            $destFolder = Join-Path -Path $SourceDir -ChildPath "Pictures\$year"
        } else {
            $destFolder = Join-Path -Path $SourceDir -ChildPath "$category\$year"
        }
        
        # Create the destination folder if it doesn't exist
        if (-not (Test-Path $destFolder)) {
            New-Item -Path $destFolder -ItemType Directory -Force | Out-Null
        }

        # Move the file
        try {
            $destPath = Join-Path -Path $destFolder -ChildPath $file.Name
            $i = 1
            while (Test-Path $destPath) {
                $newName = "$($file.BaseName)_$i$($file.Extension)"
                $destPath = Join-Path -Path $destFolder -ChildPath $newName
                $i++
            }
            Move-Item -Path $file.FullName -Destination $destPath -Force
            $movedFiles++
            Write-Host "Moved: $($file.Name) -> $destFolder/" -ForegroundColor Cyan
        } catch {
            Write-Host "Error moving $($file.Name): $_" -ForegroundColor Red
        }
    }

    Write-Progress -Activity "Processing files in $SourceDir" -Completed
    return $movedFiles
}

# Main execution
Write-Host "Starting comprehensive file organization..." -ForegroundColor Green
$totalMoved = 0

# Process the main source directory
$totalMoved += Organize-Files -SourceDir $MainSourceDir

# Process the Desktop directory
$totalMoved += Organize-Files -SourceDir $DesktopSourceDir

Write-Host "`nComprehensive organization complete! Moved $totalMoved files across all directories." -ForegroundColor Green