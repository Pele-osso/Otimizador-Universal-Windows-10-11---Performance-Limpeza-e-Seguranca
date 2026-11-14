@echo off
chcp 65001 >nul
title Otimizador Universal Windows 10/11 - Performance, Limpeza e Seguranca

:: Verifica se esta rodando como Administrador; se nao, solicita elevacao automatica
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Solicitando permissao de Administrador...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cls
echo ============================================================================
echo      OTIMIZADOR UNIVERSAL WINDOWS 10/11 (HARDWARE-AWARE / OPEN-SOURCE)
echo ============================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$lines = [System.IO.File]::ReadAllLines('%~f0', [System.Text.Encoding]::UTF8); $idx = [Array]::IndexOf($lines, ':: === INICIO_POWERSHELL ==='); $code = $lines[($idx+1)..($lines.Length-1)] -join [Environment]::NewLine; Invoke-Expression $code"
echo.
echo ============================================================================
echo   PROCESSO FINALIZADO! Reinicie o computador para aplicar todos os ajustes.
echo ============================================================================
pause
exit /b
:: === INICIO_POWERSHELL ===
$ErrorActionPreference = 'SilentlyContinue'
$desktop = [Environment]::GetFolderPath('Desktop')
$logFile = Join-Path $desktop ("Relatorio_Otimizacao_" + (Get-Date -Format "yyyy-MM-dd_HH-mm") + ".txt")

function Log($msg, $color = "Cyan") {
    Write-Host $msg -ForegroundColor $color
    Add-Content -Path $logFile -Value $msg -Encoding UTF8
}

Log "=== RELATORIO DE OTIMIZACAO UNIVERSAL WINDOWS 10/11 ===" "Green"
Log ("Data/Hora: " + (Get-Date))

# 1. Ponto de Restauracao Automatico
Log "`n[1/11] Criando Ponto de Restauracao do Sistema (Seguranca)..."
Enable-ComputerRestore -Drive $env:SystemDrive
Checkpoint-Computer -Description "Antes do Otimizador Universal" -RestorePointType "MODIFY_SETTINGS"

# 2. Deteccao Automatica de Hardware
Log "`n[2/11] Detectando Hardware (CPU, RAM, SSDs, HDDs, Notebook vs Desktop)..."
$cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$os = Get-CimInstance Win32_OperatingSystem
$ramGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$isLaptop = ($null -ne (Get-CimInstance Win32_Battery))
$sysDriveLetter = $env:SystemDrive.TrimEnd(':')
$sysPart = Get-Partition -DriveLetter $sysDriveLetter
$sysDisk = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq $sysPart.DiskNumber }
$isOsOnSSD = ($sysDisk.MediaType -eq 'SSD')
Log (" -> CPU: $cpu") "Gray"
Log (" -> RAM: $ramGB GB | Notebook: $isLaptop | Sistema ($sysDriveLetter`:) em SSD: $isOsOnSSD (" + $sysDisk.FriendlyName + ")") "Gray"

# 3. Verificacao e Limpeza de Entradas de Boot (Mantendo Apenas SSD se OS estiver em SSD)
Log "`n[3/11] Verificando Gerenciador de Boot (BCD / UEFI)..."
bcdedit /timeout 3 | Out-Null
if ($isOsOnSSD) {
    $hdds = Get-PhysicalDisk | Where-Object { $_.MediaType -eq 'HDD' }
    $fwEnum = bcdedit /enum firmware
    foreach ($hdd in $hdds) {
        $hddName = [Regex]::Escape($hdd.FriendlyName.Trim())
        if ($hddName) {
            $blocks = ($fwEnum -join "`n") -split "(?=\r?\nidentificador|\r?\nidentifier)"
            foreach ($b in $blocks) {
                if ($b -match $hddName -and $b -match '(\{[0-9a-fA-F\-]+\})') {
                    $guid = $matches[1]
                    if ($guid -notin @('{bootmgr}', '{current}', '{fwbootmgr}')) {
                        bcdedit /displayorder $guid /remove | Out-Null
                        bcdedit /delete $guid | Out-Null
                        Log (" -> Removida entrada de boot secundaria do HD mecanico: " + $hdd.FriendlyName + " ($guid)") "Yellow"
                    }
                }
            }
        }
    }
}

