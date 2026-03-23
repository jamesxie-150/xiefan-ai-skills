$doc = Get-ChildItem -Path ".github/skills/xf-radiology-schedule/references/*" -Filter "2025.3.24-2025.3.30.docx" -Recurse | Select-Object -First 1
if (-not $doc) {
  Write-Output "ERROR: docx not found"
  exit 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($doc.FullName)
$entry = $zip.Entries | Where-Object { $_.FullName -eq "word/document.xml" }
$sr = New-Object System.IO.StreamReader($entry.Open())
$xml = $sr.ReadToEnd()
$sr.Close()
$zip.Dispose()

$text = $xml -replace '</w:p>', '¶' -replace '<w:tab/>', ' ' -replace '<[^>]+>', ''
$text = $text -replace '&amp;', '&' -replace '&lt;', '<' -replace '&gt;', '>'
$parts = $text.Split('¶') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

$start = [Array]::IndexOf($parts, '卓雷')
if ($start -lt 0) {
  Write-Output "ERROR: start name not found"
  exit 1
}

function Get-Weight([string]$s) {
  if ($s -like '*值修*' -or $s -like '*下派*' -or $s -like '*规培*' -or $s -like '*进修*' -or $s -like '*怀孕*' -or $s -like '*休假*') { return 0.0 }
  if ($s -eq '休') { return 1.0 }
  if ($s -like '*/休*' -or $s -like '*休/*' -or $s -eq '上彩/修') { return 0.5 }
  return 0.0
}

$rows = @()
$errors = @()
$unknown = @{}

$i = $start
$idx = 1
while ($i -lt $parts.Count) {
  $name = $parts[$i]
  if ($name -like '备注：*') { break }

  if ($i + 7 -ge $parts.Count) {
    $errors += "数据格式错误：第$idx人（$name）排班项不足7，已跳过"
    break
  }

  $days = @($parts[$i+1], $parts[$i+2], $parts[$i+3], $parts[$i+4], $parts[$i+5], $parts[$i+6], $parts[$i+7])
  $vac = 0.0
  foreach ($d in $days) {
    $w = Get-Weight $d
    $vac += $w
    if ($w -eq 0.0 -and $d -ne '休' -and ($d -like '*休*' -or $d -like '*修*')) {
      if (-not $unknown.ContainsKey($d)) { $unknown[$d] = 0 }
      $unknown[$d]++
    }
  }

  $vac = [math]::Round($vac, 1)
  $bal = [math]::Round(2.0 - $vac, 1)
  $status = if ($bal -gt 0) { '少休' } elseif ($bal -lt 0) { '多休' } else { '正常' }
  $balShow = if ($bal -gt 0) { "+$bal" } else { "$bal" }

  $rows += [PSCustomObject]@{
    Name = $name
    D1 = $days[0]
    D2 = $days[1]
    D3 = $days[2]
    D4 = $days[3]
    D5 = $days[4]
    D6 = $days[5]
    D7 = $days[6]
    Vacation = $vac
    Balance = $balShow
    Status = $status
  }

  $i += 8
  $idx += 1
}

$normal = ($rows | Where-Object { $_.Status -eq '正常' }).Count
$less = ($rows | Where-Object { $_.Status -eq '少休' }).Count
$more = ($rows | Where-Object { $_.Status -eq '多休' }).Count

Write-Output "HEADER|放射科排班分析 v1.0.0"
Write-Output "SUMMARY|TOTAL=$($rows.Count)|NORMAL=$normal|LESS=$less|MORE=$more"
foreach ($r in $rows) {
  Write-Output ("ROW|{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}" -f $r.Name,$r.D1,$r.D2,$r.D3,$r.D4,$r.D5,$r.D6,$r.D7,$r.Vacation,$r.Balance,$r.Status)
}
foreach ($e in $errors) {
  Write-Output "ERR|$e"
}
foreach ($k in ($unknown.Keys | Sort-Object)) {
  Write-Output "UNK|$k|$($unknown[$k])"
}
