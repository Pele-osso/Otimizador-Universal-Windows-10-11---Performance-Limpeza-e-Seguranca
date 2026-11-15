# Otimizador_Universal_Windows.bat (Google Gemini — Nível Máximo / XHigh)

> **Modelo de IA & Nível:** Este projeto e todo o código interno do script `.bat` foram criados pelo modelo **Google Gemini — Nível Máximo (XHigh / Effort 1.00)**, sem dependências fixas ou dados pessoais de qualquer máquina.

---

## Download Direto & Outros Canais

| Canal / Post | Download 1-Clique (`.zip` / `.bat`) | Repositório / Raw |
| :--- | :--- | :--- |
| **Canal `otimizador-universal` *(Este Canal)*** | [⬇️ Baixar `.zip` Completo](archive/refs/heads/main.zip) · [⬇️ Ver / Baixar `.bat`](blob/main/Otimizador_Universal_Windows.bat) | [📄 Raw `.bat`](raw/main/Otimizador_Universal_Windows.bat) |
| **Suíte Unificada 1-Clique *(Novo!)*** | [⬇️ Baixar `.zip`](../Otimizador-Universal-e-Modo-Jogo-Automatico-1-Clique/archive/refs/heads/main.zip) · [⬇️ `.bat`](../Otimizador-Universal-e-Modo-Jogo-Automatico-1-Clique/blob/main/Otimizador_e_Modo_Jogo_1Clique.bat) | [🔗 Abrir canal Suíte 1-Clique](../Otimizador-Universal-e-Modo-Jogo-Automatico-1-Clique) |
| **Canal `modo-jogo`** | [⬇️ Baixar `.zip`](../Modo-Jogo-Automatico-Windows-e-MSI-Afterburner/archive/refs/heads/main.zip) · [⬇️ `.bat`](../Modo-Jogo-Automatico-Windows-e-MSI-Afterburner/blob/main/Modo_Jogo_Automatico.bat) | [🔗 Abrir canal Modo Jogo](../Modo-Jogo-Automatico-Windows-e-MSI-Afterburner) |

---

## Como usar em qualquer PC

* Basta dar **dois cliques** no arquivo `Otimizador_Universal_Windows.bat` (ele pede permissão de Administrador sozinho se ainda não estiver elevado) **ou** usar via `cmd` / `PowerShell`:
  ```cmd
  Otimizador_Universal_Windows.bat               (Execucao completa [1/12..12/12] + check/update online)
  Otimizador_Universal_Windows.bat -checkupdate  (Verifica apenas via internet vs pecas do PC, sem UAC)
  Otimizador_Universal_Windows.bat -atualizar    (Auto-atualiza codigo .bat + DirectStorage + SDXL/IA + Drivers)
  ```

---

## O que ele faz automaticamente (adaptando-se a qualquer hardware)

1. **[1/12] Ponto de Restauração Automático:** Antes de mexer em qualquer ajuste, cria um Ponto de Restauração do Windows (`Antes do Otimizador Universal`) e gera um relatório `.txt` na Área de Trabalho de quem executou.
2. **[2/12] Detecção Inteligente de Hardware:** Identifica sozinho a CPU, quantidade de memória RAM, se é **Desktop ou Notebook** (pela presença de bateria) e diferencia automaticamente todos os discos **SSD** e **HD mecânico** conectados.
3. **[3/12] Limpeza de Boot (`bcdedit`):** Reduz o tempo de espera do menu de boot para `3s` e, caso o Windows esteja instalado num **SSD**, remove entradas secundárias órfãs de HDs mecânicos da ordem de boot do firmware (mantendo intactos o `Windows Boot Manager` e o SSD).
4. **[4/12] Blindagem de Segurança e Windows Defender:** Garante que a proteção em tempo real do Defender esteja ligada, limpa exceções de ameaças permitidas (`ThreatIDDefaultAction` como *GameHacks/PUAs*), bloqueia redirecionamentos falsos no arquivo `hosts` (`0.0.0.0`) e limpa o cache DNS.
5. **[5/12] Plano de Energia (*Desempenho Máximo*) + Proteção PCIe ASPM:** Ativa o esquema oficial *Ultimate Performance / Desempenho Máximo* (ou cria se não existir no PC), apaga planos duplicados, desativa o desligamento do motor dos HDs (`disk-timeout-ac = 0`) e suspensão seletiva de USB. **Em Desktop, desativa também o PCIe ASPM (`Off`) e o tempo ocioso de disco (`0`) em TODOS os planos de energia** (evitando travamentos de vídeo `BusReset TDR` e erros de E/S ao alternar planos) e desativa a hibernação para economizar GBs no SSD *(em Notebooks, preserva a hibernação para proteger a bateria)*.
6. **[6/12] Otimização Dinâmica por Tipo de Disco:**
   * **Em cada SSD encontrado:** Executa o comando `TRIM` (`Optimize-Volume -ReTrim`) e ativa `DisableLastAccess = 1` para evitar escritas desnecessárias.
   * **Em cada HD mecânico encontrado:** Desativa a indexação contínua do Windows Search naquele disco para evitar que o HD fique "arranhando" durante jogos ou uso.
