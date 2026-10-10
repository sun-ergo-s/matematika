# Generuje ikony do icons/ (System.Drawing, Windows PowerShell 5.1).
# Pouzitie: powershell -File tools\make-icons.ps1 -OutDir icons
param([string]$OutDir = (Join-Path $PSScriptRoot '..\icons'))
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force $OutDir | Out-Null

$purple = [System.Drawing.ColorTranslator]::FromHtml('#6c5ce7')

# $rounded: zaoblene rohy (favicon, bezna ikona); inak plny stvorec (iOS a maskable si ikonu orezu samy)
# $scale: velkost obsahu (maskable potrebuje bezpecnu zonu, preto mensi)
function Make-Icon([int]$size, [string]$name, [bool]$rounded, [double]$scale) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.TextRenderingHint = 'AntiAliasGridFit'
  $g.Clear([System.Drawing.Color]::Transparent)

  $brush = New-Object System.Drawing.SolidBrush $purple
  if ($rounded) {
    $r = [int]($size * 0.22); $d = $r * 2; $s = $size - 1
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc(0, 0, $d, $d, 180, 90); $p.AddArc($s - $d, 0, $d, $d, 270, 90)
    $p.AddArc($s - $d, $s - $d, $d, $d, 0, 90); $p.AddArc(0, $s - $d, $d, $d, 90, 90)
    $p.CloseFigure(); $g.FillPath($brush, $p)
  } else {
    $g.FillRectangle($brush, 0, 0, $size, $size)
  }

  # pismeno M (Matematika), na stred
  $c = $size / 2.0
  $fontPx = $size * 0.62 * $scale
  $font = New-Object System.Drawing.Font 'Arial Black', ([float]$fontPx), ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = 'Center'; $sf.LineAlignment = 'Center'
  $rect = New-Object System.Drawing.RectangleF ([float]($c - $size)), ([float]($c + $size * 0.03 * $scale - $size)), ([float]($size * 2)), ([float]($size * 2))
  $g.DrawString('M', $font, [System.Drawing.Brushes]::White, $rect, $sf)

  $bmp.Save((Join-Path $OutDir $name), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}

Make-Icon 32  'favicon-32.png'        $true  1.0
Make-Icon 64  'favicon-64.png'        $true  1.0
Make-Icon 192 'icon-192.png'          $true  0.9
Make-Icon 512 'icon-512.png'          $true  0.9
Make-Icon 512 'icon-maskable-512.png' $false 0.72
Make-Icon 180 'apple-touch-icon.png'  $false 0.9
Get-ChildItem $OutDir | Select-Object Name, Length
