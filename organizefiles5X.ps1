<#
PLACEHOLDER ---> Customize this script for your needs!
1. Replace $MainSourceDir with your main folder path (e.g., "C:\Users\YourUsername\Documents").
2. Replace $DesktopSourceDir with your Desktop path (e.g., "C:\Users\YourUsername\Desktop").
3. Update $UniEmail, $PersonalEmail, and $BusinessEmail with your own email addresses for categorization.
4. Modify $UniKeywords, $BusinessKeywords, and $PersonalKeywords to match your file naming patterns.
5. Adjust $PictureExtensions, $ScreenshotKeywords, and $NotepadExtensions if you want different file types.
6. Run in PowerShell: Save as organize_files.ps1, navigate to its directory, and execute .\organize_files.ps1.
   - May need: Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
This script organizes all files by year into Business, School, Personal, Pictures, and NotepadFiles subfolders.
See README.md for detailed instructions!
#>

# Define the source directories (replace with your paths)
$MainSourceDir = "C:\Users\YourUsername\Documents"  # Main folder
$DesktopSourceDir = "C:\Users\YourUsername\Desktop"  # Desktop folder

# Define email addresses for categorization (replace with yours)
$UniEmail = "your.university.email@school.edu"
$PersonalEmail = "your.personal.email@example.com"
$BusinessEmail = "your.business.email@example.com"

# Keywords for each category (customize to your naming conventions)
$UniKeywords = @("school", "edu", "course", "assignment", "syllabus", "university")
$BusinessKeywords = @("business", "invoice", "contract", "client", "report", "meeting", "deal")
$PersonalKeywords = @("personal", "photo", "family", "vacation")

# File extensions for Notepad files and Pictures
$NotepadExtensions = @(".rtf", ".txt")
$PictureExtensions = @(".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tiff")
$ScreenshotKeywords = @("screenshot", "capture", "screen", "printscreen")

# Function to determine category and year
function Get-FileCategory {
    param (
        [string]$FilePath,
        [string]$BaseDir  # Base directory for relative folder creation
    )
    $file = Get-Item $FilePath
    $year = $file.CreationTime.Year.ToString()  # Using CreationTime; switch to LastWriteTime if preferred
    $category = "Business"  # Default category

    # Convert file name to lowercase for case-insensitive matching
    $fileName = $file.Name.ToLower()

    # Check if it's a picture or screenshot
    if ($PictureExtensions -contains $file.Extension) {
        # If it’s a screenshot or lacks specific category keywords, send to Pictures
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

    # Check content for text-based files
    $textExtensions = @(".txt", ".rtf", ".docx", ".pdf")
    if ($textExtensions -contains $file.Extension) {
        try {
            $content = switch ($file.Extension) {
                ".txt" { Get-Content $FilePath -Raw }
                ".rtf" { Get-Content $FilePath -Raw }
                ".docx" { 
                    $word = New-Object -ComObject Word.Application
                    $doc = $word.Documents.Open($FilePath)
                    $text = $doc.Content.Text
                    $doc.Close()
                    $word.Quit()
                    $text
                }
                ".pdf" { $fileName }  # Simplified to filename for PDF
            }
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
    $movedFiles = 0

    foreach ($file in $files) {
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
Write-Host "You're welcome, cuck! Follow me on Twitter @AKA_STUN for more goodies." -ForegroundColor Magenta