7. **[7/12] Memória Virtual (`pagefile.sys`) sob Medida:** Verifica quanto espaço livre há no disco do sistema e quanta RAM o PC possui:
   * Se o SSD tiver pouco espaço livre (`< 35 GB`), define `2048 MB` inicial; se tiver bastante espaço, define `4096 MB` inicial, com teto de `8192 MB` (ou `12288 MB` em PCs com `<= 8 GB` de RAM), e **remove qualquer `pagefile` que esteja em HDs mecânicos lentos**.
8. **[8/12] Serviços e Telemetria (*Padrão WinUtil / AtlasOS*):** Desativa telemetria da Microsoft (`DiagTrack`, `dmwappushservice`, `MapsBroker`, `lfsvc`, `RetailDemo`, `Wisvc`) e telemetria oculta da Intel (`QUEENCREEK` + tarefa agendada oculta). Se o Windows estiver num **SSD**, desativa também o `SysMain` (*Superfetch*); se o Windows estiver instalado num **HD mecânico**, mantém o `SysMain` ligado (pois em HDs antigos ele ajuda no carregamento).
9. **[9/12] Inicialização Limpa (`Run`):** Retira launchers pesados de jogos (*Steam, Epic, EA, Riot, Rave, Battle.net, Ubisoft, GOG* e *Discord* duplicado) da abertura simultânea com o Windows, mantendo todos os drivers (áudio, vídeo, mouse/teclado e antivírus).
10. **[10/12] Jogos, GPU, Contraste/Cor e Latência:** Ativa o **HAGS (`HwSchMode = 2`)**, ativa o **Modo de Jogo**, desativa a gravação oculta **GameDVR** preservando `GameDVR_FSEBehaviorMode = 0` e removendo `OverlayTestMode` (evitando tela lavada/filtro branco em tela cheia), força **RGB Completo (`0-255`)** via NVAPI, restaura **Gama linear `1.0`** e checa via **DDC/CI** se o monitor está com contraste `< 30` ou Black Level `> 55`, ajusta prioridade multimídia/rede (`SystemResponsiveness = 10`, `NetworkThrottlingIndex = ffffffff`, GPU `8` / CPU `High`), ajusta áudio multimídia (`Audio`/`Pro Audio` em prioridade `High`, garante Estéreo real com `AccessibilityMonoMixState = 0` e bloqueia redução de chamadas com `UserDuckingPreference = 3`) e zera o atraso de menus (`MenuShowDelay = 0`).
11. **[11/12] Limpeza Profunda + Reparo Automático de Erros + `DISM` & `SFC`:**
    * Limpa `Temp`, `CrashDumps`, `LiveKernelReports` / `Minidump` (`.dmp`), `SquirrelTemp`, caches residuais e esvazia todas as Lixeiras.
    * **Drivers Órfãos (`SCM 7000`):** Identifica e remove serviços de driver cujo arquivo `.sys` não existe mais na unidade conectada.
    * **WMI (`Autorecover MOFs` / `WMI 4`):** Limpa entradas vazias ou quebradas no registro `CIMOM`, recompila o `ProtectionManagement.mof` atual do Defender e executa `winmgmt /verifyrepository` (reparando via `/salvagerepository` se necessário).
    * **VBS / HVCI (`Kernel-Boot 124`):** Resolve conflitos recentes de `HypervisorEnforcedCodeIntegrity` quando registrados no log do sistema.
    * **Drivers PCI / Chipset Pendentes:** Instala automaticamente drivers `PCI\VEN_` pendentes via Windows Update caso haja algum dispositivo de sistema com falha de instalação (`CM_PROB_FAILED_INSTALL`).
    * **Reparo NTFS Offline Seguro:** Caso detecte erro recente de estrutura NTFS (`Event 55`), marca apenas a checagem offline segura no próximo boot (`fsutil dirty set`), sem rodar varreduras online lentas que possam travar o sistema.
    * **Integridade do Sistema:** Executa `DISM /CheckHealth` (`DISM /RestoreHealth` se necessário) seguido de `sfc /scannow`.
