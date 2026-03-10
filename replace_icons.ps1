Add-Type -AssemblyName System.Drawing

$src = 'C:\Users\sreen\.gemini\antigravity\brain\e4aac210-da9a-4734-a1bf-2843a1cb8262\gym_app_icon_1772291099131.png'
$webDir = 'C:\Users\sreen\OneDrive\Desktop\gym2\flutter_app\web'

function ResizeSave($source, $destPath, $size) {
    $img = [System.Drawing.Image]::FromFile($source)
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($img, 0, 0, $size, $size)
    $g.Dispose()
    $bmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $img.Dispose()
    Write-Host "Saved: $destPath ($size x $size)"
}

ResizeSave $src "$webDir\icons\Icon-192.png" 192
ResizeSave $src "$webDir\icons\Icon-512.png" 512
ResizeSave $src "$webDir\icons\Icon-maskable-192.png" 192
ResizeSave $src "$webDir\icons\Icon-maskable-512.png" 512
ResizeSave $src "$webDir\favicon.png" 32

Write-Host 'All icons replaced!'
