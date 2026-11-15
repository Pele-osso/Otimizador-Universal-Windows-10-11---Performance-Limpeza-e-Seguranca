@echo off
chcp 65001 >nul
title Otimizador Universal Windows 10/11 - Performance, Limpeza e Seguranca

set "OTIMIZADOR_ARGS=%~1"
set "OTIMIZADOR_SELF=%~f0"

:: Verifica se esta rodando como Administrador; se nao, solicita elevacao automatica
if /i "%OTIMIZADOR_ARGS%"=="-verificar" goto :RunPS
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Solicitando permissao de Administrador...
    if "%OTIMIZADOR_ARGS%"=="" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:OTIMIZADOR_SELF -Verb RunAs"
    ) else (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:OTIMIZADOR_SELF -ArgumentList $env:OTIMIZADOR_ARGS -Verb RunAs"
    )
    exit /b
)

:RunPS
cls
echo ============================================================================
echo      OTIMIZADOR UNIVERSAL WINDOWS 10/11 (HARDWARE-AWARE / OPEN-SOURCE)
echo ============================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$lines = [System.IO.File]::ReadAllLines($env:OTIMIZADOR_SELF, [System.Text.Encoding]::UTF8); $idx = [Array]::IndexOf($lines, ':: === INICIO_POWERSHELL ==='); $code = $lines[($idx+1)..($lines.Length-1)] -join [Environment]::NewLine; & ([ScriptBlock]::Create($code))" & exit /b
:: === INICIO_POWERSHELL ===
$ErrorActionPreference = 'SilentlyContinue'
$DefaultOtimRawUrl = 'https://raw.githubusercontent.com/Pele-osso/Otimizador-Universal-Windows-10-11---Performance-Limpeza-e-Seguranca/main/Otimizador_Universal_Windows.bat'
$OtimStateDir      = Join-Path $env:ProgramData 'OtimizadorUniversal'
$OtimStateFile     = Join-Path $OtimStateDir 'update_state.json'
$otimArgNorm       = ($env:OTIMIZADOR_ARGS + '').Trim().ToLower()
$desktop           = [Environment]::GetFolderPath('Desktop')
$logFile           = Join-Path $desktop ("Relatorio_Otimizacao_" + (Get-Date -Format "yyyy-MM-dd_HH-mm") + ".txt")

function Log($msg, $color = "Cyan") {
    Write-Host $msg -ForegroundColor $color
    if ($otimArgNorm -ne '-verificar') { Add-Content -Path $logFile -Value $msg -Encoding UTF8 }
}

