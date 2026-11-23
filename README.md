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

基于开放标准 [Agent Skills](https://agentskills.io/specification)：每个技能是一个文件夹 + `SKILL.md`，教 Agent **按固定流程做事**（调研、澄清问题、方法论……），而不是一次性口头提示。

| 你得到 | 说明  |
| --- | --- |
| 流程可复用 | 口令 / `/技能名` 即可跑完整步骤 |
| 多端一份货 | 同一文件夹拷到对应目录，或用 `gh skill install` |
| 可版本管理 | Git 备份、分享、按需更新 |

仓库：`ZDS111169/skills`

---

## 已收录

| Skill | 一句话 | 推荐口令 | 斜杠  |
| --- | --- | --- | --- |
| **stormx** | 改造版 STORM：五视角调研 → 矛盾图谱 → 简报 → 评审 → 学习链（非斯坦福原版） | `用STORMX方式研究【主题】` | `/stormx` |
| **5w2h** | 5W2H 把问题 / 立项说清楚，输出可执行陈述 | `用5W2H分析【主题】` | `/5w2h` |

```text
.
├── README.md
├── stormx/
│   ├── SKILL.md
│   └── references/          # 可选附录
└── 5w2h/
    └── SKILL.md
```

约定：文件夹名 = `SKILL.md` 里的 `name:`；上传 / 下载都是**整夹**。

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
| 手动挂上 | 聊天里输入 `/stormx` 或 `/5w2h` |
| 口令触发 | 见上表「推荐口令」 |
| 改完 skill | **新开对话**；仍不生效再重启客户端 |

`stormx` / `5w2h` 默认 `disable-model-invocation: true`：避免闲聊误触发，**优先斜杠或明确口令**。

---

## 自己加一个

1. 本地建 `新名字/SKILL.md`（`name` 与文件夹一致）
2. 写清：`description`（做什么 + 何时用）、步骤、输出模板、禁止事项
3. 整夹放进本仓库根目录（与 `stormx` 同级）
4. 更新本 README 的「已收录」表 + 更新日志
5. 自行 commit / push

`references/`、`scripts/` 可选；主文件够短就不必建。

---

## 更新日志

### 2025-11-23

- README 多 Agent 适配（Cursor / Claude Code / Codex / Copilot / Gemini …）
- 安装说明与目录对照表美化

### 2025-11-22

- 初始化说明
- 收录 `stormx`、`5w2h`

---

<p align="center">
  <sub>MIT-friendly 流程说明书 · 欢迎 Star / Issue / PR</sub>
</p>
