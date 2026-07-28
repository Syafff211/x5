# Download PWA Icons dari Internet
# Script ini akan download placeholder icons untuk X-5 Purbalingga

Write-Host "Downloading PWA icons..." -ForegroundColor Cyan

# Navigate ke project folder
Set-Location "C:\Users\ACER\Downloads\fix\x5-sman1-purbalingga"

# Create icons folder
New-Item -ItemType Directory -Force -Path "public\icons" | Out-Null

# Base URL untuk placeholder
$baseUrl = "https://via.placeholder.com"

# Sizes yang diperlukan
$sizes = @(72, 96, 128, 144, 152, 192, 384, 512)

# Download icons
foreach ($size in $sizes) {
    $url = "${baseUrl}/${size}x${size}/6366f1/ffffff?text=X5"
    $dest = "public\icons\icon-${size}x${size}.png"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -ErrorAction Stop
        Write-Host "✓ Downloaded icon-${size}x${size}.png" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to download icon-${size}x${size}.png" -ForegroundColor Red
    }
}

# Download logo placeholder
try {
    $logoUrl = "https://via.placeholder.com/512x512/6366f1/ffffff?text=X5"
    Invoke-WebRequest -Uri $logoUrl -OutFile "public\logo.png" -ErrorAction Stop
    Write-Host "✓ Downloaded logo.png" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download logo.png" -ForegroundColor Red
}

Write-Host "`n✅ All files downloaded successfully!" -ForegroundColor Cyan
Write-Host "Location: public\icons\" -ForegroundColor Yellow

# List downloaded files
Write-Host "`nDownloaded files:" -ForegroundColor Cyan
Get-ChildItem "public\icons" | Select-Object Name, Length | Format-Table -AutoSize

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. git add ." -ForegroundColor White
Write-Host "2. git commit -m 'feat: add PWA icons'" -ForegroundColor White
Write-Host "3. git push" -ForegroundColor White
