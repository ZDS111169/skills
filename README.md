# skills
# 更新日志
1. 第一次更新日期 11.22

[README.md](https://github.com/user-attachments/files/35229277/README.md)
# skills

专放各类 **Cursor Agent Skill**（`SKILL.md`）适配包。  
下载后把对应技能**整个文件夹**拷到本机：

`C:\Users\<你的用户名>\.cursor\skills\`

或项目内：`.cursor\skills\`

新开 Agent 对话，用 `/技能名` 或下方口令触发。

---

## 目录结构约定

```text
skills/                          # 本仓库（或本目录）
├── README.md                    # 本说明
├── stormx/                      # 一个 skill = 一个文件夹
│   ├── SKILL.md                 # 必填：主说明书
│   └── references/              # 可选：细则、对照说明（Agent 按需再读）
│       └── origin-notes.md
├── 5w2h/
│   └── SKILL.md
└── （后续新 skill 继续平铺文件夹）
```

规则：

1. **文件夹名** = `SKILL.md` 里 `name:` 字段（小写+连字符）
2. 上传 / 下载都是**整夹**，不要只丢一个孤立的 `SKILL.md` 在仓库根且改名混乱
3. `references/`、`scripts/`、`assets/` 都是**可选**；手搓时只有主文件也完全够用

---

## 已收录 Skill

| 文件夹 | 调用 | 一句话 | 推荐口令 |
|--------|------|--------|----------|
| `stormx` | `/stormx` | 改造版 STORM 深调研 + 学习 10 步（非斯坦福原版） | `用STORMX方式研究【主题】` |
| `5w2h` | `/5w2h` | 5W2H 把问题/立项说清楚 | `用5W2H分析【主题】` |

> 若仓库里暂时只有 `stormx`，表格里保留 `5w2h` 一行也无妨：本地有了再上传同一文件夹即可。

---

## 安装（第一次）

1. 克隆或 Download ZIP 本仓库  
2. 复制需要的文件夹，例如 `stormx`，到 `~\.cursor\skills\`  
3. 新开 Cursor Agent 聊天  
4. 输入 `/stormx` 或口令试跑  

可选：GitHub CLI（若本机支持）

```bash
gh skill install <你的用户名>/<仓库名> stormx --agent cursor --scope user
```

---

## 新增一个 Skill（以后持续补充时照做）

1. 本地建文件夹：`~\.cursor\skills\新名字\SKILL.md`  
2. 顶部写好：

```yaml
---
name: 新名字
description: 做什么。在用户说哪些词时使用。
disable-model-invocation: true
---
```

3. 正文写清：何时触发、步骤、输出模板、禁止事项  
4. 把该文件夹拷进本仓库根目录（与 `stormx` 同级）  
5. 更新本 README 的「已收录」表格 + 更新日志  
6. 你自己 commit / push  

`references/`：**不必每次都建**。只有「主文件太长、想拆对照说明/长清单」时再加。

---

## 更新日志

### 2025-11-22

- 初始化仓库说明  
- 收录 `stormx`（改造版 STORMX 全流程）  
- 规划收录 `5w2h`  

<!-- 以后每加一个 skill，在上面追加一节，例如：
### 2025-12-01
- 新增 `xxx`：一句话说明
-->
