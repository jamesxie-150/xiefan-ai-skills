---
name: xf-project-ctx
description: "项目上下文加载器与调度器。Use when: 加载项目上下文, 读取项目信息, 切换项目, project context, 了解项目, 项目概述, 查看项目文档。自动读取 projects/<name>/context/ 下的所有 .md 文件，为后续项目级 Skill 提供上下文基础。"
argument-hint: "项目名称，如 demo-project"
---

# 项目上下文加载器 (Project Context Loader)

通用公共 Skill，负责读取指定子项目的上下文文档，并自动发现该项目的专属 Skill。

## When to Use

- 用户想了解某个子项目的架构、技术栈、API 等信息
- 用户切换到某个项目进行工作，需要加载项目上下文
- 在调用项目专属 Skill 之前，需要先加载项目上下文
- 用户提到 "项目上下文"、"project context"、"读取项目" 等关键词

## Procedure

### Step 1: 确定项目名称

从用户输入中提取项目名称。如果未指定，列出所有可用项目：

```
读取 projects/ 目录，列出所有子目录名称。
```

可用项目存放在工作区的 `projects/` 目录下，每个子目录是一个项目。

### Step 2: 读取项目上下文

读取 `projects/<项目名>/context/` 目录下的**所有 .md 文件**：

1. 先列出 `projects/<项目名>/context/` 目录内容
2. 按以下优先级顺序读取：
   - `project-overview.md` — 项目概述（最先读取）
   - `architecture.md` — 系统架构
   - `tech-stack.md` — 技术栈
   - `api-spec.md` — API 规范
   - 其余 `.md` 文件按字母顺序读取

### Step 3: 汇总并输出

向用户输出项目上下文摘要：

```
## 📋 项目上下文已加载：<项目名>

### 已读取的文档：
- [x] project-overview.md
- [x] architecture.md
- ...

### 项目摘要：
（基于读取的文档生成简短摘要）

### 可用的项目专属 Skill：
（列出 .github/skills/ 下以项目名为前缀的 skill）
```

### Step 4: 发现项目专属 Skill

扫描 `.github/skills/` 目录，找出以**项目名为前缀**的 Skill（命名规则：`<项目名>-<功能>`）。

例如项目名为 `demo-project`，则匹配：
- `demo-review`（代码审查）
- `demo-deploy`（部署）
- 以 `demo-` 开头的所有 skill

告知用户可用的项目专属 Skill，并建议使用对应的 `/` 斜杠命令。

## 项目注册规范

每个子项目必须遵循以下目录结构：

```
projects/<项目名>/
├── context/                 # 必需：项目上下文文档
│   ├── project-overview.md  # 推荐：项目概述
│   ├── architecture.md      # 推荐：系统架构
│   ├── tech-stack.md        # 推荐：技术栈
│   └── *.md                 # 其他项目特定文档
├── skills/                  # 可选：项目专属 Skill 源码
│   └── <skill-name>/
│       ├── SKILL.md
│       └── references/
└── src/                     # 可选：项目源码
```

## Limitations

- 只读取 `.md` 格式的上下文文件
- 上下文文件总量建议控制在 10 个以内，避免 context 过载
- 不会自动执行项目专属 Skill，只做发现和建议
