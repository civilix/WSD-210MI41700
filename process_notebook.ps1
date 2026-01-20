$inputFile = "prediction_insights.ipynb"
$outputFile = "prediction_insights.ipynb"

# Load content
$jsonContent = Get-Content -Path $inputFile -Raw -Encoding UTF8 | ConvertFrom-Json

# Filter out markdown cells
$jsonContent.cells = $jsonContent.cells | Where-Object { $_.cell_type -ne "markdown" }

# Translation Map
$translations = Get-Content -Path "translations.json" -Raw -Encoding UTF8 | ConvertFrom-Json

# Apply translations to code cells and outputs
foreach ($cell in $jsonContent.cells) {
    if ($cell.cell_type -eq "code") {
        # Valid source
        if ($cell.source) {
            for ($i = 0; $i -lt $cell.source.Count; $i++) {
                $line = $cell.source[$i]
                foreach ($prop in $translations.PSObject.Properties) {
                    $key = $prop.Name
                    $value = $prop.Value
                    if ($line -match [regex]::Escape($key)) {
                       $line = $line -replace [regex]::Escape($key), $value
                    }
                }
                $cell.source[$i] = $line
            }
        }
        
        # Process Outputs
        if ($cell.outputs) {
            foreach ($output in $cell.outputs) {
                # Handle stream output (text)
                if ($output.name -eq "stdout" -and $output.text) {
                     for ($j = 0; $j -lt $output.text.Count; $j++) {
                        $line = $output.text[$j]
                        foreach ($prop in $translations.PSObject.Properties) {
                            $key = $prop.Name
                            $value = $prop.Value
                            if ($line -match [regex]::Escape($key)) {
                               $line = $line -replace [regex]::Escape($key), $value
                            }
                        }
                        $output.text[$j] = $line
                     }
                }
                # Handle data text/plain
                if ($output.data -and $output.data."text/plain") {
                     for ($k = 0; $k -lt $output.data."text/plain".Count; $k++) {
                        $line = $output.data."text/plain"[$k]
                         foreach ($prop in $translations.PSObject.Properties) {
                            $key = $prop.Name
                            $value = $prop.Value
                            if ($line -match [regex]::Escape($key)) {
                               $line = $line -replace [regex]::Escape($key), $value
                            }
                        }
                        $output.data."text/plain"[$k] = $line
                     }
                }
            }
        }
    }
}

# Save content
$jsonContent | ConvertTo-Json -Depth 100 | Set-Content -Path $outputFile -Encoding UTF8
Write-Host "Processed $outputFile"
