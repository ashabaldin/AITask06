# Выполняет файл BSL на сервере файловой ИБ через тонкий клиент и обработку ЗапускBSL.epf.
# Код должен присвоить строку переменной Результат; она печатается в stdout.
# Пример: powershell -File tools\run-bsl.ps1 -Base UF -Code tools\recon\uf.bsl
param(
    [Parameter(Mandatory = $true)][ValidateSet('BSP', 'UF')][string]$Base,
    [Parameter(Mandatory = $true)][string]$Code,
    [int]$TimeoutSec = 300
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$paths = @{ BSP = 'C:\Users\psi\Downloads\AICourse\DBIS06_BSP'; UF = 'C:\Users\psi\Downloads\AICourse\DBIS06_UF' }
$exe = 'C:\Program Files\1cv8\8.5.1.1529\bin\1cv8c.exe'
$epf = Join-Path $PSScriptRoot 'bin\ЗапускBSL.epf'
$codePath = (Resolve-Path $Code).Path
$out = [IO.Path]::Combine($env:TEMP, "runbsl-$([guid]::NewGuid()).txt")
$args = @('ENTERPRISE', "/F`"$($paths[$Base])`"", '/N"Администратор"', '/P""', '/DisableStartupDialogs',
          '/DisableStartupMessages', "/Execute`"$epf`"", "/C`"$codePath;$out`"")
$p = Start-Process -FilePath $exe -ArgumentList $args -PassThru
if (-not $p.WaitForExit($TimeoutSec * 1000)) { $p.Kill(); throw "Таймаут $TimeoutSec с" }
if (-not (Test-Path $out)) { throw "Нет файла результата (клиент не выполнил код или не стартовал)" }
Get-Content $out -Encoding UTF8 -Raw
Remove-Item $out
