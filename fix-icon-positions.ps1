# ==============================================================
# Script: FixDesktopIconLayout.ps1
# Autor: Rafael
# Função: Limpa caches e chaves de layout do Explorer
# Compatível com Windows 10 e 11
# ==============================================================

Write-Host "Criando ponto de restauracao do sistema..."
Checkpoint-Computer -Description "Antes da correcao do layout de icones" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Encerrando o Explorer..."
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# =======================
# Apagar caches do Explorer
# =======================
$explorerDir = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
if (Test-Path $explorerDir) {
    Write-Host "Limpando caches de icones e miniaturas..."
    Get-ChildItem "$explorerDir\*" -Include "iconcache*.db","thumbcache*.db","desktop*.ini" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

# =======================
# Apagar chaves Bags e BagMRU
# =======================
Write-Host "Limpando chaves de layout de pasta (Bags e BagMRU)..."
$regShellPath = "HKCU:\Software\Microsoft\Windows\Shell"
if (Test-Path "$regShellPath\Bags")   { Remove-Item "$regShellPath\Bags"   -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path "$regShellPath\BagMRU") { Remove-Item "$regShellPath\BagMRU" -Recurse -Force -ErrorAction SilentlyContinue }

# =======================
# Corrigir politica de salvamento de layout
# =======================
$policyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
if (!(Test-Path $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
Set-ItemProperty -Path $policyPath -Name "NoSaveSettings" -Type DWord -Value 0

# =======================
# Reiniciar Explorer
# =======================
Write-Host ""
Write-Host "Reiniciando o Explorer..."
Start-Process explorer.exe
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "Correcao concluida!"
Write-Host "Agora organize seus icones e reinicie o PC para testar a persistencia."
# ==============================================================