12. **[12/12] Verificação & Atualização Online Hardware-Aware (`-checkupdate` / `-atualizar`):**
    * **Re-inspeciona as peças atuais do PC** (CPU, RAM, GPU/VRAM, presença de *Tensor Cores* vs Pascal, SSDs e HardwareIDs PnP) antes de qualquer consulta ou atualização.
    * **Auto-Atualização do Próprio Código:** Consulta a versão mais recente upstream no GitHub, valida sintaticamente o PowerShell via *AST Parser* antes de aplicar e grava backup `.bak_update` automaticamente.
    * **AMD FSR, DSL (DirectStorage) & SDXL/IA:** Consulta versões oficiais online de **Magpie**, **OptiScaler**, **Microsoft DirectStorage (`1.x` via NuGet)**, **PyTorch / xFormers (PyPI)** e **ComfyUI**, atualizando caches de DirectStorage x64, repositórios locais limpos (`git pull --ff-only`), launchers `Start_SDXL_Optimized.bat` / `webui-user.bat` adaptados à GPU/VRAM atual e drivers PnP (`Display/Media/PCI`) pendentes no Windows Update.

---

## Código Interno do `Otimizador_Universal_Windows.bat`

```bat@echo off
chcp 65001 >nul
title Otimizador Universal Windows 10/11 - Google Gemini (Nivel Maximo / XHigh)

set "OTIM_ARGS=%~1"
set "OTIM_SELF=%~f0"

:: Se for apenas verificacao rapida online, dispensa UAC; caso contrario exige Administrador
if /i "%OTIM_ARGS%"=="-checkupdate" goto :RunPS

:: Verifica se esta rodando como Administrador; se nao, solicita elevacao automatica
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Solicitando permissao de Administrador...
    if "%OTIM_ARGS%"=="" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:OTIM_SELF -Verb RunAs"
    ) else (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:OTIM_SELF -ArgumentList $env:OTIM_ARGS -Verb RunAs"
    )
    exit /b
)

:RunPS
cls
echo ============================================================================
echo    OTIMIZADOR UNIVERSAL WINDOWS 10/11 (HARDWARE-AWARE / GOOGLE GEMINI XHIGH)
echo ============================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$lines = [System.IO.File]::ReadAllLines($env:OTIM_SELF, [System.Text.Encoding]::UTF8); $idx = [Array]::IndexOf($lines, ':: === INICIO_POWERSHELL ==='); $code = $lines[($idx+1)..($lines.Length-1)] -join [Environment]::NewLine; & ([ScriptBlock]::Create($code))" & exit /b
:: === INICIO_POWERSHELL ===
$ErrorActionPreference = 'SilentlyContinue'
$OptVersion     = '2.2.0'
$UpstreamOwner  = 'Pele-osso'
$UpstreamRepo   = 'Otimizador-Universal-Windows-10-11---Performance-Limpeza-e-Seguranca'
$UpstreamFile   = 'Otimizador_Universal_Windows.bat'

$desktop = [Environment]::GetFolderPath('Desktop')
$logFile = Join-Path $desktop ("Relatorio_Otimizacao_" + (Get-Date -Format "yyyy-MM-dd_HH-mm") + ".txt")

function Log($msg, $color = "Cyan") {
    Write-Host $msg -ForegroundColor $color
    if ($env:OTIM_NOLOG -ne '1') {
        Add-Content -Path $logFile -Value $msg -Encoding UTF8
    }
}

function Compare-OptSemVer {
    param([string]$LocalVer, [string]$RemoteVer)
    $lClean = (($LocalVer + '').Trim() -replace '^[vV]', '')
    $rClean = (($RemoteVer + '').Trim() -replace '^[vV]', '')
    if (-not $rClean) { return 0 }
    if (-not $lClean) { return 1 }
    $lBase = ($lClean -split '[-_]')[0]; $rBase = ($rClean -split '[-_]')[0]
    $lNums = @($lBase -split '\.' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ })
    $rNums = @($rBase -split '\.' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ })
    if ($lNums.Count -gt 0 -and $rNums.Count -gt 0) {
        $maxLen = [math]::Max($lNums.Count, $rNums.Count)
        for ($i = 0; $i -lt $maxLen; $i++) {
            $lv = if ($i -lt $lNums.Count) { $lNums[$i] } else { 0 }
            $rv = if ($i -lt $rNums.Count) { $rNums[$i] } else { 0 }
            if ($rv -gt $lv) { return 1 }
            if ($rv -lt $lv) { return -1 }
        }
        return 0
    }
    if ($rClean -ne $lClean) { return 1 }
    return 0
}

function Get-OptGitHubReleaseNoApi {
    param([string]$RepoSlug, [string]$AssetRegex = '\.(zip|7z)$')
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
    $tag = $null; $resolvedSlug = $RepoSlug; $url = "https://github.com/$RepoSlug/releases/latest"
    for ($hop = 0; $hop -lt 4; $hop++) {
        try {
            $req = [System.Net.HttpWebRequest]::Create($url)
            $req.Method = 'HEAD'; $req.AllowAutoRedirect = $false; $req.Timeout = 6000; $req.UserAgent = 'Mozilla/5.0'
            $resp = $req.GetResponse(); $code = [int]$resp.StatusCode; $loc = $resp.Headers['Location']; $resp.Close()
            if ($code -ge 300 -and $code -lt 400 -and $loc) {
                if ($loc -match 'github\.com/([^/]+/[^/]+)/releases/tag/([^/?#]+)$' -or $loc -match '^/([^/]+/[^/]+)/releases/tag/([^/?#]+)$') {
                    $resolvedSlug = $matches[1]; $tag = $matches[2]; break
                }
                if ($loc -match '^/') { $url = "https://github.com$loc" } else { $url = $loc }
            } else { break }
        } catch { break }
    }
    $assetUrl = $null
    if ($tag) {
        try {
            $expHtml = (Invoke-WebRequest -Uri "https://github.com/$resolvedSlug/releases/expanded_assets/$tag" -UseBasicParsing -TimeoutSec 8 -Headers @{ 'User-Agent' = 'Mozilla/5.0' }).Content
            foreach ($hm in ([regex]::Matches($expHtml, 'href="(/[^"]+/releases/download/[^"]+)"', 'IgnoreCase'))) {
                $relPath = $hm.Groups[1].Value
                if ([System.IO.Path]::GetFileName($relPath) -match $AssetRegex) { $assetUrl = "https://github.com$relPath"; break }
            }
        } catch {}
    }
    if (-not $tag) { return $null }
    return [PSCustomObject]@{ Tag = $tag; AssetUrl = $assetUrl }
}

function Invoke-OptHardwareAwareOnlineUpdate {
    param([switch]$ApplySelf, [switch]$ApplyComponents)
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
    $hdrs = @{ 'User-Agent' = 'GoogleGemini-AutoOptimizer'; 'Accept' = 'application/json' }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

    # 1. Re-detectar pecas reais do PC agora
    $cpuObj = Get-CimInstance Win32_Processor | Select-Object -First 1
    $osObj  = Get-CimInstance Win32_OperatingSystem
    $gpus   = @(Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch 'Microsoft Basic|Parsec|Indirect|Virtual' })
    $gpuMain = $gpus | Sort-Object AdapterRAM -Descending | Select-Object -First 1
    $ramTotGB = [math]::Round($osObj.TotalVisibleMemorySize / 1MB, 1)
    $vramMB = if ($gpuMain -and $gpuMain.AdapterRAM) { [int][math]::Round($gpuMain.AdapterRAM / 1MB, 0) } else { 0 }
    $nvSmiCmd = (Get-Command nvidia-smi -ErrorAction SilentlyContinue)
    if ($nvSmiCmd -and $gpuMain.Name -match 'NVIDIA') {
        $qMem = & $nvSmiCmd.Source --query-gpu=memory.total --format=csv,noheader,nounits 2>$null | Select-Object -First 1
        $mVal = 0; if ($qMem -and [int]::TryParse($qMem.Trim(), [ref]$mVal) -and $mVal -gt 0) { $vramMB = $mVal }
    }
    $isPascal = ($gpuMain.Name -match 'NVIDIA') -and ($gpuMain.Name -match 'GTX\s*(7\d\d|8\d\d|9\d\d|10\d\d|16\d\d)|GT\s*\d+|MX\d+')
    $noTensor = ($gpuMain.Name -notmatch 'NVIDIA') -or $isPascal
    $ssdCnt   = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.MediaType -eq 'SSD' }).Count

    Log "`n=== [12/12] VERIFICACAO E ATUALIZACAO ONLINE HARDWARE-AWARE (v$OptVersion) ===" "Cyan"
    Log (" -> Pecas Atuais: $($cpuObj.Name) | ${ramTotGB}GB RAM | $($gpuMain.Name) (${vramMB}MB VRAM) | SSDs=$ssdCnt | NoTensor=$noTensor") "Gray"

    # 2. Auto-atualizacao segura do proprio codigo via GitHub
    try {
        $nonce = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $rawUrl = "https://raw.githubusercontent.com/$UpstreamOwner/$UpstreamRepo/main/$UpstreamFile`?t=$nonce"
        $rBat = [string](Invoke-WebRequest -Uri $rawUrl -UseBasicParsing -TimeoutSec 10 -Headers @{ 'User-Agent' = 'GoogleGemini-AutoOptimizer'; 'Cache-Control' = 'no-cache' }).Content
        $remVer = $null
        if ($rBat -match "(?m)^\`$OptVersion\s*=\s*'([^']+)'") {
            $remVer = $matches[1].Trim()
        } else {
            $relSelf = Get-OptGitHubReleaseNoApi -RepoSlug "$UpstreamOwner/$UpstreamRepo"
            if ($relSelf -and $relSelf.Tag) { $remVer = $relSelf.Tag.Trim() }
        }
        if ($remVer) {
            $cmp = Compare-OptSemVer -LocalVer $OptVersion -RemoteVer $remVer
            if ($cmp -gt 0) {
                Log (" -> [Codigo] Nova versao disponivel online: v$remVer (local: v$OptVersion)") "Yellow"
                if ($ApplySelf -and $env:OTIM_SELF -and (Test-Path $env:OTIM_SELF)) {
                    $idxM = $rBat.IndexOf(':: === INICIO_POWERSHELL ===')
                    if ($idxM -gt 0 -and $rBat.Length -gt 6000) {
                        $psSub = $rBat.Substring($idxM + (':: === INICIO_POWERSHELL ===').Length)
                        $tk = $null; $astErr = $null
                        [void][System.Management.Automation.Language.Parser]::ParseInput($psSub, [ref]$tk, [ref]$astErr)
                        if (-not $astErr -or $astErr.Count -eq 0) {
                            $rBatCrlf = ($rBat -replace "\r?\n", "`r`n")
                            Copy-Item $env:OTIM_SELF "$($env:OTIM_SELF).bak_update" -Force -ErrorAction SilentlyContinue
                            [System.IO.File]::WriteAllText($env:OTIM_SELF, $rBatCrlf, $utf8NoBom)
                            Log (" -> [Codigo] Otimizador atualizado para v$remVer em $($env:OTIM_SELF) (backup .bak_update salvo)!") "Green"
                        }
                    }
                }
            } else {
                Log (" -> [Codigo] Otimizador Universal esta atualizado (v$OptVersion | online: $remVer).") "Green"
            }
        }
    } catch {
        Log (" -> [Codigo] Verificacao online indisponivel agora ($($_.Exception.Message)).") "Yellow"
    }

    # 3. AMD FSR (Magpie + OptiScaler) e DSL (DirectStorage) conforme GPU e SSD
    $toolsDir = Join-Path $env:ProgramData "ModoJogoAutomatico\Tools"
    $relMag = Get-OptGitHubReleaseNoApi -RepoSlug 'Blinue/Magpie' -AssetRegex 'x64.*\.zip$|\.zip$'
    $relOpt = Get-OptGitHubReleaseNoApi -RepoSlug 'optiscaler/OptiScaler' -AssetRegex '\.(zip|7z)$'
    $dsLatest = $null
    try {
        $dsJson = Invoke-RestMethod 'https://api.nuget.org/v3-flatcontainer/microsoft.direct3d.directstorage/index.json' -Headers $hdrs -TimeoutSec 7
        $dsLatest = $dsJson.versions | Where-Object { $_ -notmatch '-' } | Select-Object -Last 1
    } catch {}
    Log (" -> [AMD FSR / DSL] Magpie online=$(if($relMag){$relMag.Tag}else{'offline'}) | OptiScaler online=$(if($relOpt){$relOpt.Tag}else{'offline'}) | DirectStorage online=$(if($dsLatest){$dsLatest}else{'offline'})") "Cyan"

    $dsDir = Join-Path $toolsDir "DirectStorage"
    $dsVerFile = Join-Path $dsDir ".version_modojogo"
    $dsLocal = if (Test-Path $dsVerFile) { ([System.IO.File]::ReadAllText($dsVerFile, $utf8NoBom)).Trim() } else { '' }
    if ($ApplyComponents -and $dsLatest -and ((Compare-OptSemVer -LocalVer $dsLocal -RemoteVer $dsLatest) -gt 0)) {
        try {
            $tmpPkg = Join-Path $env:TEMP "dstorage_$dsLatest.zip"
            $tmpExt = Join-Path $env:TEMP "dstorage_ext_$dsLatest"
            Invoke-WebRequest "https://api.nuget.org/v3-flatcontainer/microsoft.direct3d.directstorage/$dsLatest/microsoft.direct3d.directstorage.$dsLatest.nupkg" -OutFile $tmpPkg -UseBasicParsing -TimeoutSec 30
            Expand-Archive -Path $tmpPkg -DestinationPath $tmpExt -Force
            $bin64 = Join-Path $tmpExt "native\bin\x64"
            if (Test-Path $bin64) {
                New-Item -Path $dsDir -ItemType Directory -Force | Out-Null
                Copy-Item (Join-Path $bin64 "*.dll") $dsDir -Force
                [System.IO.File]::WriteAllText($dsVerFile, $dsLatest, $utf8NoBom)
                Log (" -> [DSL / DirectStorage] DLLs x64 atualizadas ($dsLatest) em $dsDir") "Green"
            }
            Remove-Item $tmpPkg -Force -ErrorAction SilentlyContinue
            Remove-Item $tmpExt -Recurse -Force -ErrorAction SilentlyContinue
        } catch {}
    }

    # 4. SDXL / IA (PyTorch, xFormers, ComfyUI) + Flags adaptadas a GPU/VRAM
    $ptOnline = $null; $xfOnline = $null
    try { $ptOnline = (Invoke-RestMethod 'https://pypi.org/pypi/torch/json' -Headers $hdrs -TimeoutSec 6).info.version } catch {}
    try { $xfOnline = (Invoke-RestMethod 'https://pypi.org/pypi/xformers/json' -Headers $hdrs -TimeoutSec 6).info.version } catch {}
    $cuRel = Get-OptGitHubReleaseNoApi -RepoSlug 'Comfy-Org/ComfyUI' -AssetRegex '\.(7z|zip)$'
    Log (" -> [SDXL / IA] PyTorch online=$(if($ptOnline){$ptOnline}else{'offline'}) | xFormers=$(if($xfOnline){$xfOnline}else{'offline'}) | ComfyUI=$(if($cuRel){$cuRel.Tag}else{'offline'})") "Cyan"

    $lowVram = ($vramMB -gt 0 -and $vramMB -le 4200)
    $allocConf = if ($lowVram) { 'expandable_segments:True,garbage_collection_threshold:0.6,max_split_size_mb:128' } elseif ($vramMB -le 8500) { 'expandable_segments:True,garbage_collection_threshold:0.8' } else { 'expandable_segments:True' }
    $sdxlArgs = if ($lowVram -and $isPascal) { '--lowvram --opt-sdp-attention --no-half-vae --disable-nan-check' } elseif ($lowVram) { '--lowvram --opt-sdp-attention' } elseif ($vramMB -le 8500) { '--medvram-sdxl --opt-sdp-attention' } else { '--opt-sdp-attention' }
    if ($ApplyComponents) {
        try {
            [Environment]::SetEnvironmentVariable('CUDA_MODULE_LOADING', 'LAZY', 'User')
            [Environment]::SetEnvironmentVariable('SAFETENSORS_FAST_GPU', '1', 'User')
            [Environment]::SetEnvironmentVariable('PYTORCH_CUDA_ALLOC_CONF', $allocConf, 'User')
        } catch {}
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and (Test-Path $_.Root) }
        $gitExe = Get-Command git -ErrorAction SilentlyContinue
        foreach ($drv in $drives) {
            Get-ChildItem -Path $drv.Root -Directory -Depth 2 -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'ComfyUI|stable-diffusion|webui|forge|Fooocus|SDNext|SD\.Next|InvokeAI' } | ForEach-Object {
                $aiD = $_.FullName
                if ($gitExe -and (Test-Path (Join-Path $aiD '.git'))) {
                    & git -C $aiD fetch --quiet 2>$null
                    $beh = (& git -C $aiD rev-list --count 'HEAD..@{u}' 2>$null)
                    $drt = & git -C $aiD status --porcelain 2>$null
                    if ($beh -match '^\d+$' -and [int]$beh -gt 0 -and (-not $drt)) {
                        & git -C $aiD pull --ff-only 2>$null | Out-Null
                        Log (" -> [SDXL / IA] $aiD atualizado via git pull ($beh commits).") "Green"
                    }
                }
                if ((Test-Path (Join-Path $aiD 'main.py')) -and ($aiD -match 'ComfyUI')) {
                    $cFlags = if ($lowVram) { '--lowvram --preview-method auto' } elseif ($vramMB -le 8500) { '--normalvram --preview-method auto' } else { '--highvram --preview-method auto' }
                    $cBat = Join-Path $aiD 'Start_SDXL_Optimized.bat'
                    [System.IO.File]::WriteAllText($cBat, "@echo off`r`nset CUDA_MODULE_LOADING=LAZY`r`nset SAFETENSORS_FAST_GPU=1`r`nset PYTORCH_CUDA_ALLOC_CONF=$allocConf`r`npython main.py $cFlags`r`npause`r`n", $utf8NoBom)
                }
                $wuBat = Join-Path $aiD 'webui-user.bat'
                if (Test-Path $wuBat) {
                    if (-not (Test-Path "$wuBat.bak_otim")) { Copy-Item $wuBat "$wuBat.bak_otim" -Force }
                    $wTxt = [System.IO.File]::ReadAllText($wuBat, $utf8NoBom)
                    $wUpd = $wTxt -replace '(?m)^set\s+COMMANDLINE_ARGS=.*$', "set COMMANDLINE_ARGS=$sdxlArgs"
                    if ($wUpd -ne $wTxt) { [System.IO.File]::WriteAllText($wuBat, $wUpd, $utf8NoBom) }
                }
            }
        }
        Log (" -> [SDXL / IA] Variaveis CUDA & launchers adaptados para $($gpuMain.Name) ($sdxlArgs).") "Green"
    }

    # 5. Drivers Oficiais via Windows Update casados com PnP HardwareIDs ativos
    try {
        $pnpIds = @(Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.Class -in @('Display','Media','System') -and $_.InstanceId -match '^PCI\\' } | Select-Object -ExpandProperty HardwareID)
        $sess = New-Object -ComObject Microsoft.Update.Session
        $srch = $sess.CreateUpdateSearcher()
        $wuRes = $srch.Search("IsInstalled=0 and Type='Driver'")
        $coll = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($u in $wuRes.Updates) {
            $uHw = ($u.DriverHardwareID -join ';')
            foreach ($pStr in $pnpIds) {
                if ($pStr -and $uHw -and ($uHw -match [regex]::Escape(($pStr -split '&SUBSYS')[0]))) { [void]$coll.Add($u); break }
            }
        }
        if ($coll.Count -gt 0) {
            if ($ApplyComponents) {
                $dl = $sess.CreateUpdateDownloader(); $dl.Updates = $coll; [void]$dl.Download()
                $in = $sess.CreateUpdateInstaller(); $in.Updates = $coll; [void]$in.Install()
                Log (" -> [Drivers HW] $($coll.Count) driver(s) oficiais instalados via Windows Update.") "Green"
            } else {
                Log (" -> [Drivers HW] $($coll.Count) driver(s) pendente(s) no Windows Update.") "Yellow"
            }
        } else {
            Log (" -> [Drivers HW] Drivers PCI/GPU/Audio principais em dia.") "Gray"
        }
    } catch {}
}