# 4. Seguranca: Windows Defender, Excecoes de Ameacas e Blindagem do Hosts
Log "`n[4/11] Verificando Windows Defender, Excecoes e Blindando Arquivo Hosts..."
Set-MpPreference -DisableRealtimeMonitoring $false
$prefs = Get-MpPreference
if ($prefs.ThreatIDDefaultAction_Ids) {
    foreach ($tid in $prefs.ThreatIDDefaultAction_Ids) {
        Remove-MpPreference -ThreatIDDefaultAction_Ids $tid
    }
    Log " -> Removidas excecoes de ameacas permitidas (ThreatIDDefaultAction) no Windows Defender." "Yellow"
}
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
if (Test-Path $hostsPath) {
    $hLines = Get-Content $hostsPath
    $changedHosts = $false
    $newH = foreach ($l in $hLines) {
        if ($l -match 'checkhost\.local') {
            $changedHosts = $true
            continue
        } elseif ($l -match '^\s*109\.94\.209\.70\s+(\S+)') {
            $changedHosts = $true
            "0.0.0.0 $($matches[1]) # Bloqueado"
        } else {
            $l
        }
    }
    if ($changedHosts) {
        Set-Content -Path $hostsPath -Value $newH -Encoding ASCII
        ipconfig /flushdns | Out-Null
        Log " -> Redirecionamentos suspeitos no arquivo hosts bloqueados em 0.0.0.0." "Yellow"
    }
}

# 5. Plano de Energia (Desempenho Maximo sem duplicatas + Ajustes PCIe/USB/HD)
Log "`n[5/11] Otimizando Plano de Energia (Desempenho Maximo)..."
$ultScheme = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
$plansOutput = powercfg /list
$ultGuids = @()
foreach ($line in $plansOutput) {
    if ($line -match '([0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}).*(Desempenho M|Ultimate Performance)') {
        $ultGuids += $matches[1]
    }
}
$ultGuids = $ultGuids | Select-Object -Unique
if ($ultGuids.Count -eq 0) {
    $dupOut = powercfg -duplicatescheme $ultScheme
    if ($dupOut -match '([0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12})') {
        $activeGuid = $matches[1]
    } else {
        $activeGuid = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
    }
} else {
    $activeGuid = $ultGuids[0]
    if ($ultGuids.Count -gt 1) {
        for ($i = 1; $i -lt $ultGuids.Count; $i++) {
            powercfg /delete $ultGuids[$i] 2>$null
        }
    }
}
powercfg /setactive $activeGuid
powercfg /change disk-timeout-ac 0
powercfg /change standby-timeout-ac 0
# PCIe Link State Power Management -> Off (0)
powercfg /setacvalueindex $activeGuid 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
# USB Selective Suspend -> Disabled (0)
powercfg /setacvalueindex $activeGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setactive $activeGuid
if (-not $isLaptop) {
    powercfg /h off
}
Log " -> Plano Desempenho Maximo ativo ($activeGuid) | Disk Idle=0 | PCIe ASPM=Off | USB Suspend=Off" "Gray"

# 6. Otimizacao de Discos (TRIM em todos os SSDs / Desativar Indexacao em todos os HDDs)
Log "`n[6/11] Otimizando Todos os Discos (SSDs e HDDs)..."
fsutil behavior set DisableDeleteNotify 0 | Out-Null
if ($isOsOnSSD) {
    fsutil behavior set DisableLastAccess 1 | Out-Null
}
Get-PhysicalDisk | ForEach-Object {
    $disk = $_
    $parts = Get-Partition -DiskNumber $disk.DeviceId | Where-Object { $_.DriveLetter }
    foreach ($p in $parts) {
        $dl = $p.DriveLetter
        if ($disk.MediaType -eq 'SSD') {
            Log (" -> Executando TRIM no SSD " + $dl + ": (" + $disk.FriendlyName + ")") "Gray"
            Optimize-Volume -DriveLetter $dl -ReTrim | Out-Null
        } elseif ($disk.MediaType -eq 'HDD') {
            Log (" -> Desativando indexacao pesada no HD mecanico " + $dl + ": (" + $disk.FriendlyName + ")") "Gray"
            $volWmi = Get-CimInstance Win32_Volume -Filter "DriveLetter = '$($dl):'"
            if ($volWmi -and $volWmi.IndexingEnabled) {
                Set-CimInstance -InputObject $volWmi -Property @{IndexingEnabled=$false}
            }
        }
    }
}

