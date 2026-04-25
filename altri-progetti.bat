@echo off
pushd "%~dp0"
:: Lancia powershell in modalità nascosta per non vedere flash neri prolungati
start /b powershell -ExecutionPolicy Bypass -File "lanciaVSC.ps1"
popd