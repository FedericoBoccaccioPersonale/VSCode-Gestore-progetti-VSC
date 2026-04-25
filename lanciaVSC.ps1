Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Forza PowerShell a usare UTF8 per tutta la sessione
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$jsonPath = Join-Path $PSScriptRoot "progetti.json"

# Usiamo un metodo .NET più robusto per leggere il file con codifica UTF8
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$jsonContent = [System.IO.File]::ReadAllText($jsonPath, [System.Text.Encoding]::UTF8)
$progetti = $jsonContent | ConvertFrom-Json

$form = New-Object Windows.Forms.Form
$form.Text = "VS Code Project Launcher"
$form.Size = [System.Drawing.Size]::new(510, ($progetti.Count * 75 + 85))
$form.StartPosition = "CenterScreen"
$form.BackColor = "#F5F5F5"

# --- GESTIONE ICONA ---
$iconPath = "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"
if (-not (Test-Path $iconPath)) 
{ 
    $iconPath = "$env:ProgramFiles\Microsoft VS Code\Code.exe" 
}

if (Test-Path $iconPath)
{
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
}

$y = 20

$LaunchProject = 
{
    param($path, $nome, $tipo, $objForm)
    
    if (-not $path -or -not (Test-Path $path))
    {
        [Windows.Forms.MessageBox]::Show("Il workspace di $tipo per '$nome' non esiste.", "Mancante")
    }
    else
    {
        Start-Process -FilePath "code" -ArgumentList "`"$path`"" -WindowStyle Hidden
        # Chiude la finestra del launcher
        $objForm.Close()
    }
}

foreach ($p in $progetti)
{
    $label = New-Object Windows.Forms.Label
    $label.Text = $p.Nome
    $label.Location = [System.Drawing.Point]::new(20, ($y + 5))
    $label.AutoSize = $true
    $label.ForeColor = "#202020"
    $label.Font = New-Object Drawing.Font("Segoe UI", 10, [Drawing.FontStyle]::Bold)
    $form.Controls.Add($label)

    $pathDev = $p.Sviluppo
    $pathProd = $p.Produzione
    $nomePrj = $p.Nome

    $btnDev = New-Object Windows.Forms.Button
    $btnDev.Text = "SVILUPPO"
    $btnDev.Location = [System.Drawing.Point]::new(265, $y)
    $btnDev.Size = [System.Drawing.Size]::new(100, 32)
    $btnDev.BackColor = "#28A745"
    $btnDev.ForeColor = "White"
    $btnDev.FlatStyle = "Flat"
    $btnDev.Add_Click({ &$LaunchProject $pathDev $nomePrj "SVILUPPO" $form }.GetNewClosure())
    $form.Controls.Add($btnDev)

    $btnProd = New-Object Windows.Forms.Button
    $btnProd.Text = "PRODUZIONE"
    $btnProd.Location = [System.Drawing.Point]::new(375, $y)
    $btnProd.Size = [System.Drawing.Size]::new(100, 32)
    $btnProd.BackColor = "#DC3545"
    $btnProd.ForeColor = "White"
    $btnProd.FlatStyle = "Flat"
    $btnProd.Add_Click({ &$LaunchProject $pathProd $nomePrj "PRODUZIONE" $form }.GetNewClosure())
    $form.Controls.Add($btnProd)

    $y += 65
}

$form.ShowDialog()