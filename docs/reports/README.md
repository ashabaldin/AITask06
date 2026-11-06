# Результаты проверки обмена «Счет БСП → Заказ УФ» (2026-11-06)

Сквозной прогон: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\e2e.ps1`
(сброс заказов обмена → выгрузка из БСП → соответствия → загрузка дважды → проверка данных).

| Шаг | Результат |
|---|---|
| Выгрузка БСП (Vanessa `vygruzka.feature`) | status=0, 1 сценарий, 0 ошибок; 9 счетов в `exchange\invoices.json` |
| Соответствия (`e2e-sootvetstviya.bsl`) | 39 записей регистра (ручное сопоставление, имена в демобазах различаются) |
| Загрузка ×2 (Vanessa `skvoznoj.feature`) | 1-я: загружено 7, пропущено 2 (помечены в БСП); 2-я: обновлено 7, дублей нет |
| Проверка УФ (`e2e-proverka.bsl`) | 7 заказов, не проведены, шапка и строки совпадают с файлом; всего заказов 27 = 20 + 7 |

Модульные тесты: `tools\test.ps1 -Base BSP -Tests bsp\Extensions\ОбменСчетами\tests\vygruzka.bsl`,
`tools\test.ps1 -Base UF -Tests "uf\Extensions\ЗагрузкаСчетовБСП\tests\sopostavlenie.bsl,uf\Extensions\ЗагрузкаСчетовБСП\tests\zagruzka.bsl"`.

Скриншоты — `screens\`: выгрузка БСП, протокол первой и повторной загрузки, список заказов УФ, UI-тест загрузки.
