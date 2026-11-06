# Сквозная проверка обмена: выгрузка из БСП (Vanessa) → соответствия (BSL) → загрузка дважды (Vanessa) → сверка данных (BSL).
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$root = Split-Path $PSScriptRoot -Parent
$uf = Join-Path $root 'uf\Extensions\ЗагрузкаСчетовБСП'
$steps = @(
    @{ N = 'Сброс УФ';      C = { & "$PSScriptRoot\test.ps1" -Base UF -Tests (Join-Path $uf 'tests\e2e-sbros.bsl') } },
    @{ N = 'Выгрузка БСП';  C = { & "$PSScriptRoot\va-run.ps1" -Base BSP -Feature (Join-Path $root 'bsp\Extensions\ОбменСчетами\features\vygruzka.feature') } },
    @{ N = 'Соответствия';  C = { & "$PSScriptRoot\test.ps1" -Base UF -Tests (Join-Path $uf 'tests\e2e-sootvetstviya.bsl') } },
    @{ N = 'Загрузка x2';   C = { & "$PSScriptRoot\va-run.ps1" -Base UF -Feature (Join-Path $uf 'features\skvoznoj.feature') } },
    @{ N = 'Проверка УФ';   C = { & "$PSScriptRoot\test.ps1" -Base UF -Tests (Join-Path $uf 'tests\e2e-proverka.bsl') } }
)
foreach ($s in $steps) {
    Write-Output "=== $($s.N)"
    & $s.C
    if ($LASTEXITCODE -ne 0) { Write-Output "СТОП: шаг «$($s.N)» не прошел"; exit 1 }
}
Write-Output "=== Сквозная проверка пройдена"