function Get-OtimHardwareSnapshot {
    $cpuObj = Get-CimInstance Win32_Processor | Select-Object -First 1
    $osObj  = Get-CimInstance Win32_OperatingSystem | Select-Object -First 1
    $gpuCtl = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue)
    $gpuMain = $gpuCtl | Where-Object { $_.Name -match 'NVIDIA|AMD|Radeon|Arc' } | Select-Object -First 1
    if (-not $gpuMain) { $gpuMain = $gpuCtl | Select-Object -First 1 }
    $gpuName = if ($gpuMain) { $gpuMain.Name } else { 'GPU Desconhecida' }
    $vendor  = if ($gpuName -match 'NVIDIA') { 'NVIDIA' } elseif ($gpuName -match 'AMD|Radeon') { 'AMD' } elseif ($gpuName -match 'Intel') { 'Intel' } else { 'Other' }
    $vramMB  = if ($gpuMain -and $gpuMain.AdapterRAM) { [math]::Round($gpuMain.AdapterRAM / 1MB, 0) } else { 0 }
    $drvVer  = if ($gpuMain -and $gpuMain.DriverVersion) { $gpuMain.DriverVersion } else { '' }
    $cudaVer = ''; $cudaNum = 0.0
    $nvSmi = @((Get-Command 'nvidia-smi.exe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source), 'C:\Windows\System32\nvidia-smi.exe', 'C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe') | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
    if ($vendor -eq 'NVIDIA' -and $nvSmi) {
        $m = (& $nvSmi --query-gpu=memory.total,driver_version --format=csv,noheader,nounits 2>$null | Select-Object -First 1)
        if ($m -match '^([\d\.]+),\s*([^\s,]+)') {
            $tmpV = 0.0; if ([double]::TryParse($Matches[1], [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$tmpV) -and $tmpV -gt 0) { $vramMB = [int][math]::Round($tmpV) }
            $drvVer = $Matches[2]
        }
        $hdr = (& $nvSmi 2>$null | Out-String)
        if ($hdr -match 'CUDA Version:\s*([\d\.]+)') {
            $cudaVer = $Matches[1]
            [void][double]::TryParse($cudaVer, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$cudaNum)
        }
    }
    $isPascalOrOlder = ($vendor -eq 'NVIDIA') -and ($gpuName -match 'GTX\s*(7\d\d|8\d\d|9\d\d|10\d\d|16\d\d)|GT\s*\d+|MX\d+|TITAN\s*(X|Xp|V)?\b')
    $sysLet  = $env:SystemDrive.TrimEnd(':')
    $sysPart = Get-Partition -DriveLetter $sysLet -ErrorAction SilentlyContinue
    $sysDisk = if ($sysPart) { Get-PhysicalDisk | Where-Object { $_.DeviceId -eq $sysPart.DiskNumber } | Select-Object -First 1 } else { $null }
    return [PSCustomObject]@{
        CpuName         = ($cpuObj.Name -replace '\s+', ' ').Trim()
        RamTotalGB      = [math]::Round($osObj.TotalVisibleMemorySize / 1MB, 1)
        IsLaptop        = ($null -ne (Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue))
        SysDriveLetter  = $sysLet
        SysDisk         = $sysDisk
        IsOsOnSSD       = ($sysDisk -and $sysDisk.MediaType -eq 'SSD')
        GpuName         = $gpuName
        GpuVendor       = $vendor
        VramMB          = $vramMB
        LowVram         = ($vramMB -gt 0 -and $vramMB -le 4200)
        IsPascalOrOlder = $isPascalOrOlder
        NoTensorCores   = ($vendor -ne 'NVIDIA') -or $isPascalOrOlder
        DriverVersion   = $drvVer
        CudaVersion     = $cudaVer
        CudaNumeric     = $cudaNum
        OsBuild         = [System.Environment]::OSVersion.Version.Build
    }
}

function Get-OtimGitHubRelease {
    param([string]$Repo, [string]$AssetRegex = '\.(zip|7z)$')
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
    $headers = @{ 'User-Agent' = 'OtimizadorUniversalUpdater'; 'Cache-Control' = 'no-cache' }
    $tag = $null; $assets = @()
    try {
        $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers $headers -TimeoutSec 15
        if ($rel -and $rel.tag_name) { $tag = ($rel.tag_name + '').Trim(); if ($rel.assets) { $assets = @($rel.assets) } }
    } catch {
        try {
            $resp = Invoke-WebRequest -Uri "https://github.com/$Repo/releases/latest" -Headers $headers -MaximumRedirection 5 -UseBasicParsing -TimeoutSec 15
            if ($resp.BaseResponse -and $resp.BaseResponse.ResponseUri -and $resp.BaseResponse.ResponseUri.AbsoluteUri -match '/releases/tag/([^/?#]+)') {
                $tag = [Uri]::UnescapeDataString($Matches[1]).Trim()
            }
        } catch {}
    }
    $sel = if ($assets.Count -gt 0 -and $AssetRegex) { $assets | Where-Object { $_.name -match $AssetRegex } | Select-Object -First 1 } else { $null }
    if (-not $sel -and $assets.Count -gt 0) { $sel = $assets | Where-Object { $_.name -match '\.(zip|7z)$' } | Select-Object -First 1 }
    return [PSCustomObject]@{ Repo=$Repo; TagName=$tag; AssetName=if ($sel){$sel.name}else{$null}; DownloadUrl=if ($sel){$sel.browser_download_url}else{$null} }
}

function Invoke-OtimizadorOnlineUpdate {
    param($Hw, [switch]$CheckOnly)
    if (-not $Hw) { $Hw = Get-OtimHardwareSnapshot }
    if (-not [System.Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable()) {
        Log " -> Sem internet no momento; verificacao online ignorada." "Yellow"
        return [PSCustomObject]@{ SelfUpdated=$false }
    }
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    # A. Auto-atualizacao do proprio Otimizador_Universal_Windows.bat via GitHub (verificando AST antes de gravar)
    $selfPath = $env:OTIMIZADOR_SELF
    $selfUpdated = $false; $remoteAvail = $false
    try {
        $resp = Invoke-WebRequest -Uri $DefaultOtimRawUrl -Headers @{ 'User-Agent'='OtimizadorUniversalUpdater'; 'Cache-Control'='no-cache' } -UseBasicParsing -TimeoutSec 15
        $remTxt = $resp.Content
        if ($remTxt -and $remTxt.Length -ge 4000 -and $remTxt -match ':: === INICIO_POWERSHELL ===') {
            $lines = $remTxt -split "\r?\n"
            $idx = [Array]::IndexOf($lines, ':: === INICIO_POWERSHELL ===')
            $psBody = $lines[($idx+1)..($lines.Length-1)] -join "`n"
            $errs = $null
            [void][System.Management.Automation.Language.Parser]::ParseInput($psBody, [ref]$null, [ref]$errs)
            if ($null -eq $errs -or $errs.Count -eq 0) {
                $enc = New-Object System.Text.UTF8Encoding($false)
                $sha = [System.Security.Cryptography.SHA256]::Create()
                $rNorm = ($remTxt -replace "(\r\n|\r|\n)", "`n").TrimEnd("`r","`n")
                $rHash = ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($rNorm))) -replace '-','').ToLowerInvariant()
                $lHash = ''
                if ($selfPath -and (Test-Path $selfPath)) {
                    $lNorm = (([IO.File]::ReadAllText($selfPath, $enc)) -replace "(\r\n|\r|\n)", "`n").TrimEnd("`r","`n")
                    $lHash = ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($lNorm))) -replace '-','').ToLowerInvariant()
                }
                $sha.Dispose()
                $remoteAvail = ($rHash -ne '' -and $rHash -ne $lHash)
                if ($remoteAvail -and -not $CheckOnly -and $selfPath) {
                    Copy-Item $selfPath "$selfPath.bak_update" -Force -ErrorAction SilentlyContinue
                    [IO.File]::WriteAllText($selfPath, ($rNorm -replace "`n","`r`n") + "`r`n", $enc)
                    $selfUpdated = $true
                    Log (" -> Codigo Otimizador atualizado via GitHub (SHA256=" + $rHash.Substring(0,8) + "...).") "Green"
                }
            }
        }
    } catch {}

    # B. Verificacao/Atualizacao Hardware-Aware de AMD FSR (Magpie), DSL (OptiScaler + DirectStorage) e SDXL/IA
    $relMag   = Get-OtimGitHubRelease -Repo 'Blinue/Magpie' -AssetRegex 'x64.*\.zip$'
    $relOpti  = Get-OtimGitHubRelease -Repo 'optiscaler/OptiScaler' -AssetRegex '\.(zip|7z)$'
    $comfyRx  = if ($Hw.GpuVendor -eq 'AMD') {'portable_amd\.7z$'} elseif ($Hw.GpuVendor -eq 'Intel') {'portable_intel\.7z$'} elseif ($Hw.CudaNumeric -ge 12.6) {'nvidia_cu126\.7z$'} else {'nvidia\.7z$'}
    $relComfy = Get-OtimGitHubRelease -Repo 'comfyanonymous/ComfyUI' -AssetRegex $comfyRx
    $torchVer = ''
    try { $tp = Invoke-RestMethod 'https://pypi.org/pypi/torch/json' -TimeoutSec 12; if ($tp.info.version) { $torchVer = $tp.info.version } } catch {}

    $allocConf = if ($Hw.LowVram) { 'expandable_segments:True,garbage_collection_threshold:0.6,max_split_size_mb:128' } elseif ($Hw.VramMB -le 8500) { 'expandable_segments:True,garbage_collection_threshold:0.8' } else { 'expandable_segments:True' }
    $sdxlArgs  = if ($Hw.GpuVendor -eq 'NVIDIA') {
        if ($Hw.LowVram -and $Hw.IsPascalOrOlder) { '--lowvram --opt-sdp-attention --no-half-vae --disable-nan-check' }
        elseif ($Hw.LowVram) { '--lowvram --opt-sdp-attention' }
        elseif ($Hw.VramMB -le 8500) { '--medvram-sdxl --opt-sdp-attention' }
        else { '--opt-sdp-attention' }
    } elseif ($Hw.LowVram) { '--lowvram --use-directml' } else { '--use-directml' }

    $prevState = $null
    if (Test-Path $OtimStateFile) { try { $prevState = Get-Content $OtimStateFile -Raw -Encoding UTF8 | ConvertFrom-Json } catch {} }
    $toolsBase = Join-Path $env:ProgramData 'ModoJogoAutomatico\Tools'

    if (-not $CheckOnly) {
        [Environment]::SetEnvironmentVariable('CUDA_MODULE_LOADING', 'LAZY', 'User')
        [Environment]::SetEnvironmentVariable('SAFETENSORS_FAST_GPU', '1', 'User')
        [Environment]::SetEnvironmentVariable('PYTORCH_CUDA_ALLOC_CONF', $allocConf, 'User')

        # Atualizar Magpie/OptiScaler se ja estiverem instalados em ModoJogoAutomatico\Tools e houver tag mais nova
        foreach ($tInfo in @(
            @{ Name='Magpie'; Dir=(Join-Path $toolsBase 'Magpie'); Exe='Magpie.exe'; Rel=$relMag; OldTag=if($prevState){$prevState.MagpieTag}else{''} },
            @{ Name='OptiScaler'; Dir=(Join-Path $toolsBase 'OptiScaler'); Exe='OptiScaler.dll'; Rel=$relOpti; OldTag=if($prevState){$prevState.OptiScalerTag}else{''} }
        )) {
            if ((Test-Path $tInfo.Dir) -and $tInfo.Rel.DownloadUrl -and ($tInfo.Rel.TagName -ne $tInfo.OldTag)) {
                $tmpArc = Join-Path $env:TEMP $tInfo.Rel.AssetName
                try {
                    Invoke-WebRequest -Uri $tInfo.Rel.DownloadUrl -OutFile $tmpArc -UseBasicParsing -TimeoutSec 90
                    if ($tmpArc -match '\.zip$') { Expand-Archive -Path $tmpArc -DestinationPath $tInfo.Dir -Force }
                    elseif (Get-Command tar -ErrorAction SilentlyContinue) { & tar -xf $tmpArc -C $tInfo.Dir 2>$null }
                    Log (" -> " + $tInfo.Name + " atualizado online para [" + $tInfo.Rel.TagName + "] conforme GPU " + $Hw.GpuVendor + ".") "Green"
                } catch {} finally { Remove-Item $tmpArc -Force -ErrorAction SilentlyContinue }
            }
        }

        # Atualizar Launchers ComfyUI/WebUI existentes conforme GPU/VRAM e git pull se repositorio limpo
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and (Test-Path $_.Root) }
        $enc = New-Object System.Text.UTF8Encoding($false)
        foreach ($drv in $drives) {
            Get-ChildItem -Path $drv.Root -Directory -Depth 2 -ErrorAction SilentlyContinue | Where-Object {
                $_.Name -match 'ComfyUI|stable-diffusion|webui|forge|Fooocus|SDNext|InvokeAI'
            } | ForEach-Object {
                $d = $_.FullName
                if ((Get-Command git -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $d '.git'))) {
                    $dirty = & git -C $d status --porcelain 2>$null
                    if (-not $dirty) { & git -C $d pull --ff-only 2>$null | Out-Null }
                }
                $wb = Join-Path $d 'webui-user.bat'
                if (Test-Path $wb) {
                    $txt = [IO.File]::ReadAllText($wb, $enc)
                    $upd = $txt -replace '(?m)^set\s+COMMANDLINE_ARGS=.*$', "set COMMANDLINE_ARGS=$sdxlArgs"
                    if ($upd -notmatch 'PYTORCH_CUDA_ALLOC_CONF') { $upd = "set CUDA_MODULE_LOADING=LAZY`r`nset SAFETENSORS_FAST_GPU=1`r`nset PYTORCH_CUDA_ALLOC_CONF=$allocConf`r`n" + $upd }
                    if ($upd -ne $txt) { [IO.File]::WriteAllText($wb, $upd, $enc) }
                }
                if ((Test-Path (Join-Path $d 'main.py')) -and ($d -match 'ComfyUI')) {
                    $cFlags = if ($Hw.GpuVendor -ne 'NVIDIA') {'--directml --preview-method auto'} elseif ($Hw.LowVram) {'--lowvram --preview-method auto'} elseif ($Hw.VramMB -le 8500) {'--normalvram --preview-method auto'} else {'--highvram --preview-method auto'}
                    [IO.File]::WriteAllText((Join-Path $d 'Start_SDXL_Optimized.bat'), "@echo off`r`nset CUDA_MODULE_LOADING=LAZY`r`nset SAFETENSORS_FAST_GPU=1`r`nset PYTORCH_CUDA_ALLOC_CONF=$allocConf`r`npython main.py $cFlags`r`npause`r`n", $enc)
                }
            }
        }
        try { Update-MpSignature -ErrorAction SilentlyContinue } catch {}
    }

    try {
        New-Item -Path $OtimStateDir -ItemType Directory -Force | Out-Null
        $stOut = [ordered]@{
            LastCheckUtc   = [DateTime]::UtcNow.ToString('o')
            Hardware       = "$($Hw.GpuVendor)|$($Hw.GpuName)|$($Hw.VramMB)MB|$($Hw.CpuName)"
            DriverVersion  = $Hw.DriverVersion
            CudaVersion    = $Hw.CudaVersion
            SdxlArgs       = $sdxlArgs
            MagpieTag      = $relMag.TagName
            OptiScalerTag  = $relOpti.TagName
            ComfyTag       = $relComfy.TagName
            PyTorchOnline  = $torchVer
        }
        [IO.File]::WriteAllText($OtimStateFile, ($stOut | ConvertTo-Json -Depth 3), (New-Object System.Text.UTF8Encoding($false)))
    } catch {}

    Log (" -> Codigo .bat    : " + $(if ($selfUpdated) {"ATUALIZADO agora"} elseif ($remoteAvail) {"Nova versao disponivel online"} else {"Atualizado (igual ao GitHub)"})) $(if ($remoteAvail -and -not $selfUpdated) {'Yellow'} else {'Green'})
    Log (" -> FSR / DSL / IA : GPU=$($Hw.GpuName) ($($Hw.VramMB) MB, CUDA=$($Hw.CudaVersion)) | Magpie=$($relMag.TagName) | OptiScaler=$($relOpti.TagName) | ComfyUI=$($relComfy.TagName) | PyTorch=$torchVer" ) "Gray"
    Log (" -> Perfis SDXL    : $sdxlArgs | DirectStorage SSD=$($Hw.IsOsOnSSD) (Build $($Hw.OsBuild))") "Gray"
    return [PSCustomObject]@{ SelfUpdated=$selfUpdated; SelfPath=$selfPath; UpdateAvailable=$remoteAvail }
}

