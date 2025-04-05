# File Organizer

A PowerShell script to declutter your computer by organizing files into `Business`, `School`, `Personal`, `Pictures`, and `NotepadFiles` subfolders, sorted by year. It processes a main directory (e.g., Documents) and your Desktop, making your loading screen less chaotic. Customize it to fit your life—whether it’s work, school, or personal chaos!

## Features
- **Categories**: Files go into `Business`, `School`, or `Personal` based on email addresses or keywords in names/content.
- **Pictures**: Screenshots (e.g., `screenshot.png`) and generic images go to `Pictures\Year`.
- **Notepad Files**: `.rtf` and `.txt` files go to `Category\NotepadFiles\Year`.
- **All Years**: Organizes all files, no date limit—perfect for years of data.
- **Desktop Cleanup**: Clears random files from your Desktop into organized folders.
- **Progress Bar**: Shows how far along it is while running.

## How to Use It

### Prerequisites
- **Windows**: Requires PowerShell (pre-installed on Windows 10/11).

### Step-by-Step Setup
1. **Download the Script**:
   - Clone this repo or download `organize_files.ps1`.

2. **Find Your Paths**:
   - Open File Explorer (`Win + E`).
   - Navigate to your main folder (e.g., Documents) and Desktop.
   - Right-click the address bar, select "Copy address as text" to get paths like:
     - Main folder: `C:\Users\YourUsername\Documents`
     - Desktop: `C:\Users\YourUsername\Desktop`
   - Or in PowerShell:
     - Run `cd C:\Users\YourUsername\Documents; Get-Location` to confirm.
     - Repeat for Desktop.

3. **Edit the Script**:
   - Open `organize_files.ps1` in a text editor (e.g., Notepad, VS Code).
   - **Paths**: Replace the placeholders at the top:
     ```powershell
     $MainSourceDir = "C:\Users\YourUsername\Documents"  # Your main folder
     $DesktopSourceDir = "C:\Users\YourUsername\Desktop"  # Your Desktop
     ```
   - **Emails**: Update these with your own:
     ```powershell
     $UniEmail = "your.university.email@school.edu"
     $PersonalEmail = "your.personal.email@example.com"
     $BusinessEmail = "your.business.email@example.com"
     ```
   - **Keywords**: Customize these arrays to match your file names:
     ```powershell
     $UniKeywords = @("school", "edu", "course", "assignment", "syllabus", "university")
     $BusinessKeywords = @("business", "invoice", "contract", "client", "report", "meeting", "deal")
     $PersonalKeywords = @("personal", "photo", "family", "vacation")
     ```
   - **File Types**: Add or remove extensions if needed:
     ```powershell
     $NotepadExtensions = @(".rtf", ".txt")
     $PictureExtensions = @(".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tiff")
     $ScreenshotKeywords = @("screenshot", "capture", "screen", "printscreen")
     ```

4. **Run the Script**:
   - Open PowerShell: `Win + X` > "Windows PowerShell".
   - Navigate to the script’s folder: `cd C:\Path\To\Your\Script`.
   - Allow execution (if prompted): `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`.
   - Execute: `.\organize_files.ps1`.
   - **Validation**: If a path is wrong, it’ll prompt you to enter a new one.

5. **Check the Results**:
   - Files move to subfolders like:
     - `Business\2023`, `School\NotepadFiles\2022`, `Pictures\2024`.
   - Watch the progress bar and `Moved: filename -> path/` messages.
   - It ends with: "Comprehensive organization complete! Moved X files across all directories."

## Troubleshooting
- **Path Errors**: If a directory doesn’t exist, enter a valid path when prompted. Use File Explorer or `Get-Location` to verify.
- **Permission Denied**: Run PowerShell as Administrator (`Win + X` > "Windows PowerShell (Admin)") and try again.
- **Stuck Script**: If it’s slow, check Task Manager for stuck processes; press `Ctrl + C` to stop and rerun.
- **Custom Sorting**: Want modified dates? Change `$file.CreationTime` to `$file.LastWriteTime` in `Get-FileCategory`.

## Customization Tips
- **Add Categories**: Edit `Get-FileCategory` to add new categories (e.g., "Hobbies") with keywords.
- **Change Defaults**: Swap `"Business"` to another category as the default.
- **More File Types**: Expand `$PictureExtensions` (e.g., `.webp`) or `$NotepadExtensions` (e.g., `.log`).

## License
Free to use, modify, and share—no formal license, just enjoy!

## Feedback
Got ideas or issues? Open an issue here or hit me up when you see my Twitter in the script’s output!
