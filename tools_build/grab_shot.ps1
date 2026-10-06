# Capture the MVZ2.exe main window client area (or full screen) to a PNG.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File grab_shot.ps1 -Out <path.png> [-FullScreen]
# NOTE: ASCII-only source on purpose -- PowerShell 5.1 reads .ps1 as the ANSI codepage (GBK here),
# which corrupts UTF-8 comments and breaks parsing.
param(
    [Parameter(Mandatory = $true)][string]$Out,
    [switch]$FullScreen
)

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinApi {
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd, ref POINT lpPoint);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("shcore.dll")] public static extern int SetProcessDpiAwareness(int value);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
}
"@

try { [void][WinApi]::SetProcessDpiAwareness(2) } catch { }

$bounds = $null
$target = "fullscreen"

if (-not $FullScreen) {
    $proc = Get-Process -Name MVZ2 -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($proc -ne $null) {
        $h = $proc.MainWindowHandle
        [void][WinApi]::ShowWindow($h, 5)
        [void][WinApi]::SetForegroundWindow($h)
        Start-Sleep -Milliseconds 700
        $fg = [WinApi]::GetForegroundWindow()
        $cr = New-Object WinApi+RECT
        if ([WinApi]::GetClientRect($h, [ref]$cr)) {
            $origin = New-Object WinApi+POINT
            $origin.X = 0
            $origin.Y = 0
            [void][WinApi]::ClientToScreen($h, [ref]$origin)
            $w = $cr.Right - $cr.Left
            $hgt = $cr.Bottom - $cr.Top
            if ($w -gt 0 -and $hgt -gt 0) {
                $bounds = New-Object System.Drawing.Rectangle($origin.X, $origin.Y, $w, $hgt)
                $target = "client hwnd=$h pid=$($proc.Id) origin=$($origin.X),$($origin.Y) size=${w}x${hgt} foreground=$($fg -eq $h)"
            }
        }
    }
}

if ($bounds -eq $null) {
    $bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $target = "fullscreen $($bounds.Width)x$($bounds.Height)"
}

$bmp = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
$gfx.Dispose()
$dir = Split-Path -Parent $Out
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "saved=$Out target=$target"