if ($otimArgNorm -eq '-verificar') {
    Write-Host "[VERIFICACAO ONLINE HARDWARE-AWARE - MODO SOMENTE LEITURA]" -ForegroundColor Cyan
    $hwSnap = Get-OtimHardwareSnapshot
    Invoke-OtimizadorOnlineUpdate -Hw $hwSnap -CheckOnly | Out-Null
    exit 0
}
if ($otimArgNorm -eq '-atualizar') {
    Write-Host "[ATUALIZACAO ONLINE HARDWARE-AWARE]" -ForegroundColor Cyan
    $hwSnap = Get-OtimHardwareSnapshot
    Invoke-OtimizadorOnlineUpdate -Hw $hwSnap | Out-Null
    exit 0
}

Log "=== RELATORIO DE OTIMIZACAO UNIVERSAL WINDOWS 10/11 ===" "Green"
Log ("Data/Hora: " + (Get-Date))

# 1. Ponto de Restauracao Automatico
Log "`n[1/11] Criando Ponto de Restauracao do Sistema (Seguranca)..."
Enable-ComputerRestore -Drive $env:SystemDrive
Checkpoint-Computer -Description "Antes do Otimizador Universal" -RestorePointType "MODIFY_SETTINGS"

# 2. Deteccao Automatica de Hardware + Verificacao/Atualizacao Online
Log "`n[2/11] Detectando Hardware (CPU, GPU, RAM, SSDs/HDDs, DirectStorage) e Atualizacoes Online..."
$hwSnap   = Get-OtimHardwareSnapshot
$cpu      = $hwSnap.CpuName
$ramGB    = $hwSnap.RamTotalGB
$isLaptop = $hwSnap.IsLaptop
$sysDriveLetter = $hwSnap.SysDriveLetter
$sysDisk  = $hwSnap.SysDisk
$isOsOnSSD = $hwSnap.IsOsOnSSD
Log (" -> CPU: $cpu | GPU: $($hwSnap.GpuName) ($($hwSnap.VramMB) MB)") "Gray"
Log (" -> RAM: $ramGB GB | Notebook: $isLaptop | Sistema ($sysDriveLetter`:) em SSD: $isOsOnSSD (" + $sysDisk.FriendlyName + ")") "Gray"

