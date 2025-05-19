[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

Clear-Host

# Paths
$ConfigFile  = "$env:USERPROFILE\.config\fastfetch\config.jsonc"
$SourceFile  = "$env:USERPROFILE\Nextcloud\Phone\Download\Notes Graph\pages\Obsidian Vault\splashes.md"

# Validate files exist
if (-not (Test-Path $SourceFile)) {
    Write-Error "Source file not found: $SourceFile"
    exit 1
}
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Config file not found: $ConfigFile"
    exit 1
}

# Read a random line
$RandomLine = Get-Content $SourceFile | Get-Random

# Escape special characters for JSON insertion
function Escape-Json($text) {
    $text.Replace('\', '\\').Replace('"', '\"')
}
$EscapedRandom = Escape-Json $RandomLine

# Format both lines
$Indent = '    '
$OriginalFormattedLine = "$Indent`"format`": `"$EscapedRandom`""

$env:PYTHONIOENCODING = "utf-8"

# Translate the line
$TranslatedLine = try {
    $output = "$RandomLine" | & deepl '--fr' 'de' '--to' 'ja' '-s' '-t' '2147483647' 2>&1
    $output | Where-Object { $_ -match '\S' } | Select-Object -Last 1
} catch {
    "⚠️ Translation failed"
}

# Sanitize translation
$CleanTranslated = ($TranslatedLine -replace '[\x00-\x1F]', '').Trim()
$EscapedTranslated = Escape-Json $CleanTranslated
$TranslatedFormattedLine = "$Indent`"format`": `"$EscapedTranslated`""

# Update config file lines
$ConfigLines = Get-Content $ConfigFile

#REMEMBER YOU HAVE TO CHANGE THESE IF YOU CHANGE THE LINE THAT SHOULD BE REPLACED IN THE CONFIG
$ConfigLines[24] = $OriginalFormattedLine 
$ConfigLines[28] = $TranslatedFormattedLine

# Save updated config file as UTF-8 without BOM
Set-Content -Path $ConfigFile -Value $ConfigLines -Encoding utf8NoBOM

# Regenerate image for fastfetch display
$imageConverter = "$env:USERPROFILE\.config\fastfetch\ascii-image-converter.exe"
$imagePath = "$env:USERPROFILE\.config\fastfetch\image.jpg"
$outputPath = "$env:USERPROFILE\.config\fastfetch\image.txt"
& $imageConverter $imagePath -b -d 40,17 | Out-File -Encoding utf8NoBOM -FilePath $outputPath

# Run fastfetch
& fastfetch

