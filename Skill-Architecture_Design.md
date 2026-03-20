# Skill 架构设计文档

> 版本：v2.0.0 | 作者：James | 日期：2026-03-20
>
> 参考：[Claude Skills 实战：如何为团队构建专属 AI 能力](https://www.80aj.com/2025/10/20/claude-skills%e5%ae%9e%e6%88%98%ef%bc%9a%e5%a6%82%e4%bd%95%e4%b8%ba%e5%9b%a2%e9%98%9f%e6%9e%84%e5%bb%ba%e4%b8%93%e5%b1%9eai%e8%83%bd%e5%8a%9b/) — Toy's Tech Notes

---

## 1. 设计目标

1. **VS Code 原生兼容** — 所有 Skill 严格遵循 `.github/skills/<name>/SKILL.md` 规范，确保 Copilot Agent 可自动发现、加载和触发。
2. **单一职责** — 每个 Skill 只做一件事，通过组合实现复杂工作流。
3. **渐进加载** — 利用 VS Code 的三级加载机制（Discovery → Instructions → Resources），控制 context 消耗。
4. **公共 + 项目双层架构** — 公共 Skill 提供通用能力，项目专属 Skill 结合项目上下文提供针对性能力。
5. **团队可协作** — 共享资源集中管理，项目团队独立开发各自 Skill，通过同步脚本统一注册。
6. **可迭代** — 语义化版本管理 + CHANGELOG，支持平滑升级。

---

## 2. 目录结构

```
xiefan-ai-skills/                          # 仓库根目录（Linux 工作区）
├── README.md                              # 项目总览与使用指南
├── Skill-Architecture_Design.md           # 本文档：架构设计说明
├── CHANGELOG.md                           # 全局变更日志
│
├── .github/
│   ├── skills/                            # ★ VS Code Skill 发现区（所有可用 Skill）
│   │   ├── xf-review/                    # [公共] 代码审查
│   │   ├── xf-project-ctx/              # [公共] 项目上下文加载器/调度器
│   │   └── demo-review/ → (symlink)      # [项目专属] 由同步脚本链接
│   │
│   ├── instructions/                      # File Instructions（自动注入）
│   │   └── project-context.instructions.md  # 处理 projects/** 文件时自动加载
│   │
│   └── workflows/                         # GitHub Actions CI/CD
│       └── skill-validation.yml
│
├── projects/                              # ★ 子项目区（项目上下文 + 专属 Skill）
│   ├── demo-project/                      # 示例子项目
│   │   ├── context/                       # 项目上下文文档（.md）
│   │   │   ├── project-overview.md        #   项目概述
│   │   │   ├── architecture.md            #   系统架构
│   │   │   ├── tech-stack.md              #   技术栈
│   │   │   └── api-spec.md               #   API 规范
│   │   ├── skills/                        # 项目专属 Skill 源码
│   │   │   └── demo-review/              #   项目专属代码审查
│   │   │       ├── SKILL.md
│   │   │       └── references/
│   │   └── src/                           # 项目源码
│   │
│   └── <other-project>/                   # 其他子项目（同结构）
│
├── scripts/                               # 运维脚本
│   └── sync-project-skills.sh             # 同步项目 Skill → .github/skills/
│
├── shared/                                # 跨 Skill 共享资源
│   ├── standards/                         # 团队规范
│   ├── templates/skill-template/          # 新 Skill 脚手架
│   └── utils/                             # 通用脚本
│
└── docs/                                  # 项目文档
    ├── how-to-create-skill.md
    ├── best-practices.md
    └── troubleshooting.md
```

### 关键约束

| 规则 | 说明 |
|------|------|
| Skill 必须放在 `.github/skills/<name>/` | 这是 VS Code Copilot 唯一扫描的项目级路径 |
| `name` 字段 = 文件夹名 | 小写字母 + 连字符，1-64 字符，如 `xf-review` |
| SKILL.md 必须为 Markdown | YAML frontmatter（`---`）仅包含元数据，正文为 Markdown |
| 资源文件只深入一级 | 从 SKILL.md 引用的文件应在 `./references/`、`./scripts/`、`./templates/` 下 |
| 公共 Skill 前缀 `xf-` | 如 `xf-review`、`xf-project-ctx` |
| 项目 Skill 前缀 `<项目缩写>-` | 如 `demo-review`、`alpha-deploy` |
| 项目上下文在 `projects/<name>/context/` | Agent 通过读取此目录获取项目背景 |
| 项目 Skill 源码在 `projects/<name>/skills/` | 通过 `sync-project-skills.sh` 链接到 `.github/skills/` |

---

## 3. 单个 Skill 的内部结构

```
.github/skills/<skill-name>/
├── SKILL.md              # 必需：入口文件
├── references/            # 可选：参考文档，被 SKILL.md 正文链接引用
│   ├── standards.md
│   └── examples.md
├── scripts/               # 可选：可执行脚本（Python/Shell）
│   ├── checker.py
│   └── formatter.sh
├── templates/             # 可选：输出模板
│   └── report-template.md
└── assets/                # 可选：静态资源（图片等）
```

### SKILL.md 标准格式

```markdown
---
name: skill-name                   # 必需：与文件夹名一致
description: "简短描述。Use when: 关键词1, 关键词2。"  # 必需：≤1024字符，关键词驱动发现
argument-hint: "可选的斜杠命令参数提示"        # 可选
user-invocable: true               # 可选：是否作为 / 斜杠命令（默认 true）
disable-model-invocation: false    # 可选：是否禁止模型自动触发（默认 false）
---

# Skill 标题

简要说明功能。

## When to Use
- 触发场景 1
- 触发场景 2

## Procedure
1. 步骤 1
2. 步骤 2 — 引用 [参考文档](./references/xxx.md)

## Output Format
期望的输出格式说明

## Limitations
- 边界 1
- 边界 2
```

### 三级渐进加载机制

| 阶段 | 加载内容 | Token 消耗 |
|------|---------|-----------|
| **Discovery** | `name` + `description`（约 100 tokens） | 极低 |
| **Instructions** | SKILL.md 正文（建议 < 500 行） | 中等 |
| **Resources** | `references/`、`scripts/` 中的文件（按需） | 按需 |

> **设计原则**：SKILL.md 正文控制在 500 行以内。详细内容拆分到 `references/` 下，通过 Markdown 链接引用，只在 Agent 需要时才加载。

---

## 4. 共享资源策略

### 问题

多个 Skill 可能引用相同的团队规范（如 coding-standards.md）。

### 方案

采用 **"复制到 Skill 内部 + 源头在 shared/ 维护"** 的双层策略：

```
shared/standards/coding-standards.md       ← 源头（团队维护）
    ↓ 复制
.github/skills/xf-review/references/coding-standards.md  ← Skill 内部副本
.github/skills/xf-debug/references/coding-standards.md   ← Skill 内部副本
```

**为什么不直接跨目录引用？**
- VS Code Skill 资源引用限制为 SKILL.md 同级或一级子目录
- Skill 必须自包含，才能独立加载和分享

**同步方式**：
- 手动复制（当前阶段，Skill 数量少）
- 后续可通过 CI 脚本自动同步 `shared/` → 各 Skill 的 `references/`

---

## 5. 命名规范

### Skill 命名

| 类型 | 前缀模式 | 示例 | 说明 |
|------|---------|------|------|
| 公共 Skill | `xf-<功能>` | `xf-review`, `xf-project-ctx` | 通用能力，所有项目可用 |
| 项目专属 Skill | `<项目缩写>-<功能>` | `demo-review`, `alpha-deploy` | 结合项目上下文的专属能力 |

**规则**：
- 仅使用小写字母、数字和连字符
- 长度 1-64 字符
- 必须与文件夹名完全一致
- **公共 Skill** 以 `xf-` 前缀标识
- **项目 Skill** 以项目缩写为前缀

### Description 关键词设计

`description` 是 Copilot Agent 发现 Skill 的**唯一线索**。用 "Use when:" 模式列出触发词：

```yaml
description: "功能说明。Use when: keyword1, keyword2, keyword3。补充说明。"
```

**反例**：
```yaml
# ❌ 模糊描述，Agent 无法匹配
description: "一个有用的工具"

# ✅ 关键词丰富，Agent 容易发现
description: "代码审查助手。Use when: code review, lint, security check, /xf-review。检查安全、性能和最佳实践。"
```

---

## 6. 子项目架构（核心机制）

### 6.1 部署模型

```
团队成员 (PC)                         Linux 服务器 (工作区)
┌──────────────┐                     ┌─────────────────────────────────┐
│  本地开发      │    git push        │  xiefan-ai-skills/              │
│  Skill 源码    │ ───────────────→   │  ├── .github/skills/ (所有Skill) │
│  项目上下文    │                     │  ├── projects/  (子项目区)      │
└──────┬───────┘                     │  └── ...                        │
       │                              └──────────────┬──────────────────┘
       │                                             │
       │ VS Code Remote SSH                          │ Copilot Agent
       └─────────────────────────────→ 使用 Skill 完成工作
```

- 团队成员在本地开发公共 Skill 和项目专属 Skill，推送到远端分支
- 在 Linux 服务器上 `git pull` 拉取最新代码
- 运行 `bash scripts/sync-project-skills.sh` 同步项目 Skill 到 `.github/skills/`
- 通过 PC 上的 VS Code Remote SSH 连接 Linux，使用 Copilot 调用 Skill

### 6.2 两层 Skill 架构

```
                    ┌───────────────────────────┐
                    │     公共 Skill 层         │
                    │  xf-review (通用审查)     │
                    │  xf-project-ctx (调度器)  │
                    └─────────┬─────────────────┘
                              │ 加载项目上下文 + 发现项目 Skill
                              ▼
          ┌───────────────────┴───────────────────┐
          │           项目专属 Skill 层           │
          │                                       │
  ┌───────┴───────┐                      ┌───────┴───────┐
  │ demo-project  │                      │ alpha-project │
  │               │                      │               │
  │ context/      │ ← Agent 读取上下文    │ context/      │
  │ demo-review   │ ← 结合上下文审查      │ alpha-deploy  │
  └───────────────┘                      └───────────────┘
```

**调用链路**：

1. 用户在 Copilot Chat 中提到项目关键词
2. 公共 `xf-project-ctx` 被触发，读取 `projects/<name>/context/*.md`
3. Agent 获得项目上下文后，自动匹配项目专属 Skill
4. 项目专属 Skill 在项目上下文基础上执行专项任务

### 6.3 子项目目录规范

每个子项目必须遵循以下结构：

```
projects/<项目名>/
├── context/                    # 必需：项目上下文文档
│   ├── project-overview.md    # 推荐：项目概述（最先被读取）
│   ├── architecture.md        # 推荐：系统架构
│   ├── tech-stack.md          # 推荐：技术栈
│   ├── api-spec.md            # 推荐：API 规范
│   └── *.md                   # 其他项目特定文档
├── skills/                    # 可选：项目专属 Skill 源码
│   └── <项目缩写>-<功能>/
│       ├── SKILL.md
│       └── references/
└── src/                       # 可选：项目源码或链接
```

**上下文文档编写要点**：

| 要求 | 说明 |
|------|------|
| 文件格式 | 纯 Markdown (.md) |
| 单文件行数 | 建议 ≤ 200 行 |
| 总文件数 | 建议 ≤ 10 个（控制 context 开销） |
| 内容要求 | 包含具体技术细节（端口、版本、地址），而非泛泛描述 |
| 更新频率 | 架构变更时同步更新 |

### 6.4 项目 Skill 如何读取上下文

项目专属 Skill 通过 SKILL.md 正文指令告诉 Agent 读取项目上下文：

```markdown
## Before You Start — 加载项目上下文

**必须**先读取项目上下文文档：

1. 读取 `projects/demo-project/context/project-overview.md`
2. 读取 `projects/demo-project/context/architecture.md`
3. 读取 `projects/demo-project/context/tech-stack.md`
4. 读取 `projects/demo-project/context/api-spec.md`
```

Agent 会使用其内置的文件读取能力，访问工作区内的任意文件。这不受 Skill `references/` 的一级引用限制 —— 那是 VS Code 自动加载机制的限制，而 Agent 的工具调用可以读取工作区内任何路径。

### 6.5 同步机制

项目团队在 `projects/<name>/skills/` 下开发 Skill，通过同步脚本注册到 `.github/skills/`：

```bash
# 在 Linux 服务器上，每次 git pull 后执行
bash scripts/sync-project-skills.sh
```

脚本行为：
1. 遍历 `projects/*/skills/*/`
2. 检查每个 skill 下是否有 `SKILL.md`
3. 在 `.github/skills/` 下创建符号链接（symlink）
4. 已存在的公共 Skill（非链接目录）不会被覆盖

```
projects/demo-project/skills/demo-review/
        │
        │  symlink
        ▼
.github/skills/demo-review/ → ../../../projects/demo-project/skills/demo-review/
```

### 6.6 自动上下文注入（Instructions）

`.github/instructions/project-context.instructions.md` 配置了 `applyTo: "projects/**"`。

当用户在 Copilot 中引用 `projects/` 下的文件时，该 instruction 会**自动注入**，指导 Agent：

1. 从文件路径提取项目名
2. 读取该项目的 `context/` 目录
3. 优先查找并使用项目专属 Skill

这意味着用户不需要手动调用 `/xf-project-ctx`，只要操作的是项目文件，上下文就会自动加载。

---

## 7. 现有 Skill 清单

| Skill | 类型 | 版本 | 斜杠命令 | 状态 | 说明 |
|-------|------|------|---------|------|------|
| xf-review | 公共 | v1.0.0 | `/xf-review` | ✅ 可用 | 通用代码审查 |
| xf-project-ctx | 公共 | v1.0.0 | `/xf-project-ctx` | ✅ 可用 | 项目上下文加载器/调度器 |
| demo-review | 项目专属 | v1.0.0 | `/demo-review` | ✅ 可用 | demo-project 专属代码审查 |

---

## 8. 版本管理

### 语义化版本号

```
MAJOR.MINOR.PATCH

MAJOR — 不兼容的重大变更（如输出格式改变）
MINOR — 向后兼容的功能新增
PATCH — 向后兼容的 bug 修复
```

### 变更日志格式

在根目录 `CHANGELOG.md` 中记录全局变更：

```markdown
# Changelog

## [1.1.0] - 2026-xx-xx
### Added
- xf-review: 新增 Go 语言规范检查
### Fixed
- xf-review: 修复误触发问题

## [1.0.0] - 2026-03-20
### Added
- 初始版本：xf-review skill
```

---

## 9. 开发工作流

### 新建公共 Skill 流程

```
1. 复制脚手架       shared/templates/skill-template/ → .github/skills/<name>/
2. 修改 SKILL.md    填写 name、description、正文
3. 添加资源         references/、scripts/ 按需添加
4. 本地测试         在 VS Code 中输入 / 验证发现 → 触发 → 输出
5. 提交 PR          附带测试场景说明
6. Code Review      至少 1 人 review
7. 合并发布         更新 CHANGELOG、打 tag
```

### 新建项目专属 Skill 流程

```
1. 创建项目目录     projects/<项目名>/ （如不存在）
2. 编写上下文     projects/<项目名>/context/ 下创建 .md 文件
3. 创建 Skill      projects/<项目名>/skills/<项目缩写>-<功能>/SKILL.md
4. Skill 中引用      在 SKILL.md 中写明“Before You Start”读取 context/ 文件
5. 同步注册       bash scripts/sync-project-skills.sh
6. 测试验证         在 VS Code 中验证 Skill 发现 + 上下文加载
7. 提交推送         git push 到远端分支
```

### Skill Review 检查清单

```
□ name 与文件夹名一致
□ description 包含触发关键词
□ SKILL.md < 500 行
□ references/ 内文件被正文链接引用
□ 无硬编码密钥或敏感信息
□ 脚本有错误处理
□ 输出格式明确
□ 已更新 CHANGELOG
```

---

## 10. 反模式 & 最佳实践

### 避免的反模式

| 反模式 | 后果 | 正确做法 |
|--------|------|---------|
| 一个 Skill 做所有事 | 触发混乱、维护困难 | 单一职责，拆分为多个小 Skill |
| SKILL.md 全内容堆砌 | context 爆炸、加载慢 | 核心在正文，详细内容放 references/ |
| description 过于模糊 | Agent 无法发现 | 明确写 "Use when:" + 关键词 |
| 跨目录引用资源 | VS Code 加载失败 | 资源复制到 Skill 内部 |
| 硬编码敏感信息 | 安全风险 | 使用环境变量 |
| 文档不更新 | Agent 行为与预期不符 | 代码改了文档必须同步改 |
| 裸 except 捕获 | 隐藏错误、无法调试 | 捕获具体异常 |
| 文件夹名与 name 不匹配 | 静默失败，无报错 | 严格保持一致 |

### 关键最佳实践

1. **关键词驱动发现** — description 是唯一的发现面，务必包含用户会使用的关键词
2. **渐进加载** — SKILL.md 只放核心指令，详细规范放 references
3. **自包含** — 每个 Skill 独立运行，不依赖外部相对路径
4. **从 MVP 开始** — 先做最小可用版本，快速测试，再迭代扩展
5. **明确边界** — 在 SKILL.md 中说明能做什么、不能做什么

---

## 11. 迭代路线图

### 阶段 1：基础搭建 ✅

- [x] 建立标准目录结构 `.github/skills/`
- [x] 完成首个公共 Skill `xf-review`
- [x] 编写架构设计文档

### 阶段 2：子项目架构 ✅

- [x] 建立 `projects/` 子项目目录规范
- [x] 创建 `xf-project-ctx` 公共调度 Skill
- [x] 创建 `.github/instructions/` 自动上下文注入
- [x] 创建示例项目 `demo-project` 及其专属 Skill
- [x] 创建 `scripts/sync-project-skills.sh` 同步脚本

### 阶段 3：团队落地

- [ ] 将实际项目接入 `projects/` 目录
- [ ] 团队成员开始开发项目专属 Skill
- [ ] 在 Linux 服务器上验证完整流程（push → pull → sync → 调用）
- [ ] 收集反馈并迭代优化

### 阶段 4：工程化

- [ ] 添加 CI/CD：Skill 格式校验、安全扫描
- [ ] `git pull` 后自动运行 sync 脚本（git hook）
- [ ] 自动同步 `shared/` → 各 Skill 的 `references/`
- [ ] Skill 使用统计和效果评估

---

## 附录：VS Code Skill 发现机制

```
用户输入 / 或对话包含关键词
        │
        ▼
 Copilot 扫描 .github/skills/*/SKILL.md
        │
        ▼
 读取 name + description（~100 tokens）
        │
        ▼
 匹配到相关 Skill？ ─── 否 ──→ 不加载
        │
       是
        ▼
 加载 SKILL.md 正文（<5000 tokens）
        │
        ▼
 正文中引用了 references/xxx？ ─── 否 ──→ 执行
        │
       是
        ▼
 按需加载引用的资源文件
        │
        ▼
 执行 Skill 指令
```
