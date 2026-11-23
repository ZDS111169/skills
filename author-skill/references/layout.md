# 技能夹布局

依据 [Agent Skills 规范](https://agentskills.io/specification) 和 [Cursor Skills](https://cursor.com/docs/skills)。

## 加载方式

1. 每轮只看到各技能的 `name` 和 `description`。
2. 口令命中后才读整个 `SKILL.md`。
3. `references/`、`scripts/`、`assets/` 里的文件，只有步骤点名时才读或执行。

所以 description 要短，并带上真实口令。不要把长教程写进 description。

## Frontmatter

| 字段 | 要求 |
| --- | --- |
| `name` | 必填。与文件夹名相同。小写、数字、连字符。最长 64。不能以连字符开头或结尾 |
| `description` | 必填。1–1024 字。做什么 + 何时用 + 何时不用 |
| `license` | 可选 |
| `compatibility` | 可选。最长 500。写运行环境，例如需要 Windows 计划任务 |
| `disable-model-invocation` | 可选。设为 `true` 时，只有用户输入 `/name` 才挂上，口令不会自动命中。需要口令触发时不要设 |

Cursor 另有可选 `paths`（只在打开匹配文件时出现）和 `metadata`。

## 三个可选目录

| 目录 | 放什么 | 不放什么 |
| --- | --- | --- |
| `references/` | 长表、字段说明、边界细则 | 可执行脚本、第二份 README |
| `scripts/` | 要执行的脚本 | 只给人看的说明 |
| `assets/` | 模板、图片、要复制的样例 | 希望模型每次都读的步骤 |

`SKILL.md` 里用正斜杠写路径，例如 `scripts/install-tasks.ps1`。

## 数量

规范没有「最多 N 个」的硬条款。名字和 description 每轮都会占上下文。本库按大约 20 个来收，不要超过 50。再多就合并职责相近的，或把不常用的标成只许 `/name` 调用。