if ($otimArgNorm -ne '-noupdate') {
    $upOtim = Invoke-OtimizadorOnlineUpdate -Hw $hwSnap
    if ($upOtim.SelfUpdated -and $upOtim.SelfPath -and (Test-Path $upOtim.SelfPath)) {
        Log " -> Reabrindo Otimizador com a versao mais recente do GitHub..." "Cyan"
        Start-Process -FilePath $upOtim.SelfPath -ArgumentList '-noupdate' -Verb RunAs
        exit 0
    }
}

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
# Em Desktop, garante PCIe ASPM Desligado (0) e Disk Idle 0 em TODOS os planos (evita BusReset TDR / disk 153 ao alternar planos)
foreach ($pLine in ($plansOutput)) {
    if ($pLine -match '([0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12})') {
        $g = $matches[1]
        if (-not $isLaptop) {
            powercfg /setacvalueindex $g 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 2>$null
            powercfg /setacvalueindex $g 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0 2>$null
        }
    }
}
# PCIe Link State Power Management -> Off (0) e USB Selective Suspend -> Disabled (0) no plano ativo
powercfg /setacvalueindex $activeGuid 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
powercfg /setacvalueindex $activeGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setactive $activeGuid
if (-not $isLaptop) {
    powercfg /h off
}
Log " -> Plano Desempenho Maximo ativo ($activeGuid) | Disk Idle=0 | PCIe ASPM=Off (todos os planos em Desktop) | USB Suspend=Off" "Gray"

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
foreach ($audTask in @('Audio','Pro Audio')) {
    if (Test-Path "$mm\Tasks\$audTask") {
        $pVal = if ($audTask -eq 'Pro Audio') { 2 } else { 6 }
        Set-ItemProperty -Path "$mm\Tasks\$audTask" -Name 'Scheduling Category' -Value 'High' -Type String -Force
        Set-ItemProperty -Path "$mm\Tasks\$audTask" -Name 'GPU Priority' -Value 8 -Type DWord -Force
        Set-ItemProperty -Path "$mm\Tasks\$audTask" -Name 'Priority' -Value $pVal -Type DWord -Force
    }
}
$mmUsr = 'HKCU:\Software\Microsoft\Multimedia\Audio'
New-Item -Path $mmUsr -Force | Out-Null
Set-ItemProperty -Path $mmUsr -Name 'AccessibilityMonoMixState' -Value 0 -Type DWord -Force
Set-ItemProperty -Path $mmUsr -Name 'UserDuckingPreference' -Value 3 -Type DWord -Force
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '0' -Type String -Force

