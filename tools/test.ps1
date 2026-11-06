# Запускает серверные тесты BSL (файлы *.bsl) в ИБ. Тест присваивает Результат = "OK" или текст ошибки.
# Код выхода 0 — все тесты вернули строку, начинающуюся с OK.
param([Parameter(Mandatory = $true)][ValidateSet('BSP', 'UF')][string]$Base,
      [Parameter(Mandatory = $true)][string[]]$Tests)
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$failed = 0
foreach ($t in $Tests) {
    $r = (& (Join-Path $PSScriptRoot 'run-bsl.ps1') -Base $Base -Code $t | Out-String).Trim()
    if ($r.StartsWith('OK')) { Write-Output "PASS $t :: $r" } else { $failed++; Write-Output "FAIL $t :: $r" }
}
Write-Output "Итого: $($Tests.Count - $failed)/$($Tests.Count)"
exit $failed
