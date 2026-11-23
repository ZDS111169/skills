---
name: night-self-check
description: >-
  按演示时段跑通序 ERP 的夜间分档检查：本机 Windows 计划任务，不每档叫醒对话。
  仅当用户说夜间自检、晚上自检、下班自检、改夜间自检时间、/night-self-check 时使用。
  用户只说自检、本轮自检、验收、核对进度时不要用本技能。
---

# 夜间自检

只认这些口令：夜间自检、晚上自检、下班自检、改夜间自检时间、`/night-self-check`。用户只说「自检」时，那是当前这一轮的核对，不要跑本技能。

本机脚本分档检查。不改页面、不改 Java、不改数据库、不改系统代理、不打包。不启动 `/loop`。

这是为本仓库写的技能，不是从 GitHub 复制的测试技能。浏览器点页面用别的技能，不要和本技能混在一夜里反复跑。

## 关联文件

没有单独的 `references/`。没有技能内 README。钟点和脚本都在本夹，下载整夹即可。

| 文件 | 步骤里何时用 |
| --- | --- |
| `schedule.json` | 各档钟点。默认就是演示时间。`repoRoot` 指向通序仓库 |
| `accepted.txt` | 已验收条目号，一行一个数字。夜班跳过，07:10 仍点名 |
| `scripts/install-tasks.ps1` | 按 `schedule.json` 注册或更新八个 Windows 任务 |
| `scripts/run-slot.ps1` | 跑其中一档。计划任务调用的就是它 |

结果写到 `repoRoot` 下的 `docs/夜间自检-结果.md`。痕迹写到 `docs/夜间自检-痕迹.md`。不要改、不要关进度清单。

## 演示时间（默认）

| 档 id | 默认 | 做什么 |
| --- | --- | --- |
| env | 19:10 | 9999、3000、日志、7890 只记录 |
| menu | 20:10 | 供应商菜单串 |
| save | 21:10 | 同名只取一条、失败中文、空登录名 |
| master | 22:10 | 期末只读、租户下拉、改密码问号、下班文案 |
| bill | 23:10 | 全屏样式、分步引导函数 |
| review | 06:10 | 复核已改项还在不在。已验收的跳过 |
| complete | 07:10 | 十二条是否收齐。齐了写「齐全」 |
| summary | 07:40 | 只汇总 |

00:00–05:30 没有任务。08:00 前结束。

## 步骤

1. 改钟点只改本夹 `schedule.json` 的 `at`（`HH:mm`）。换了一台电脑或仓库不在原处，同时改 `repoRoot`。然后执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor\skills\night-self-check\scripts\install-tasks.ps1"
```

2. 立刻试一档，不等到点：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor\skills\night-self-check\scripts\run-slot.ps1" -Slot env
```

`Slot` 只能是上表的 id。

3. 用户说某条已经点头：把编号写入 `accepted.txt`。不要从进度清单删行。

4. 安装脚本会停用旧的单次任务 `TongxuNightCheck`，避免和分档结果互相覆盖。