# 7. Dimensionamento Inteligente do Pagefile (Memoria Virtual)
Log "`n[7/11] Configurando Memoria Virtual (Pagefile) Inteligente..."
$sysVol = Get-Volume -DriveLetter $sysDriveLetter
$freeGB = [math]::Round($sysVol.SizeRemaining / 1GB, 1)
$initMB = if ($freeGB -lt 35) { 2048 } else { 4096 }
$maxMB = if ($ramGB -le 8) { 12288 } else { 8192 }
$cs = Get-CimInstance Win32_ComputerSystem
if ($cs.AutomaticManagedPagefile) {
    Set-CimInstance -InputObject $cs -Property @{AutomaticManagedPagefile=$false}
}
Get-CimInstance Win32_PageFileSetting | Where-Object { $_.Name -notlike "$($sysDriveLetter):*" } | Remove-CimInstance
$pf = Get-CimInstance Win32_PageFileSetting | Where-Object { $_.Name -like "$($sysDriveLetter):*" }
if ($pf) {
    Set-CimInstance -InputObject $pf -Property @{InitialSize=$initMB; MaximumSize=$maxMB}
} else {
    New-CimInstance -ClassName Win32_PageFileSetting -Property @{Name="$($sysDriveLetter):\pagefile.sys"; InitialSize=$initMB; MaximumSize=$maxMB} | Out-Null
}
Log (" -> Pagefile ajustado em " + $sysDriveLetter + ":\pagefile.sys (Inicial: $initMB MB / Maximo: $maxMB MB)") "Gray"

# 8. Desativacao de Servicos de Telemetria, Bloat e Coleta Oculta (Padrao WinUtil / AtlasOS)
Log "`n[8/11] Desativando Servicos de Telemetria e Coleta em Segundo Plano..."
$svcsToDisable = @(
    'DiagTrack',
    'dmwappushservice',
    'MapsBroker',
    'lfsvc',
    'RetailDemo',
    'Wisvc',
    'ESRV_SVC_QUEENCREEK',
    'USER_ESRV_SVC_QUEENCREEK',
    'SystemUsageReportSvc_QUEENCREEK',
    'IntelCollectorService',
    'IntelTelemetryAgent',
    'Intel(R) SUR QC SAM'
)
if ($isOsOnSSD) {
    $svcsToDisable += 'SysMain'
    Disable-MMAgent -ApplicationPreLaunch
}
foreach ($s in $svcsToDisable) {
    if (Get-Service -Name $s) {
        Stop-Service -Name $s -Force
        Set-Service -Name $s -StartupType Disabled
    }
}
Unregister-ScheduledTask -TaskName 'USER_ESRV_SVC_QUEENCREEK' -Confirm:$false
Get-ScheduledTask -TaskName 'SoftLandingCreativeManagementTask' | Disable-ScheduledTask | Out-Null

New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0 -Type DWord -Force
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -Value 1 -Type DWord -Force
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -Value 1 -Type DWord -Force

# 9. Limpeza de Launchers Pesados na Inicializacao do Windows (Run)
Log "`n[9/11] Aliviando Inicializacao do Windows (Removendo Auto-Start de Launchers Pesados)..."
$bloatRun = @('Steam','EpicGamesLauncher','EADM','RiotClient','Rave','Battle.net','Ubisoft Game Launcher','GalaxyClient')
foreach ($app in $bloatRun) {
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $app
}
if ((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord') -and (Get-ItemProperty 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord')) {
    Remove-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord'
}

