# Запуск сценария Vanessa для файловой ИБ проекта и краткий итог по junit.xml.
param([Parameter(Mandatory = $true)][ValidateSet('BSP', 'UF')][string]$Base,
      [Parameter(Mandatory = $true)][string]$Feature)
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$ib = @{ BSP = 'C:\Users\psi\Downloads\AICourse\DBIS06_BSP'; UF = 'C:\Users\psi\Downloads\AICourse\DBIS06_UF' }[$Base]
$profile = @{ BSP = 'БСП'; UF = 'UF' }[$Base]
& powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\psi\Vanessa\va.ps1 -Feature $Feature -InfoBasePath $ib `
    -Profile $profile -User 'Администратор' -Exe 'C:\Program Files\1cv8\8.5.1.1529\bin\1cv8c.exe' *> $null
$run = Get-ChildItem C:\Users\psi\Vanessa\reports -Directory -Filter 'run-*' | Sort-Object Name | Select-Object -Last 1
$status = (Get-Content (Join-Path $run.FullName 'status.txt') -Raw).Trim([char]0xFEFF, ' ', "`r", "`n")
[xml]$j = Get-Content (Join-Path $run.FullName 'junit.xml') -Raw -Encoding UTF8
$tests = ($j.SelectNodes('//testcase')).Count
$bad = ($j.SelectNodes('//failure|//error|//skipped')).Count
Write-Output "Отчет: $($run.FullName)"
Write-Output "status=$status tests=$tests failures=$bad"
if ($bad -gt 0 -or $status -ne '0' -or $tests -eq 0) {
    Select-String -Path (Join-Path $run.FullName 'steps.log') -Pattern 'Pending|не выполнен|Failed:' -Encoding UTF8 | Select-Object -First 3 | ForEach-Object { $_.Line }
    exit 1
}
exit 0
