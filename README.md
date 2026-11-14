# Otimizador Universal Windows 10/11 - Performance, Limpeza e Segurança

> **Criado por Antigravity** (assistente de IA do Google DeepMind) — script universal desenvolvido para aplicar ajustes de desempenho, limpeza profunda, reparo de integridade e segurança no Windows 10 e Windows 11, detectando automaticamente o hardware de qualquer PC.

---

## Como usar em qualquer PC

1. Baixe o arquivo [`Otimizador_Universal_Windows.bat`](./Otimizador_Universal_Windows.bat) (ou copie o código interno abaixo e salve como `Otimizador_Universal_Windows.bat` em UTF-8).
2. Dê **dois cliques** no arquivo (ele solicita permissão de **Administrador** automaticamente caso não esteja elevado) **ou** execute-o pelo Prompt de Comando (`cmd`):

```cmd
Otimizador_Universal_Windows.bat
```

3. Ao final, reinicie o computador para aplicar todos os ajustes por completo. Um relatório completo (`Relatorio_Otimizacao_*.txt`) é gerado automaticamente na Área de Trabalho.

---

## O que ele faz automaticamente (adaptando-se a qualquer hardware)

1. **[1/11] Ponto de Restauração Automático:** Antes de mexer em qualquer ajuste, cria um Ponto de Restauração do Windows (`Antes do Otimizador Universal`) e gera um relatório `.txt` na Área de Trabalho de quem executou.
2. **[2/11] Detecção Inteligente de Hardware:** Identifica sozinho a CPU, quantidade de memória RAM, se é **Desktop ou Notebook** (pela presença de bateria) e diferencia automaticamente todos os discos **SSD** e **HD mecânico** conectados.
3. **[3/11] Limpeza de Boot (`bcdedit`):** Reduz o tempo de espera do menu de boot para `3s` e, caso o Windows esteja instalado num **SSD**, remove entradas secundárias órfãs de HDs mecânicos da ordem de boot do firmware (mantendo intactos o `Windows Boot Manager` e o SSD).
4. **[4/11] Blindagem de Segurança e Windows Defender:** Garante que a proteção em tempo real do Defender esteja ligada, limpa exceções de ameaças permitidas (`ThreatIDDefaultAction`), verifica redirecionamentos externos no arquivo `hosts` e limpa o cache DNS.
5. **[5/11] Plano de Energia (*Desempenho Máximo*):** Ativa o esquema oficial *Ultimate Performance / Desempenho Máximo* (ou cria se não existir no PC), apaga planos duplicados, desativa o desligamento do motor dos HDs na tomada (`disk-timeout-ac = 0`), desativa economia de energia PCIe (`ASPM Off`) e suspensão seletiva de USB. *(Se for Desktop, desativa a hibernação para economizar GBs no SSD; se for Notebook, preserva a hibernação para não perder bateria).*
6. **[6/11] Otimização Dinâmica por Tipo de Disco:**
   * **Em cada SSD encontrado:** Executa o comando `TRIM` (`Optimize-Volume -ReTrim`) e ativa `DisableLastAccess = 1` para evitar escritas desnecessárias.
   * **Em cada HD mecânico encontrado:** Desativa a indexação contínua do Windows Search naquele disco para evitar que o HD fique sobrecarregado durante jogos ou uso.
7. **[7/11] Memória Virtual (`pagefile.sys`) sob Medida:** Verifica quanto espaço livre há no disco do sistema e quanta RAM o PC possui:
   * Se o SSD tiver pouco espaço livre (`< 35 GB`), define `2048 MB` inicial; se tiver bastante espaço, define `4096 MB` inicial, com teto de `8192 MB` (ou `12288 MB` em PCs com `<= 8 GB` de RAM), e **remove qualquer `pagefile` que esteja em HDs mecânicos lentos**.
8. **[8/11] Serviços e Telemetria (*Padrão WinUtil / AtlasOS*):** Desativa telemetria da Microsoft (`DiagTrack`, `dmwappushservice`, `MapsBroker`, `lfsvc`, `RetailDemo`, `Wisvc`) e telemetria oculta da Intel (`QUEENCREEK` + tarefa agendada oculta, se presentes). Se o Windows estiver num **SSD**, desativa também o `SysMain` (*Superfetch*); se o Windows estiver instalado num **HD mecânico**, mantém o `SysMain` ligado.
9. **[9/11] Inicialização Limpa (`Run`):** Retira launchers pesados de jogos (*Steam, Epic, EA, Origin, Riot, Battle.net, Ubisoft, GOG* e *Discord* duplicado) da abertura simultânea com o Windows, mantendo todos os drivers (áudio, vídeo, mouse/teclado e antivírus).
10. **[10/11] Jogos, GPU e Latência:** Ativa o **HAGS (`HwSchMode = 2`)**, ativa o **Modo de Jogo**, desativa a gravação oculta **GameDVR**, ajusta o perfil de multimídia e rede (`SystemResponsiveness = 10`, `NetworkThrottlingIndex = ffffffff`, prioridade de GPU `8` / CPU `High`) e zera o atraso de menus (`MenuShowDelay = 0`).
11. **[11/11] Limpeza Profunda + Reparo Oficial (`DISM` e `SFC`):** Limpa pastas `Temp`, `CrashDumps`, `SquirrelTemp` e `$SysReset`, esvazia a Lixeira e roda `DISM /CheckHealth` (executando `DISM /RestoreHealth` se houver corrupção) seguido de `sfc /scannow`.

---

## Código Interno do `.bat` (`Otimizador_Universal_Windows.bat`)

```bat
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

# 4. Seguranca: Windows Defender, Excecoes de Ameacas e Auditoria do Arquivo Hosts
Log "`n[4/11] Verificando Windows Defender, Excecoes e Arquivo Hosts..."
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
    $suspiciousHosts = Get-Content $hostsPath | Where-Object {
        $_ -notmatch '^\s*#' -and $_ -match '\S' -and $_ -notmatch '^\s*(127\.0\.0\.1|0\.0\.0\.0|::1)\s+'
    }
    if ($suspiciousHosts) {
        Log (" -> ATENCAO: Encontradas entradas externas no arquivo hosts (" + $suspiciousHosts.Count + " linhas). Recomenda-se revisar.") "Yellow"
    }
}
ipconfig /flushdns | Out-Null

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

# 8. Desativacao de Servicos de Telemetria, Bloat e Coleta em Segundo Plano (Padrao WinUtil / AtlasOS)
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
$bloatRun = @('Steam','EpicGamesLauncher','EADM','Origin','RiotClient','Battle.net','Ubisoft Game Launcher','GalaxyClient')
foreach ($app in $bloatRun) {
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $app
}
if ((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord') -and (Get-ItemProperty 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord')) {
    Remove-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord'
}

# 10. Otimizacoes de GPU (HAGS), Game Mode, GameDVR, Rede e Latencia de Interface
Log "`n[10/11] Aplicando Otimizacoes de GPU (HAGS), Jogos, Rede e Interface..."
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'HwSchMode' -Value 2 -Type DWord -Force
New-Item -Path 'HKCU:\Software\Microsoft\GameBar' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 1 -Type DWord -Force
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AutoGameModeEnabled' -Value 1 -Type DWord -Force
New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0 -Type DWord -Force
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0 -Type DWord -Force
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord -Force

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
    "$env:SystemDrive\`$SysReset"
)
foreach ($jp in $junkPaths) {
    Remove-Item -Path $jp -Recurse -Force
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
```
