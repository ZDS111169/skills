---
name: author-skill
description: >-
  按 Agent Skills 规范新建或修改一个技能夹：SKILL.md、触发词、边界，以及必要时的
  references、scripts、assets。仅当用户说按规范做技能、写一个 skill、规范一个技能、
  /author-skill 时使用。用户只说自检、改需求、或没有点名要做技能时不要用。
---

# 做技能

把技能放进 `C:\Users\AI_AGENT\.cursor\skills\<name>\`。文件夹名等于 frontmatter 的 `name`。不要放进 `skills-cursor`。不要在技能夹里再写 README。不要代用户 git commit。

每完成一个技能，更新外围 `C:\Users\AI_AGENT\.cursor\skills\README.md` 的「已收录」、目录树和更新日志。

## 边界

- 一件技能只做一件事。触发词要窄，写明「不要在什么情况下用」。
- 单独一个宽词（例如只写「自检」）不算口令。
- 已启用技能宜在 20 个左右，不要堆过 50。规范本身没有硬上限，超了描述会撞车。
- `references/`、`scripts/`、`assets/` 没有内容就不要建空目录。
- 建了这三个目录中的任何一个，必须在下面的步骤里写明何时读、何时执行。

## 步骤

1. 定 `name`（小写、数字、连字符，最长 64，不能以连字符开头或结尾）。
2. 写 `SKILL.md`。`description` 用第三人称，写清做什么、什么口令才用、什么口令不用。正文不超过 500 行。
3. 需要长说明时才建 `references/`，并在步骤里写：读 `references/<文件>`。只链一层，不要 references 里再链 references。
4. 需要反复执行的命令才建 `scripts/`。步骤里写明是**执行**哪一个脚本，不要把脚本贴进正文。脚本放进夹内 `scripts/`，不要散落到别的仓库，除非用户明确要求。
5. 需要模板、图片、样例文件才建 `assets/`。步骤里写明何时复制哪一个文件。`assets/` 不自动读进对话。
6. 在正文写边界：不改什么、不代替用户做什么。
7. 用一张表写关联：每个附加文件在哪一步用。没有附加文件就写「无 references、无 scripts、无 assets」。
8. 更新外围 README 的已收录表。口令与 `description` 一致。
9. 技能若带脚本，执行一次最小路径，确认能跑完。失败就改脚本，不要把未跑通的任务说成已挂上。

细则见 [references/layout.md](references/layout.md)。只在要决定目录或 frontmatter 字段时读它。