# 11. Limpeza de Arquivos Temporarios, Caches, Correcao de Erros do Sistema e Reparo DISM + SFC
Log "`n[11/11] Limpando Temporarios, Corrigindo Erros do Windows e Verificando Integridade..."
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
    "$env:SystemDrive\`$SysReset",
    "$env:SystemRoot\LiveKernelReports\**\*.dmp",
    "$env:SystemRoot\Minidump\*.dmp"
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

# 11a. Remover servicos/drivers orfaos cujo arquivo .sys nao existe na unidade do sistema ou em disco conectado
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\*' -ErrorAction SilentlyContinue | ForEach-Object {
    $ip = $_.ImagePath
    $svcName = $_.PSChildName
    if ($ip -and ($_.Type -eq 1 -or $_.Type -eq 2) -and ($_.Start -in @(0,1,2,3))) {
        $sysFull = $null
        if ($ip -match '^(?:\\\?\?\\)?([A-Za-z]:\\.+?\.sys)$') { $sysFull = $matches[1] }
        elseif ($ip -match '^(system32\\drivers\\.+\.sys)$') { $sysFull = Join-Path $env:SystemRoot $matches[1] }
        if ($sysFull -and ($sysFull -match '^([A-Za-z]:)\\') -and (Test-Path ($matches[1] + '\')) -and (-not (Test-Path $sysFull))) {
            sc.exe stop $svcName 2>$null | Out-Null
            sc.exe delete $svcName 2>$null | Out-Null
            Log (" -> Removido servico de driver orfao inexistente: $svcName ($sysFull)") "Yellow"
        }
    }
}

# 11b. Corrigir WMI Autorecover MOFs ausentes/duplicados (WMI Error 4)
try {
    $cimomKey = 'HKLM:\SOFTWARE\Microsoft\Wbem\CIMOM'
    $curMofs = (Get-ItemProperty $cimomKey -ErrorAction SilentlyContinue).'Autorecover MOFs'
    if ($curMofs) {
        $seenMof = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $cleanMof = [System.Collections.Generic.List[string]]::new()
        $mofChanged = $false
        foreach ($m in $curMofs) {
            if ([string]::IsNullOrWhiteSpace($m)) { $mofChanged = $true; continue }
            $exp = [Environment]::ExpandEnvironmentVariables($m)
            if ((Test-Path $exp) -and $seenMof.Add($m)) { $cleanMof.Add($m) }
            else { $mofChanged = $true }
        }
        $latestDefMof = Get-ChildItem "$env:ProgramData\Microsoft\Windows Defender\Platform" -Filter 'ProtectionManagement.mof' -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latestDefMof -and $seenMof.Add($latestDefMof.FullName)) {
            $cleanMof.Add($latestDefMof.FullName)
            $mofChanged = $true
        }
        if ($mofChanged) {
            Set-ItemProperty -Path $cimomKey -Name 'Autorecover MOFs' -Value ([string[]]$cleanMof.ToArray()) -Type MultiString -Force
            if ($latestDefMof) { mofcomp $latestDefMof.FullName 2>$null | Out-Null }
            Log " -> Lista Autorecover MOFs do WMI limpa (removidas referencias quebradas)." "Gray"
        }
    }
    $wmiVer = winmgmt /verifyrepository 2>&1
    if ($LASTEXITCODE -ne 0 -or ($wmiVer -join ' ') -match 'inconsist|not consistent') {
        winmgmt /salvagerepository 2>$null | Out-Null
        Log " -> Repositorio WMI reparado automaticamente." "Yellow"
    }
} catch {}

