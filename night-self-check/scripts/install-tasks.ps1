# Register the demo-time night slots as Windows tasks. Does not start a chat loop.
$ErrorActionPreference = 'Stop'
$skill = Split-Path $PSScriptRoot -Parent
$run = Join-Path $PSScriptRoot 'run-slot.ps1'
$schedulePath = Join-Path $skill 'schedule.json'
if (-not (Test-Path $run)) { throw "missing $run" }
if (-not (Test-Path $schedulePath)) { throw "missing $schedulePath" }
$schedule = Get-Content $schedulePath -Raw -Encoding UTF8 | ConvertFrom-Json
$root = [string]$schedule.repoRoot
if (-not $root -or -not (Test-Path $root)) { throw 'schedule.json 的 repoRoot 不存在' }

$old = Get-ScheduledTask -TaskName 'TongxuNightCheck' -EA SilentlyContinue
if ($old) {
  Disable-ScheduledTask -TaskName 'TongxuNightCheck' | Out-Null
  Write-Host 'disabled old TongxuNightCheck (20:00 single run)'
}

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

foreach ($slot in $schedule.slots) {
  if ($slot.at -notmatch '^\d{2}:\d{2}$') { throw "bad time: $($slot.at)" }
  $name = 'TongxuNight-' + $slot.id
  $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$run`" -Slot $($slot.id)"
  $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arg -WorkingDirectory $root
  $trigger = New-ScheduledTaskTrigger -Daily -At ([string]$slot.at)
  Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force | Out-Null
  $info = Get-ScheduledTaskInfo -TaskName $name
  Write-Host ("{0}  {1}  next {2}" -f $name, $slot.at, $info.NextRunTime)
}
Write-Host 'installed. default times are the demo times in schedule.json'
