# Skills

<p align="center">
  <strong>可移植的 Agent Skill 合集</strong><br/>
  一份 <code>SKILL.md</code>，多端可用：Cursor · Claude Code · Codex · Copilot · Gemini …
</p>

<p align="center">
  <a href="#-已收录">已收录</a> ·
  <a href="#-安装">安装</a> ·
  <a href="#-多-agent-适配">多 Agent</a> ·
  <a href="#-怎么用">怎么用</a> ·
  <a href="#-自己加一个">贡献</a>
</p>

---

## 这是什么

[Agent Skills](https://agentskills.io/home) 的定义是：一种轻量、开放的格式，用来给 AI 代理扩展专门知识和工作流程。

原文：Agent Skills are a lightweight, open format for extending AI agent capabilities with specialized knowledge and workflows.

官方对它怎么起作用的说明是：把流程性知识，以及公司、团队、个人的上下文，打包成可移植、可版本管理的文件夹，代理按需加载。一个技能就是这样一个文件夹。其中必须有 `SKILL.md`（名称、何时使用、具体步骤），需要时再带上 `scripts/`（可执行脚本）、`references/`（说明）和 `assets/`（模板或图片）。Cursor 的挂载方式见 [Cursor Skills](https://cursor.com/docs/skills)。

挂上之后：

| 好处  | 说明  |
| --- | --- |
| 专门知识可复用 | 多步流程写成固定步骤，换一次对话仍然一样 |
| 按需加载 | 平时只看到技能的名字和一句话；对上任务才读正文 |
| 整夹可带走 | 脚本和说明在同一个文件夹里，复制或安装后就能用 |
| 跨产品 | 同一份技能可用于 Cursor、Claude Code、Codex、Copilot、Gemini 等支持该格式的代理 |

规范没有写死个数。每个技能的名字和 description 每轮都会被看到，所以宜少而准。建议大约 20 个，不要超过 50。再多就合并，或把不常用的改成只能用 `/名字` 调用。

仓库：`ZDS111169/skills`

---

## 已收录

| Skill | 一句话 | 推荐口令 | 斜杠  |
| --- | --- | --- | --- |
| **stormx** | 改造版 STORM：五视角调研 → 矛盾图谱 → 简报 → 评审 → 学习链（非斯坦福原版） | `用STORMX方式研究【主题】` | `/stormx` |
| **5w2h** | 5W2H 把问题 / 立项说清楚，输出可执行陈述 | `用5W2H分析【主题】` | `/5w2h` |
| **night-self-check** | 下班后的分档检查。脚本在该夹的 `scripts/`。默认 19:10 至次日 07:40 | `夜间自检`、`晚上自检`、`下班自检` | `/night-self-check` |
| **author-skill** | 按规范新做一个技能夹，并更新本 README | `按规范做技能` / `写一个 skill` | `/author-skill` |

```text
.
├── README.md                 # 仓库只有这一份总说明
├── stormx/
│   ├── SKILL.md
│   └── references/
├── 5w2h/
│   └── SKILL.md
├── night-self-check/
    ├── SKILL.md
    ├── schedule.json
    ├── accepted.txt
    └── scripts/              # 计划任务执行的就是这里的 ps1
        ├── install-tasks.ps1
        └── run-slot.ps1
└── author-skill/
    ├── SKILL.md
    └── references/
        └── layout.md         # 只在决定目录和字段时读
```

每增加一个技能，都要改本文件的「已收录」、上面的目录树和文末更新日志。技能夹内不另放 README。

---

## 安装

### 方式 A · 一键（GitHub CLI）

需 [GitHub CLI](https://cli.github.com/) ≥ 支持 `gh skill` 的版本，并已 `gh auth login`。

```bash
# Cursor（装到用户目录，全局可用）
gh skill install ZDS111169/skills stormx --agent cursor --scope user
gh skill install ZDS111169/skills 5w2h  --agent cursor --scope user

# Claude Code
gh skill install ZDS111169/skills stormx --agent claude-code --scope user

# OpenAI Codex
gh skill install ZDS111169/skills stormx --agent codex --scope user

# GitHub Copilot
gh skill install ZDS111169/skills stormx --agent github-copilot --scope user

# Gemini CLI
gh skill install ZDS111169/skills stormx --agent gemini-cli --scope user
```

一次装仓内全部 skill：

```bash
gh skill install ZDS111169/skills --all --agent cursor --scope user
```

> 不要写成 `<ZDS111169>/<skills>`——尖括号只是文档占位符，命令里要写成 `ZDS111169/skills`。

### 方式 B · 手动复制（任何环境）

1. Download ZIP 或 `git clone https://github.com/ZDS111169/skills.git`
2. 把 `stormx`、`5w2h` 等文件夹拷到下表对应目录
3. **新开** Agent 对话（必要时重启客户端）再调用

---

## 多 Agent 适配

同一套 `SKILL.md`；差别只在**落盘目录**。

### 用户级（全局，推荐）

| Agent | `--agent` | 用户目录 |
| --- | --- | --- |
| Cursor | `cursor` | `~/.cursor/skills/` |
| Claude Code | `claude-code` | `~/.claude/skills/` |
| Codex | `codex` | `~/.codex/skills/` |
| GitHub Copilot | `github-copilot` | `~/.copilot/skills/` |
| Gemini CLI | `gemini-cli` | `~/.gemini/skills/` |

Windows 示例（Cursor）：

`C:\Users\<你的用户名>\.cursor\skills\stormx\SKILL.md`

### 项目级（跟仓库走、团队共享）

多数主机（Cursor / Codex / Copilot / Gemini 等）共用：

```text
你的项目/
└── .agents/skills/
    ├── stormx/
    └── 5w2h/
```

Claude Code 项目级常用：`.claude/skills/`  
Cursor 也认：`.cursor/skills/`

```bash
# 在项目仓库根目录执行 → 写入当前项目
gh skill install ZDS111169/skills stormx --agent cursor --scope project
```

### 国内 / 其它常见主机

凡声明兼容 **Agent Skills**（`SKILL.md` + 文件夹规范）的客户端，一般可：

1. 用 `gh skill install ... --agent <主机名>`（若在 [支持列表](https://cli.github.com/manual/gh_skill_install) 中），或
2. 手动拷到该产品文档写明的 skills 目录（不少也读 `.agents/skills/`）

本仓库不绑定单一厂商；内容以流程方法论为主，与具体模型无关。

---

## 怎么用

| 场景  | 做法  |
| --- | --- |
| 手动挂上 | 聊天里输入 `/stormx`、`/5w2h`、`/night-self-check`、`/author-skill` |
| 口令  | 用上表里的整句。夜间检查请说「夜间自检」「晚上自检」或「下班自检」 |
| 改完 skill | 新开对话；仍不生效再重启客户端 |

`stormx`、`5w2h` 设了 `disable-model-invocation: true`，闲聊不会自动挂上，用斜杠或口令。`night-self-check` 和 `author-skill` 靠上面的窄口令命中。

---

## 自己加一个

按 `/author-skill` 做。要点：

1. 在本目录新建 `新名字/SKILL.md`，`name` 与文件夹一致
2. 口令写窄，并写明什么情况下不要用
3. 有 `references/`、`scripts/`、`assets/` 时，在 `SKILL.md` 步骤里点名
4. 更新本 README 的「已收录」、目录树、更新日志
5. 带脚本的先跑通，再挂定时任务
6. 自行 commit / push

---

## 更新日志

### 2026-11-23

- 收录 `night-self-check`、`author-skill`
- 按 Agent Skills 的定义补充「这是什么」
- 夜间检查的口令为「夜间自检」「晚上自检」「下班自检」

### 2025-11-23

- README 多 Agent 适配（Cursor / Claude Code / Codex / Copilot / Gemini …）
- 安装说明与目录对照表美化
- STORMX 关联 references子目录，确保挂载上

### 2025-11-22

- 初始化说明
- 收录 `stormx`、`5w2h`

---

<p align="center">
  <sub>MIT-friendly 流程说明书 · 欢迎 Star / Issue / PR</sub>
</p>
