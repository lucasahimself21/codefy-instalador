
# Instala o comando "codefy" sem Docker e sem administrador: Node e CodeFy ficam em %LOCALAPPDATA%\CodeFy.
# codefy = terminal na pasta atual; codefy web = o site (arquivos, chat, terminal) na pasta atual.
$ErrorActionPreference = 'Continue'
# Roda tudo nesta janela: alguns Windows (antivírus/política) bloqueiam abrir outro powershell.exe.
try { Set-ExecutionPolicy -Scope Process Bypass -Force } catch {}
[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue' # a barra de progresso deixa o download muito lento no PowerShell 5
$Base = if ($env:CODEFY_BASE) { $env:CODEFY_BASE } else { 'https://raw.githubusercontent.com/lucasahimself21/codefy-instalador/main' }
$Dir = Join-Path $env:LOCALAPPDATA 'CodeFy'
$NodeDir = Join-Path $Dir 'node'
$NpmDir = Join-Path $Dir 'npm'

function B($t) { Write-Host $t -ForegroundColor White }
function Ok($t) { Write-Host "✓ $t" -ForegroundColor Green }
function Warn($t) { Write-Host "! $t" -ForegroundColor Yellow }
# throw, não exit: rodando por "irm | iex" o exit fecharia a janela antes de dar pra ler o erro.
function Fail($t) { Write-Host "✗ $t" -ForegroundColor Red; throw 'Instalação interrompida.' }
function Yes($q) { $a = Read-Host "$q [S/n]"; return -not ($a -match '^[nN]') }

Clear-Host
B 'CodeFy: instalação'
Write-Host 'Não precisa de Docker nem de administrador. Leva 1 ou 2 minutos.'
Write-Host ''

# ---- 1) Node (o CodeFy roda nele) ----
New-Item -ItemType Directory -Force $Dir | Out-Null
$node = Get-Command node -ErrorAction SilentlyContinue
$nodeOk = $node -and ([int]((& node -v) -replace '^v(\d+).*', '$1') -ge 18)
if (Test-Path (Join-Path $NodeDir 'node.exe')) { $nodeOk = $false } # já tem o nosso: usa ele
if ($nodeOk) { $NodeBin = Split-Path $node.Source; Ok "Node $(& node -v) já instalado" }
else {
  $NodeBin = $NodeDir
  if (-not (Test-Path (Join-Path $NodeDir 'node.exe'))) {
    Write-Host 'Baixando o Node.js…'
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
    try {
      $sums = (Invoke-WebRequest -UseBasicParsing -TimeoutSec 60 'https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt').Content
      $zipName = ([regex]::Match($sums, "node-v[\d.]+-win-$arch\.zip")).Value
      $zip = Join-Path $env:TEMP $zipName
      Invoke-WebRequest -UseBasicParsing -TimeoutSec 600 "https://nodejs.org/dist/latest-v22.x/$zipName" -OutFile $zip
      $tmp = Join-Path $Dir 'node-tmp'
      Remove-Item -Recurse -Force $tmp, $NodeDir -ErrorAction SilentlyContinue
      Expand-Archive -Force $zip $tmp
      Move-Item (Get-ChildItem $tmp -Directory | Select-Object -First 1).FullName $NodeDir
      Remove-Item -Recurse -Force $tmp, $zip -ErrorAction SilentlyContinue
    } catch { Fail 'Não consegui baixar o Node.js. Confira a internet e tente de novo.' }
  }
  Ok 'Node.js pronto'
}
$env:Path = "$NpmDir;$NodeBin;$env:Path"

# ---- 2) CodeFy ----
Write-Host 'Baixando o CodeFy…'
& (Join-Path $NodeBin 'npm.cmd') install -g --prefix $NpmDir --no-audit --no-fund --loglevel=error --update-notifier=false "$Base/codefy-cli.tgz"
if ($LASTEXITCODE -or -not (Test-Path (Join-Path $NpmDir 'codefy.cmd'))) { Fail 'Não consegui instalar o CodeFy. Confira a internet e tente de novo.' }
Ok 'CodeFy instalado'

# Põe o comando no PATH do usuário (e tira o comando antigo do modo Docker, se tiver).
$old = Join-Path $Dir 'bin'
Remove-Item -Force (Join-Path $old 'codefy.cmd'), (Join-Path $old 'codefy.ps1') -ErrorAction SilentlyContinue
$up = ([Environment]::GetEnvironmentVariable('Path', 'User') -split ';') | Where-Object { $_ -and $_ -ne $old -and $_ -ne $NpmDir -and $_ -ne $NodeDir }
$add = @($NpmDir) + $(if ($NodeBin -eq $NodeDir) { @($NodeDir) } else { @() })
[Environment]::SetEnvironmentVariable('Path', (($add + $up) -join ';'), 'User')

# Git traz o bash que o agente usa nos comandos; sem ele, o CodeFy usa o Prompt de Comando.
if (-not (Get-Command git -ErrorAction SilentlyContinue) -and (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host 'Instalando o Git (opcional)…'
  winget install -e --id Git.Git --scope user --silent --accept-package-agreements --accept-source-agreements *> $null
  if ($LASTEXITCODE) { Warn 'O Git não instalou; tudo bem, o CodeFy funciona sem ele.' } else { Ok 'Git instalado' }
}

# ---- 3) Conexão ----
Write-Host ''
& (Join-Path $NpmDir 'codefy.cmd') check
if ($LASTEXITCODE -eq 1) { Write-Host 'Depois que o admin liberar, é só usar o codefy (não precisa instalar de novo).' -ForegroundColor Yellow }

Write-Host ''
B 'CodeFy instalado.'
Write-Host 'Abra um terminal novo, entre na pasta do seu projeto e rode:'
Write-Host '  codefy            o CodeFy no terminal'
Write-Host '  codefy web        o CodeFy no navegador (arquivos, chat e terminal)'
Write-Host 'Ele avisa quando tiver versão nova.'
Write-Host ''
$Def = Join-Path $env:USERPROFILE 'CodeFy'
if (Yes "Abrir o CodeFy agora no navegador (pasta $Def)?") {
  New-Item -ItemType Directory -Force $Def | Out-Null
  Set-Location $Def
  & (Join-Path $NpmDir 'codefy.cmd') web
}
