# Загружает расширение из XML в файловую ИБ, применяет его и проверяет модули.
# Основную конфигурацию не трогает: все команды конфигуратора идут с -Extension.
param([Parameter(Mandatory = $true)][ValidateSet('BSP', 'UF')][string]$Base,
      [Parameter(Mandatory = $true)][string]$Name)
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$cfg = @{ BSP = @('C:\Users\psi\Downloads\AICourse\DBIS06_BSP', 'bsp'); UF = @('C:\Users\psi\Downloads\AICourse\DBIS06_UF', 'uf') }
$ib, $sub = $cfg[$Base]
$src = Join-Path $root "$sub\Extensions\$Name"
$exe = 'C:\Program Files\1cv8\8.5.1.1529\bin\1cv8.exe'
$log = Join-Path $env:TEMP "extload-$Base-$Name.log"
function Designer([string[]]$cmd) {
    if (Test-Path $log) { Remove-Item $log }
    $a = @('DESIGNER', "/F`"$ib`"", '/N"Администратор"', '/P""', '/DisableStartupDialogs', '/DisableStartupMessages') + $cmd + @('/Out', "`"$log`"")
    $p = Start-Process $exe -ArgumentList $a -Wait -PassThru
    $text = if (Test-Path $log) { Get-Content $log -Raw -Encoding UTF8 } else { '' }
    [pscustomobject]@{ Code = $p.ExitCode; Log = "$text" }
}
$r = Designer @('/LoadConfigFromFiles', "`"$src`"", '-Extension', $Name, '/UpdateDBCfg')
Write-Output "== Загрузка ($($r.Code)): $($r.Log.Trim())"
if ($r.Code -ne 0) { exit 1 }
$r = Designer @('/CheckModules', '-ThinClient', '-Server', '-Extension', $Name)
Write-Output "== Проверка модулей ($($r.Code)): $($r.Log.Trim())"
exit $r.Code
