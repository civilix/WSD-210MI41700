$content = Get-Content -Path "prediction_insights.ipynb" -Raw -Encoding UTF8 | ConvertFrom-Json
$chinesePattern = "[\u4e00-\u9fff]"
$lines = @()

foreach ($cell in $content.cells) {
    if ($cell.cell_type -eq "code") {
        foreach ($line in $cell.source) {
            if ($line -match $chinesePattern) {
                $lines += $line.Trim()
            }
        }
    }
}

$lines | Set-Content -Path "chinese_lines.txt" -Encoding UTF8
