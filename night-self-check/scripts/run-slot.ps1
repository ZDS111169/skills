# One night-check slot. Read-only. No chat, no pack, no proxy change.
param(
  [Parameter(Mandatory = $true)][string]$Slot
)
$ErrorActionPreference = 'Continue'
$here = Split-Path $PSScriptRoot -Parent
$schedule = Get-Content (Join-Path $here 'schedule.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$root = [string]$schedule.repoRoot
if (-not $root -or -not (Test-Path $root)) { Write-Host 'schedule.json de repoRoot bu cun zai'; exit 1 }
$known = @($schedule.slots | ForEach-Object { $_.id })
if ($known -notcontains $Slot) {
  Write-Host ("Slot must be one of: " + ($known -join ', '))
  exit 1
}
$when = Get-Date -Format 'yyyy-MM-dd HH:mm'
$day = Get-Date -Format 'yyyy-MM-dd'
$title = @($schedule.slots | Where-Object { $_.id -eq $Slot } | Select-Object -First 1).title
$trace = Join-Path $root 'docs\夜间自检-痕迹.md'
$result = Join-Path $root 'docs\夜间自检-结果.md'
$acceptedPath = Join-Path $here 'accepted.txt'
$accepted = @()
if (Test-Path $acceptedPath) {
  $accepted = @(Get-Content $acceptedPath -Encoding UTF8 | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' })
}

function Test-Http([string]$url) {
  try {
    $r = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 5
    return @{ ok = $true; code = [int]$r.StatusCode; err = '' }
  } catch {
    return @{ ok = $false; code = 0; err = $_.Exception.Message }
  }
}
function Test-FileHas([string]$rel, [string]$needle) {
  $p = Join-Path $root $rel
  if (-not (Test-Path $p)) { return $false }
  return ([IO.File]::ReadAllText($p)).Contains($needle)
}
function Skip-Id([string]$id) { return $accepted -contains $id }

$lines = New-Object System.Collections.Generic.List[string]
function Add-Line([string]$s) { $lines.Add($s) | Out-Null }

if ($Slot -eq 'summary') {
  $body = ''
  if (Test-Path $trace) { $body = [IO.File]::ReadAllText($trace) }
  $sum = @()
  $sum += '# 夜间自检结果'
  $sum += ''
  $sum += ('汇总时间：' + $when)
  $sum += '本档只汇总，没有再跑前面的检查。'
  $sum += ''
  if ($body -notlike "*$day*") {
    $sum += '当天痕迹还没有。先等各档跑完，或手动跑 env、menu、save、master、bill、review、complete。'
  } else {
    $sum += '当天各档痕迹见 docs/夜间自检-痕迹.md。下面是痕迹全文。'
    $sum += ''
    $sum += $body
  }
  [IO.File]::WriteAllText($result, ($sum -join "`r`n"), [Text.UTF8Encoding]::new($false))
  Write-Host "summary -> $result"
  exit 0
}

Add-Line ('## ' + $when + '  ' + $title + '（' + $Slot + '）')
Add-Line ''

if ($Slot -eq 'env' -or $Slot -eq 'review') {
  if ($Slot -eq 'env') {
    $b = Test-Http 'http://127.0.0.1:9999/jshERP-boot/platformConfig/getPlatform/name'
    $w = Test-Http 'http://127.0.0.1:3000/'
    Add-Line ('- 后端 9999：' + $(if ($b.ok) { '可打开，HTTP ' + $b.code } else { '打不开。' + $b.err }))
    Add-Line ('- 网页 3000：' + $(if ($w.ok) { '可打开，HTTP ' + $w.code } else { '打不开。早上请先开网页。' }))
    $logHit = '日志里没有新的「写入异常」或英文空值'
    $logDir = Join-Path $root 'jshERP-boot\logs'
    if (Test-Path $logDir) {
      foreach ($f in (Get-ChildItem $logDir -File -EA SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 3)) {
        $blob = (Get-Content $f.FullName -Tail 200 -EA SilentlyContinue) -join "`n"
        if ($blob -match '数据写入异常|cannot be null|TooManyResults') {
          $logHit = '最近日志里还有保存失败字样，见 ' + $f.Name
          break
        }
      }
    }
    Add-Line ('- 最近日志：' + $logHit)
    $listen = [bool](Get-NetTCPConnection -LocalPort 7890 -State Listen -EA SilentlyContinue)
    Add-Line ('- 本机 7890：' + $(if ($listen) { '有程序在听。本次未改代理。' } else { '没有程序在听。本次未改代理。' }))
    Add-Line '- 未改：系统代理（条目 4）。不改 Windows 代理。'
  }
}

if ($Slot -eq 'menu' -or $Slot -eq 'review') {
  if (Skip-Id '1') { Add-Line '- 条目 1 供应商菜单：已验收，本档跳过' }
  else {
    $menuHead = '未查到库'
    $menuHas = '未查到库'
    $fn = '未查到库'
    $my = $schedule.mysql
    if ($my -and (Test-Path $my.exe)) {
      $sql = "SELECT CONCAT(CASE WHEN LEFT(value,1)='[' THEN 'HEAD_OK' ELSE 'HEAD_BAD' END, '|', CASE WHEN value LIKE '%[25]%' THEN 'HAS25' ELSE 'NO25' END) FROM jsh_user_business WHERE id=32; SELECT CONCAT('FN25=', IFNULL(enabled+0,-1)) FROM jsh_function WHERE id=25;"
      $raw = & $my.exe "-u$($my.user)" "-p$($my.password)" --default-character-set=utf8mb4 $my.database -N -e $sql 2>$null
      foreach ($line in $raw) {
        if ($line -like 'HEAD_*') {
          $menuHead = $(if ($line -like 'HEAD_OK*') { '开头是 [' } else { '开头仍缺 [' })
          $menuHas = $(if ($line -like '*HAS25') { '含 [25]' } else { '没有 [25]' })
        } elseif ($line -like 'FN25=*') {
          $fn = $(if ($line -eq 'FN25=1') { '供应商功能已启用' } else { '供应商功能未启用' })
        }
      }
    }
    $src = Test-FileHas 'jshERP-boot\src\main\java\com\jsh\erp\controller\FunctionController.java' 'supplierMenu'
    Add-Line ('- 条目 1 供应商菜单：' + $menuHead + '，' + $menuHas + '，' + $fn + '。源码 supplierMenu ' + $(if ($src) { '在' } else { '不在 FunctionController.java' }))
    Add-Line '- 页面是否真的出现菜单：未代点。要退出再登录才算数。'
  }
}

if ($Slot -eq 'save' -or $Slot -eq 'review') {
  if (Skip-Id '2') { Add-Line '- 条目 2 写入异常：已验收，本档跳过' }
  else {
    $a = Test-FileHas 'jshERP-boot\src\main\resources\mapper_xml\SupplierMapperEx.xml' 'limit 1'
    $c2 = Test-FileHas 'jshERP-boot\src\main\java\com\jsh\erp\exception\GlobalExceptionHandler.java' '同名档案有多条'
    Add-Line ('- 条目 2 写入异常：limit 1 ' + $(if ($a) { '在 SupplierMapperEx.xml' } else { '不在' }) + '；中文说明 ' + $(if ($c2) { '在 GlobalExceptionHandler.java' } else { '不在' }))
  }
  if (Skip-Id '7') { Add-Line '- 条目 7 空登录名：已验收，本档跳过' }
  else {
    $c = Test-FileHas 'jshERP-web\src\views\system\modules\TenantModal.vue' 'const name = value == null'
    Add-Line ('- 条目 7 空登录名：空值提前返回 ' + $(if ($c) { '在 TenantModal.vue' } else { '不在 TenantModal.vue' }) + '。红字是否只有中文：未代点。')
  }
}

if ($Slot -eq 'master' -or $Slot -eq 'review') {
  if (Skip-Id '8') { Add-Line '- 条目 8 期末应付：已验收，本档跳过' }
  else {
    $v = Test-FileHas 'jshERP-web\src\views\system\modules\VendorModal.vue' 'allNeedPay'
    $g = Test-FileHas 'jshERP-web\src\views\system\modules\CustomerModal.vue' 'allNeedGet'
    $vd = Test-FileHas 'jshERP-web\src\views\system\modules\VendorModal.vue' 'readOnly disabled'
    $cd = Test-FileHas 'jshERP-web\src\views\system\modules\CustomerModal.vue' 'readOnly disabled'
    Add-Line ('- 条目 8 期末应付/应收：供应商栏 ' + $(if ($v -and $vd) { '只读在 VendorModal.vue' } else { '不齐，看 VendorModal.vue' }) + '；客户栏 ' + $(if ($g -and $cd) { '只读在 CustomerModal.vue' } else { '不齐，看 CustomerModal.vue' }) + '。方向键：未代点。')
  }
  if (Skip-Id '5') { Add-Line '- 条目 5 租户搜索：已验收，本档跳过' }
  else {
    $s = Test-FileHas 'jshERP-web\src\views\system\TenantList.vue' '@change="searchQuery"'
    Add-Line ('- 条目 5 租户搜索：下拉即搜 ' + $(if ($s) { '在 TenantList.vue' } else { '不在 TenantList.vue' }) + '。查询按钮是否还在：未代点。')
  }
  if (Skip-Id '6') { Add-Line '- 条目 6 改密码问号：已验收，本档跳过' }
  else {
    $p = Test-FileHas 'jshERP-web\src\views\system\modules\TenantModal.vue' '密码修改'
    Add-Line ('- 条目 6 改密码问号：' + $(if ($p) { '句子在 TenantModal.vue' } else { '不在 TenantModal.vue' }) + '。圆圈是否可见：未代点。')
  }
  if (Skip-Id '3') { Add-Line '- 条目 3 下班提示：已验收，本档跳过' }
  else {
    $o = Test-FileHas 'jshERP-web\src\components\tools\UserMenu.vue' '下班后请及时退出账户'
    Add-Line ('- 条目 3 下班提示：文案 ' + $(if ($o) { '在 UserMenu.vue' } else { '不在 UserMenu.vue' }) + '。到点那一句：未代等。')
  }
}

if ($Slot -eq 'bill' -or $Slot -eq 'review') {
  if (Skip-Id '12') { Add-Line '- 条目 12 单据缩放：已验收，本档跳过' }
  else {
    $f = Test-FileHas 'jshERP-web\src\components\jeecg\JModal\index.vue' 'j-modal-box.fullscreen'
    Add-Line ('- 条目 12 单据缩放：全屏样式 ' + $(if ($f) { '在 JModal/index.vue' } else { '不在 JModal/index.vue' }) + '。缩小后底栏：未代点。')
  }
  if (Skip-Id '11') { Add-Line '- 条目 11 分步引导：已验收，本档跳过' }
  else {
    $g1 = Test-FileHas 'jshERP-web\src\views\bill\mixins\BillListMixin.js' 'openNewbieGuide'
    $g2 = Test-FileHas 'jshERP-web\src\views\financial\mixins\FinancialListMixin.js' 'openNewbieGuide'
    Add-Line ('- 条目 11 分步引导：采购类 ' + $(if ($g1) { '在 BillListMixin.js' } else { '不在 BillListMixin.js' }) + '；收支类 ' + $(if ($g2) { '在 FinancialListMixin.js' } else { '不在 FinancialListMixin.js' }) + '。点问号是否逐步走：未代点。')
  }
}

if ($Slot -eq 'complete') {
  $catalog = @(
    @{ id = '1'; name = '供应商菜单'; changed = $true },
    @{ id = '2'; name = '写入异常'; changed = $true },
    @{ id = '3'; name = '下班提示'; changed = $true },
    @{ id = '4'; name = '系统代理'; changed = $false; why = '未改。不改 Windows 代理。痕迹：本档与 env 档都只记录 7890，没有写系统设置。' },
    @{ id = '5'; name = '租户搜索'; changed = $true },
    @{ id = '6'; name = '改密码问号'; changed = $true },
    @{ id = '7'; name = '空登录名'; changed = $true },
    @{ id = '8'; name = '期末应付'; changed = $true },
    @{ id = '9'; name = '服务器'; changed = $false; why = '未改。只写了方案，没有采购、没有安装。痕迹：docs/2.0-进度与待做项-12.md 文末清单。' },
    @{ id = '10'; name = '定时自检'; changed = $true },
    @{ id = '11'; name = '分步引导'; changed = $true },
    @{ id = '12'; name = '单据缩放'; changed = $true }
  )
  $missing = @()
  foreach ($item in $catalog) {
    if (Skip-Id $item.id) {
      Add-Line ('- 条目 ' + $item.id + ' ' + $item.name + '：已验收')
      continue
    }
    if (-not $item.changed) {
      Add-Line ('- 条目 ' + $item.id + ' ' + $item.name + '：' + $item.why)
      continue
    }
    $ok = $true
    $where = ''
    switch ($item.id) {
      '1' { $ok = Test-FileHas 'jshERP-boot\src\main\java\com\jsh\erp\controller\FunctionController.java' 'supplierMenu'; $where = 'FunctionController.java' }
      '2' { $ok = (Test-FileHas 'jshERP-boot\src\main\resources\mapper_xml\SupplierMapperEx.xml' 'limit 1') -and (Test-FileHas 'jshERP-boot\src\main\java\com\jsh\erp\exception\GlobalExceptionHandler.java' '同名档案有多条'); $where = 'SupplierMapperEx.xml / GlobalExceptionHandler.java' }
      '3' { $ok = Test-FileHas 'jshERP-web\src\components\tools\UserMenu.vue' '下班后请及时退出账户'; $where = 'UserMenu.vue' }
      '5' { $ok = Test-FileHas 'jshERP-web\src\views\system\TenantList.vue' '@change="searchQuery"'; $where = 'TenantList.vue' }
      '6' { $ok = Test-FileHas 'jshERP-web\src\views\system\modules\TenantModal.vue' '密码修改'; $where = 'TenantModal.vue' }
      '7' { $ok = Test-FileHas 'jshERP-web\src\views\system\modules\TenantModal.vue' 'const name = value == null'; $where = 'TenantModal.vue' }
      '8' { $ok = (Test-FileHas 'jshERP-web\src\views\system\modules\VendorModal.vue' 'readOnly disabled') -and (Test-FileHas 'jshERP-web\src\views\system\modules\CustomerModal.vue' 'readOnly disabled'); $where = 'VendorModal.vue / CustomerModal.vue' }
      '10' { $ok = (Test-Path (Join-Path $here 'SKILL.md')) -and ([IO.File]::ReadAllText((Join-Path $here 'SKILL.md'))).Contains('night-self-check'); $where = '本技能 SKILL.md' }
      '11' { $ok = (Test-FileHas 'jshERP-web\src\views\bill\mixins\BillListMixin.js' 'openNewbieGuide') -and (Test-FileHas 'jshERP-web\src\views\financial\mixins\FinancialListMixin.js' 'openNewbieGuide'); $where = 'BillListMixin.js / FinancialListMixin.js' }
      '12' { $ok = Test-FileHas 'jshERP-web\src\components\jeecg\JModal\index.vue' 'j-modal-box.fullscreen'; $where = 'JModal/index.vue' }
    }
    if ($ok) { Add-Line ('- 条目 ' + $item.id + ' ' + $item.name + '：已改，痕迹在 ' + $where) }
    else { Add-Line ('- 条目 ' + $item.id + ' ' + $item.name + '：收录不齐，期望痕迹在 ' + $where); $missing += $item.id }
  }
  if ($missing.Count -eq 0) { Add-Line '- 齐全。十二条都有着落（已改、未改或已验收）。' }
  else { Add-Line ('- 不齐全。缺痕迹的条目：' + ($missing -join '、')) }
}

Add-Line ''
$block = $lines -join "`r`n"
$prev = ''
if (Test-Path $trace) { $prev = [IO.File]::ReadAllText($trace) }
if ($prev -notlike "*$day*") { $prev = "# 夜间自检痕迹 $day`r`n`r`n" }
[IO.File]::WriteAllText($trace, ($prev + $block), [Text.UTF8Encoding]::new($false))

$sheet = @()
$sheet += '# 夜间自检结果'
$sheet += ''
$sheet += ('最近一档：' + $when + '  ' + $title)
$sheet += '这是夜班中途结果。07:40 的汇总档会把当天痕迹收成一份。进度清单没有改。'
$sheet += ''
$sheet += $block
[IO.File]::WriteAllText($result, ($sheet -join "`r`n"), [Text.UTF8Encoding]::new($false))
Write-Host "slot $Slot -> $result"
