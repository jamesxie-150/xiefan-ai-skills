param(
    [Parameter(Mandatory=$false)]
    [string]$DocxPath,
    [Parameter(Mandatory=$false)]
    [string]$OutputPath
)

# 如果参数为空，使用默认路径
if (-not $DocxPath) {
    $DocxPath = ".github\skills\xf-radiology-schedule\references\输入参考用例\2025.3.24-2025.3.30.docx"
}

if (-not $OutputPath) {
    $OutputPath = "utils\radiology-output-template-demo.md"
}

# 检查文件是否存在
if (-not (Test-Path $DocxPath)) {
    Write-Error "文件不存在: $DocxPath"
    exit 1
}

# 解析 DOCX（Office Open XML）
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($DocxPath)
$entry = $zip.Entries | Where-Object { $_.FullName -eq "word/document.xml" }

if (-not $entry) {
    Write-Error "无法找到 document.xml"
    $zip.Dispose()
    exit 1
}

$sr = New-Object System.IO.StreamReader($entry.Open())
$xml = $sr.ReadToEnd()
$sr.Close()
$zip.Dispose()

# 清理 XML 并提取表格内容
$text = $xml -replace '</w:p>', '¶' -replace '<w:tab/>', ' ' -replace '<[^>]+>', ''
$text = $text -replace '&amp;', '&' -replace '&lt;', '<' -replace '&gt;', '>'
$parts = $text.Split('¶') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

# 权重计算函数
function Get-Weight([string]$s) {
    if ($s -like '*值修*' -or $s -like '*值休*' -or $s -like '*下派*' -or $s -like '*规培*' -or $s -like '*进修*' -or $s -like '*怀孕*' -or $s -like '*休假*') {
        return 0.0
    }
    if ($s -eq '休') {
        return 1.0
    }
    if ($s -like '*/休*' -or $s -like '*休/*' -or $s -eq '上彩/修') {
        return 0.5
    }
    return 0.0
}

# 定位起始位置
$start = [Array]::IndexOf($parts, '卓雷')
if ($start -lt 0) {
    Write-Error "无法找到起始姓名"
    exit 1
}

# 解析数据
$rows = @()
$errors = @()
$unknown = @{}
$i = $start
$idx = 1

while ($i -lt $parts.Count) {
    $name = $parts[$i]
    if ($name -like '备注：*') {
        break
    }

    if ($i + 7 -ge $parts.Count) {
        $errors += "⚠️ 数据格式错误：第$idx人（$name）排班项不足7，已跳过。"
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
    $status = if ($bal -gt 0) { '🔴 少休' } elseif ($bal -lt 0) { '🟡 多休' } else { '✅ 正常' }
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
    $idx++
}

# 汇总统计
$normal = ($rows | Where-Object { $_.Status -eq '✅ 正常' }).Count
$less = ($rows | Where-Object { $_.Status -eq '🔴 少休' }).Count
$more = ($rows | Where-Object { $_.Status -eq '🟡 多休' }).Count

# 生成 Markdown 输出
$output = @()
$output += "放射科排班分析 v1.0.0"
$output += "---"
$output += ""
$output += "## 📊 本周排班工时盈亏统计（Word 文件试运行）"
$output += "|人员|周一|周二|周三|周四|周五|周六|周日|实际休假(天)|盈亏(天)|状态|"
$output += "|---|---|---|---|---|---|---|---|---|---|---|"

foreach ($r in $rows) {
    $line = "|$($r.Name)|$($r.D1)|$($r.D2)|$($r.D3)|$($r.D4)|$($r.D5)|$($r.D6)|$($r.D7)|$($r.Vacation)|$($r.Balance)|$($r.Status)|"
    $output += $line
}

$output += ""
$output += "> ℹ️ 基准：标准周休 2 天；盈亏 = 2 - 实际休假天数；正值=少休，负值=多休。"
$output += ""
$output += "### 📝 计算说明"

foreach ($r in $rows) {
    $note = ""
    if ($r.Vacation -eq 2) {
        $note = "标准双休，正常。"
    } elseif ($r.Vacation -gt 2) {
        $note = "$($r.Vacation)天休假，多休$((-1)*([math]::Round($r.Balance, 1)))天。"
    } else {
        $note = "$($r.Vacation)天休假，少休$($r.Balance)天。"
    }
    $output += "- **$($r.Name)**：$note"
}

$output += ""
$output += "### ⚠️ 数据错误（如有）"
if ($errors.Count -eq 0) {
    $output += "- 无"
} else {
    $output += $errors
}

$output += ""
$output += "### ❓ 未知状态码清单（如有）"
if ($unknown.Keys.Count -eq 0) {
    $output += "- 无"
} else {
    $output += "|状态码|出现次数|当前权重|建议操作|"
    $output += "|---|---|---|---|"
    foreach ($k in ($unknown.Keys | Sort-Object)) {
        $output += "|$k|$($unknown[$k])|0|请确认是否需要定义为特殊权重|"
    }
}

$output += ""
$output += "### 📌 汇总"
$output += "- 共解析人员：$($rows.Count)"
$output += "- ✅ 正常：$normal"
$output += "- 🔴 少休：$less"
$output += "- 🟡 多休：$more"
$output += ""
$output += "> 本文档由 Word 解析模块自动生成，遵循固定输出模板。"

# 写入文件
$output | Set-Content -Path $OutputPath -Encoding UTF8
Write-Host "✅ 输出已保存: $OutputPath"
Write-Host "📋 解析人数: $($rows.Count) | 正常: $normal | 少休: $less | 多休: $more"