# 10. Otimizacoes de GPU (HAGS), Game Mode, GameDVR, Contraste/Cor, Rede e Latencia de Interface
Log "`n[10/11] Aplicando Otimizacoes de GPU (HAGS), Jogos, Contraste/Cor, Rede e Interface..."
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'HwSchMode' -Value 2 -Type DWord -Force
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' -Name 'OverlayTestMode' -ErrorAction SilentlyContinue
New-Item -Path 'HKCU:\Software\Microsoft\GameBar' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 1 -Type DWord -Force
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AutoGameModeEnabled' -Value 1 -Type DWord -Force
New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0 -Type DWord -Force
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0 -Type DWord -Force
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_FSEBehaviorMode' -Value 0 -Type DWord -Force
Remove-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_HonorUserFSEBehaviorMode' -ErrorAction SilentlyContinue
if (Test-Path 'HKCU:\Software\Microsoft\ColorFiltering') {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\ColorFiltering' -Name 'Active' -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# Protecao universal contra filtro branco / contraste lavado (Gama 1.0, RGB Completo 0-255, DDC monitor)
$csColorFix = @'
using System;
using System.Runtime.InteropServices;
public static class WinOptDisplayHelper {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct PHYSICAL_MONITOR {
        public IntPtr hPhysicalMonitor;
        [MarshalAs(LayoutKind.ByValTStr, SizeConst = 128)]
        public string szPhysicalMonitorDescription;
    }
    public delegate bool MonitorEnumProc(IntPtr hMonitor, IntPtr hdcMonitor, IntPtr lprcMonitor, IntPtr dwData);
    [DllImport("user32.dll")] static extern bool EnumDisplayMonitors(IntPtr hdc, IntPtr lprcClip, MonitorEnumProc lpfnEnum, IntPtr dwData);
    [DllImport("dxva2.dll")] static extern bool GetNumberOfPhysicalMonitorsFromHMONITOR(IntPtr hMonitor, out uint pdwNumberOfPhysicalMonitors);
    [DllImport("dxva2.dll")] static extern bool GetPhysicalMonitorsFromHMONITOR(IntPtr hMonitor, uint dwPhysicalMonitorArraySize, [Out] PHYSICAL_MONITOR[] pPhysicalMonitorArray);
    [DllImport("dxva2.dll")] static extern bool DestroyPhysicalMonitors(uint dwPhysicalMonitorArraySize, PHYSICAL_MONITOR[] pPhysicalMonitorArray);
    [DllImport("dxva2.dll")] static extern bool GetVCPFeatureAndVCPFeatureReply(IntPtr hMonitor, byte bVCPCode, out uint pvct, out uint pdwCurrentValue, out uint pdwMaximumValue);
    [DllImport("dxva2.dll")] static extern bool SetVCPFeature(IntPtr hMonitor, byte bVCPCode, uint dwNewValue);
    [DllImport("gdi32.dll")] static extern IntPtr CreateDC(string d, string dev, string o, IntPtr p);
    [DllImport("gdi32.dll")] static extern bool DeleteDC(IntPtr h);
    [DllImport("gdi32.dll")] static extern bool SetDeviceGammaRamp(IntPtr h, ushort[] r);
    [DllImport("kernel32.dll")] static extern IntPtr LoadLibrary(string n);
    [DllImport("kernel32.dll")] static extern IntPtr GetProcAddress(IntPtr m, string n);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)] delegate IntPtr NvQI(uint id);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)] delegate int NvInit();
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)] delegate int NvEnum(IntPtr[] h, out int c);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)] delegate int NvDisp(IntPtr h, [Out] byte[] b, ref uint c, uint f);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)] delegate int NvCol(uint id, byte[] c);

    public static void Repair() {
        IntPtr hdc = CreateDC("DISPLAY", null, null, IntPtr.Zero);
        if (hdc != IntPtr.Zero) {
            try {
                ushort[] r = new ushort[768];
                for (int i = 0; i < 256; i++) { ushort v = (ushort)(i * 257); r[i] = v; r[i + 256] = v; r[i + 512] = v; }
                SetDeviceGammaRamp(hdc, r);
            } finally { DeleteDC(hdc); }
        }
        try {
            IntPtr mod = LoadLibrary("nvapi64.dll");
            if (mod != IntPtr.Zero) {
                IntPtr qiPtr = GetProcAddress(mod, "nvapi_QueryInterface");
                if (qiPtr != IntPtr.Zero) {
                    var qi = Marshal.GetDelegateForFunctionPointer<NvQI>(qiPtr);
                    IntPtr iP = qi(0x0150E828), eP = qi(0xE5AC921F), dP = qi(0x0078DBA2), cP = qi(0x92F9D80D);
                    if (iP != IntPtr.Zero && eP != IntPtr.Zero && dP != IntPtr.Zero && cP != IntPtr.Zero && Marshal.GetDelegateForFunctionPointer<NvInit>(iP)() == 0) {
                        var gpus = new IntPtr[64]; int gc = 0;
                        if (Marshal.GetDelegateForFunctionPointer<NvEnum>(eP)(gpus, out gc) == 0) {
                            var gd = Marshal.GetDelegateForFunctionPointer<NvDisp>(dP);
                            var col = Marshal.GetDelegateForFunctionPointer<NvCol>(cP);
                            for (int g = 0; g < gc; g++) {
                                uint cnt = 0;
                                if (gd(gpus[g], null, ref cnt, 0) != 0 || cnt == 0) continue;
                                byte[] buf = new byte[16 * cnt];
                                for (uint k = 0; k < cnt; k++) BitConverter.GetBytes((1u << 16) | 16u).CopyTo(buf, (int)(k * 16));
                                if (gd(gpus[g], buf, ref cnt, 0) != 0) continue;
                                for (int k = 0; k < cnt; k++) {
                                    uint did = BitConverter.ToUInt32(buf, k * 16 + 8);
                                    if (did == 0) continue;
                                    byte[] cb = new byte[24];
                                    BitConverter.GetBytes((5u << 16) | 24u).CopyTo(cb, 0);
                                    BitConverter.GetBytes((ushort)24).CopyTo(cb, 4);
                                    cb[6] = 1;
                                    if (col(did, cb) == 0 && (cb[7] != 0 || cb[9] != 0)) {
                                        cb[6] = 2; cb[7] = 0; cb[8] = 0; cb[9] = 0;
                                        BitConverter.GetBytes(2u).CopyTo(cb, 12);
                                        BitConverter.GetBytes(1u).CopyTo(cb, 16);
                                        col(did, cb);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {}
        try {
            EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero, delegate(IntPtr hm, IntPtr dc, IntPtr rc, IntPtr d) {
                uint n = 0;
                if (!GetNumberOfPhysicalMonitorsFromHMONITOR(hm, out n) || n == 0) return true;
                var arr = new PHYSICAL_MONITOR[n];
                if (!GetPhysicalMonitorsFromHMONITOR(hm, n, arr)) return true;
                try {
                    foreach (var pm in arr) {
                        uint t, cCur = 50, cMax = 100, bCur = 80, bMax = 100;
                        bool hasC = GetVCPFeatureAndVCPFeatureReply(pm.hPhysicalMonitor, 0x12, out t, out cCur, out cMax);
                        bool hasB = GetVCPFeatureAndVCPFeatureReply(pm.hPhysicalMonitor, 0x10, out t, out bCur, out bMax);
                        bool chg = false;
                        if (hasC && cMax >= 50 && cCur < 30) { SetVCPFeature(pm.hPhysicalMonitor, 0x12, 50); chg = true; }
                        foreach (byte code in new byte[] { 0x6C, 0x6E, 0x70 }) {
                            uint vCur = 50, vMax = 100;
                            if (GetVCPFeatureAndVCPFeatureReply(pm.hPhysicalMonitor, code, out t, out vCur, out vMax) && vMax >= 50 && vCur > 55) { SetVCPFeature(pm.hPhysicalMonitor, code, 50); chg = true; }
                        }
                        if (chg && hasB && bMax >= 50 && bCur >= 95) SetVCPFeature(pm.hPhysicalMonitor, 0x10, 80);
                    }
                } finally { DestroyPhysicalMonitors(n, arr); }
                return true;
            }, IntPtr.Zero);
        } catch {}
    }
}
'@
if (-not ([System.Management.Automation.PSTypeName]'WinOptDisplayHelper').Type) {
    Add-Type -TypeDefinition $csColorFix -ErrorAction SilentlyContinue
}
try { [WinOptDisplayHelper]::Repair(); Log " -> Contraste, Gama linear 1.0, RGB Completo (0-255) e DDC do monitor verificados." "Gray" } catch {}

$mm = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
Set-ItemProperty -Path $mm -Name 'SystemResponsiveness' -Value 10 -Type DWord -Force
Set-ItemProperty -Path $mm -Name 'NetworkThrottlingIndex' -Value 0xffffffff -Type DWord -Force
if (Test-Path "$mm\Tasks\Games") {
    Set-ItemProperty -Path "$mm\Tasks\Games" -Name 'GPU Priority' -Value 8 -Type DWord -Force
    Set-ItemProperty -Path "$mm\Tasks\Games" -Name 'Priority' -Value 6 -Type DWord -Force
    Set-ItemProperty -Path "$mm\Tasks\Games" -Name 'Scheduling Category' -Value 'High' -Type String -Force
    Set-ItemProperty -Path "$mm\Tasks\Games" -Name 'SFIO Priority' -Value 'High' -Type String -Force
}
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '0' -Type String -Force

# 11. Limpeza de Arquivos Temporarios, Caches, Lixeiras e Reparo DISM + SFC
Log "`n[11/11] Limpando Temporarios, Caches, Lixeiras e Verificando Integridade do Windows..."
$junkPaths = @(
    "$env:LOCALAPPDATA\Temp\*",
    "$env:SystemRoot\Temp\*",
    "$env:LOCALAPPDATA\CrashDumps",
    "$env:LOCALAPPDATA\SquirrelTemp",
    "$env:LOCALAPPDATA\ads_event_reporter",
    "$env:LOCALAPPDATA\appsflyer",
    "$env:LOCALAPPDATA\UniSDK",
    "$env:LOCALAPPDATA\UniSDK_FirstOpen",
    "$env:LOCALAPPDATA\UniCompactView",
    "$env:APPDATA\hydralauncher",
    "$env:SystemDrive\`$SysReset"
)
foreach ($jp in $junkPaths) {
    Remove-Item -Path $jp -Recurse -Force
}
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $root = $_.Root
    foreach ($f in @("found.000", "DumpStack.log.tmp", "bootTel.dat")) {
        $target = Join-Path $root $f
        if (Test-Path $target) { Remove-Item -Path $target -Recurse -Force }
    }
    $stremioCache = Join-Path $root "stremio\stremio-cache"
    if (Test-Path $stremioCache) { Remove-Item -Path "$stremioCache\*" -Recurse -Force }
}
Clear-RecycleBin -Force

Log " -> Verificando saude da imagem do Windows (DISM /CheckHealth)..." "Gray"
$dismCheck = DISM.exe /Online /Cleanup-Image /CheckHealth
if ($dismCheck -match 'repar|repair') {
    Log " -> Corrupcao detectada! Executando DISM /RestoreHealth..." "Yellow"
    DISM.exe /Online /Cleanup-Image /RestoreHealth
}
Log " -> Executando verificador de arquivos do sistema (sfc /scannow)..." "Gray"
sfc /scannow

Log "`n=== OTIMIZACAO UNIVERSAL CONCLUIDA COM SUCESSO! ===" "Green"
Write-Host "Relatorio completo salvo em: $logFile" -ForegroundColor Green