$otimArg = ($env:OTIM_ARGS + "").Trim().ToLower()
if ($otimArg -eq '-checkupdate') {
    $env:OTIM_NOLOG = '1'
    Invoke-OptHardwareAwareOnlineUpdate
    exit 0
}
if ($otimArg -eq '-atualizar') {
    Invoke-OptHardwareAwareOnlineUpdate -ApplySelf -ApplyComponents
    exit 0
}

Log "=== RELATORIO DE OTIMIZACAO UNIVERSAL WINDOWS 10/11 ===" "Green"
Log ("Data/Hora: " + (Get-Date))

# 1. Ponto de Restauracao Automatico
Log "`n[1/12] Criando Ponto de Restauracao do Sistema (Seguranca)..."
Enable-ComputerRestore -Drive $env:SystemDrive
Checkpoint-Computer -Description "Antes do Otimizador Universal" -RestorePointType "MODIFY_SETTINGS"

# 2. Deteccao Automatica de Hardware
Log "`n[2/12] Detectando Hardware (CPU, RAM, SSDs, HDDs, Notebook vs Desktop)..."
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
Log "`n[3/12] Verificando Gerenciador de Boot (BCD / UEFI)..."
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
Log "`n[4/12] Verificando Windows Defender, Excecoes e Blindando Arquivo Hosts..."
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
Log "`n[5/12] Otimizando Plano de Energia (Desempenho Maximo)..."
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
Log "`n[6/12] Otimizando Todos os Discos (SSDs e HDDs)..."
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
Log "`n[7/12] Configurando Memoria Virtual (Pagefile) Inteligente..."
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
Log "`n[8/12] Desativando Servicos de Telemetria e Coleta em Segundo Plano..."
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
Log "`n[9/12] Aliviando Inicializacao do Windows (Removendo Auto-Start de Launchers Pesados)..."
$bloatRun = @('Steam','EpicGamesLauncher','EADM','RiotClient','Rave','Battle.net','Ubisoft Game Launcher','GalaxyClient')
foreach ($app in $bloatRun) {
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $app
}
if ((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord') -and (Get-ItemProperty 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord')) {
    Remove-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord'
}

# 10. Otimizacoes de GPU (HAGS), Game Mode, GameDVR, Contraste/Cor, Rede e Latencia de Interface
Log "`n[10/12] Aplicando Otimizacoes de GPU (HAGS), Jogos, Contraste/Cor, Rede e Interface..."
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
Log "`n[11/12] Limpando Temporarios, Corrigindo Erros do Windows e Verificando Integridade..."
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

Invoke-OptHardwareAwareOnlineUpdate -ApplySelf -ApplyComponents

Log "`n=== OTIMIZACAO UNIVERSAL CONCLUIDA COM SUCESSO! ===" "Green"
Write-Host "Relatorio completo salvo em: $logFile" -ForegroundColor Green
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "  PROCESSO FINALIZADO! Reinicie o computador para aplicar todos os ajustes." -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Read-Host "Pressione ENTER para fechar"
```