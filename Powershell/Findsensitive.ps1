# Prompt the user to input the directory to search
$directory = Read-Host "Please enter the directory path to search"

# Define patterns for sensitive data
$creditCardPattern = '\b(?:\d[ -]*?){13,16}\b'
$emailPattern = '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,7}\b'

# Check if the directory exists
if (-Not (Test-Path -Path $directory)) {
    Write-Error "The directory path '$directory' does not exist. Please provide a valid path."
    exit
}

# Get all files in the directory
try {
    $files = Get-ChildItem -Path $directory -Recurse -File
} catch {
    Write-Error "Error accessing files in the directory. Ensure you have the necessary permissions."
    exit
}

foreach ($file in $files) {
    try {
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw

        # Search for credit card numbers
        if ($content -match $creditCardPattern) {
            Write-Output "Credit card number found in file: $($file.FullName)"
        }

        # Search for email addresses
        if ($content -match $emailPattern) {
            Write-Output "Email address found in file: $($file.FullName)"
        }
    } catch {
        Write-Warning "Could not read file: $($file.FullName). Skipping."
    }
}