# 11c. Corrigir conflito VBS/HVCI causando Kernel-Boot 124 no Event Log
try {
    $kb124 = Get-WinEvent -FilterHashtable @{ LogName='System'; ProviderName='Microsoft-Windows-Kernel-Boot'; Id=124; StartTime=(Get-Date).AddDays(-7) } -MaxEvents 1 -ErrorAction SilentlyContinue
    if ($kb124) {
        $hvciReg = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'
        if (Test-Path $hvciReg) {
            Set-ItemProperty -Path $hvciReg -Name 'Enabled' -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $hvciReg -Name 'WasEnabledBy' -Value 0 -Type DWord -Force
        }
        $dgReg = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'
        if (Test-Path $dgReg) { Set-ItemProperty -Path $dgReg -Name 'EnableVirtualizationBasedSecurity' -Value 0 -Type DWord -Force }
        Log " -> Conflito VBS/HVCI (Kernel-Boot 124) desativado para estabilidade e FPS." "Yellow"
    }
} catch {}

# 11d. Instalar drivers de sistema/chipset pendentes via Windows Update caso haja dispositivo PCI/System com erro de instalacao
try {
    $badSysDevs = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.Problem -eq 'CM_PROB_FAILED_INSTALL' -and $_.InstanceId -match '^PCI\\' }
    if ($badSysDevs) {
        $sess = New-Object -ComObject Microsoft.Update.Session
        $searcher = $sess.CreateUpdateSearcher()
        $drvRes = $searcher.Search("IsInstalled=0 and Type='Driver'")
        $drvColl = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($du in $drvRes.Updates) {
            $hwids = ($du.DriverHardwareID -join ';').ToLower()
            if ($hwids -match '^pci\\|pci\\ven_') { [void]$drvColl.Add($du) }
        }
        if ($drvColl.Count -gt 0) {
            $dl = $sess.CreateUpdateDownloader(); $dl.Updates = $drvColl; [void]$dl.Download()
            $inst = $sess.CreateUpdateInstaller(); $inst.Updates = $drvColl; [void]$inst.Install()
            Log (" -> Drivers oficiais PCI/Chipset pendentes instalados via Windows Update (" + $drvColl.Count + ").") "Green"
        }
    }
} catch {}

