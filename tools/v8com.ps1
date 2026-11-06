# Помощник для COM-соединения с файловыми ИБ 1С (позднее связывание).
# Ранняя привязка PowerShell к V85.COMConnector падает с TYPE_E_LIBNOTREGISTERED,
# поэтому методы и свойства вызываются через Type.InvokeMember.
# Источник приема: https://learn.microsoft.com/dotnet/api/system.type.invokemember

[Console]::OutputEncoding = [Text.Encoding]::UTF8

function V8-Call($obj, [string]$name, [object[]]$params = @()) {
    $obj.GetType().InvokeMember($name, [Reflection.BindingFlags]::InvokeMethod, $null, $obj, $params)
}
function V8-Get($obj, [string]$name) {
    $obj.GetType().InvokeMember($name, [Reflection.BindingFlags]::GetProperty, $null, $obj, $null)
}
function V8-Set($obj, [string]$name, $value) {
    [void]$obj.GetType().InvokeMember($name, [Reflection.BindingFlags]::SetProperty, $null, $obj, @($value))
}

function V8-Connect([string]$Path, [string]$User = 'Администратор') {
    $c = New-Object -ComObject V85.COMConnector
    V8-Call $c 'Connect' @("File=""$Path"";Usr=""$User"";Pwd="""";")
}

# Выполняет запрос и возвращает массив PSCustomObject с колонками выборки (простые значения).
function V8-Query($ib, [string]$Text, [hashtable]$Params = @{}) {
    $q = V8-Call $ib 'NewObject' @('Запрос')
    V8-Set $q 'Текст' $Text
    foreach ($k in $Params.Keys) { [void](V8-Call $q 'УстановитьПараметр' @($k, $Params[$k])) }
    $res = V8-Call $q 'Выполнить'
    $cols = V8-Get $res 'Колонки'
    $names = @(); $n = V8-Call $cols 'Количество'
    for ($i = 0; $i -lt $n; $i++) { $names += (V8-Get (V8-Call $cols 'Получить' @($i)) 'Имя') }
    $sel = V8-Call $res 'Выбрать'
    $out = @()
    while (V8-Call $sel 'Следующий') {
        $row = [ordered]@{}
        foreach ($nm in $names) {
            $v = V8-Get $sel $nm
            if ($v -is [__ComObject]) { $v = V8-Call $ib 'String' @($v) }
            $row[$nm] = $v
        }
        $out += [pscustomobject]$row
    }
    $out
}