# 11e. Agendar verificacao OFFLINE segura no proximo boot apenas se houver erro Ntfs Id=55 recente (evita travamento online)
try {
    $ntfs55 = Get-WinEvent -FilterHashtable @{ LogName='System'; ProviderName='Ntfs'; Id=55; StartTime=(Get-Date).AddDays(-7) } -MaxEvents 10 -ErrorAction SilentlyContinue
    if ($ntfs55) {
        $badVols = $ntfs55 | ForEach-Object { if ($_.Properties.Count -gt 0) { ($_.Properties[0].Value + '').Trim() } } | Where-Object { $_ -match '^[A-Za-z]:$' } | Select-Object -Unique
        foreach ($bv in $badVols) {
            fsutil dirty set $bv | Out-Null
            Log (" -> Corrupcao NTFS recente em $bv - reparo offline seguro agendado para o proximo boot.") "Yellow"
        }
    }
} catch {}

Log " -> Verificando saude da imagem do Windows (DISM /CheckHealth)..." "Gray"
$dismCheck = DISM.exe /Online /Cleanup-Image /CheckHealth
if ($dismCheck -match 'repar|repair') {
    Log " -> Corrupcao detectada! Executando DISM /RestoreHealth..." "Yellow"
    DISM.exe /Online /Cleanup-Image /RestoreHealth
}
Log " -> Executando verificador de arquivos do sistema (sfc /scannow)..." "Gray"
sfc /scannow

Log "`n=== OTIMIZACAO UNIVERSAL CONCLUIDA COM SUCESSO! ===" "Green"
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  PROCESSO FINALIZADO! Reinicie o computador para aplicar todos os ajustes." -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Relatorio completo salvo em: $logFile" -ForegroundColor Green
if ($otimArgNorm -notin @('-verificar','-atualizar','-silent')) {
    Read-Host "Pressione Enter para fechar" | Out-Null
}