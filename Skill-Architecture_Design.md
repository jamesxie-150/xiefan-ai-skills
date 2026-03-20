# Skill 架构设计文档

> 版本：v1.0.0 | 作者：James | 日期：2026-03-20
>
> 参考：[Claude Skills 实战：如何为团队构建专属 AI 能力](https://www.80aj.com/2025/10/20/claude-skills%e5%ae%9e%e6%88%98%ef%bc%9a%e5%a6%82%e4%bd%95%e4%b8%ba%e5%9b%a2%e9%98%9f%e6%9e%84%e5%bb%ba%e4%b8%93%e5%b1%9eai%e8%83%bd%e5%8a%9b/) — Toy's Tech Notes

---

## 1. 设计目标

1. **VS Code 原生兼容** — 所有 Skill 严格遵循 `.github/skills/<name>/SKILL.md` 规范，确保 Copilot Agent 可自动发现、加载和触发。
2. **单一职责** — 每个 Skill 只做一件事，通过组合实现复杂工作流。
3. **渐进加载** — 利用 VS Code 的三级加载机制（Discovery → Instructions → Resources），控制 context 消耗。
4. **团队可协作** — 共享资源集中管理，支持多人并行开发不同 Skill。
5. **可迭代** — 语义化版本管理 + CHANGELOG，支持平滑升级。

---

## 2. 目录结构

```
xiefan-ai-skills/                          # 仓库根目录
├── README.md                              # 项目总览与使用指南
├── Skill-Architecture_Design.md           # 本文档：架构设计说明
├── CHANGELOG.md                           # 全局变更日志
│
├── .github/
│   ├── skills/                            # ★ VS Code Skill 存放区（核心）
│   │   ├── xf-review/                    # Skill: 代码审查
│   │   │   ├── SKILL.md                  # 入口文件（YAML frontmatter + Markdown）
│   │   │   ├── references/               # 参考资料（按需加载）
│   │   │   │   ├── coding-standards.md
│   │   │   │   └── good-review-example.md
│   │   │   └── scripts/                  # 可执行脚本（按需加载）
│   │   │       └── (预留)
│   │   │
│   │   ├── xf-doc-gen/                   # Skill: 文档生成（规划中）
│   │   │   ├── SKILL.md
│   │   │   ├── references/
│   │   │   └── templates/
│   │   │
│   │   └── xf-debug/                     # Skill: 调试助手（规划中）
│   │       ├── SKILL.md
│   │       ├── references/
│   │       └── scripts/
│   │
│   └── workflows/                         # GitHub Actions CI/CD
│       └── skill-validation.yml           # Skill 格式校验 & 安全扫描
│
├── shared/                                # 跨 Skill 共享资源
│   ├── standards/                         # 团队规范
│   │   ├── coding-standards.md
│   │   ├── api-guidelines.md
│   │   └── security-checklist.md
│   ├── templates/                         # 通用模板
│   │   └── skill-template/               # 新 Skill 脚手架
│   │       ├── SKILL.md.template
│   │       └── README.md
│   └── utils/                             # 通用脚本
│       └── (预留)
│
└── docs/                                  # 项目文档
    ├── how-to-create-skill.md             # 如何创建新 Skill
    ├── best-practices.md                  # 最佳实践
    └── troubleshooting.md                 # 常见问题排查
```

### 关键约束

| 规则 | 说明 |
|------|------|
| Skill 必须放在 `.github/skills/<name>/` | 这是 VS Code Copilot 唯一扫描的项目级路径 |
| `name` 字段 = 文件夹名 | 小写字母 + 连字符，1-64 字符，如 `xf-review` |
| SKILL.md 必须为 Markdown | YAML frontmatter（`---`）仅包含元数据，正文为 Markdown |
| 资源文件只深入一级 | 从 SKILL.md 引用的文件应在 `./references/`、`./scripts/`、`./templates/` 下 |
| Skill 自包含 | 每个 Skill 文件夹内包含自身所需的全部资源，不依赖外部相对路径 |

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

| 模式 | 示例 | 说明 |
|------|------|------|
| `xf-<功能>` | `xf-review`, `xf-debug` | 个人前缀，用于标识作者 |
| `<功能>-<子类>` | `code-review`, `api-review` | 通用命名风格 |

**规则**：
- 仅使用小写字母、数字和连字符
- 长度 1-64 字符
- 必须与文件夹名完全一致

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

## 6. 现有 Skill 清单

| Skill | 版本 | 斜杠命令 | 状态 | 说明 |
|-------|------|---------|------|------|
| xf-review | v1.0.0 | `/xf-review` | ✅ 可用 | 代码审查：安全性、性能、最佳实践 |
| xf-doc-gen | — | `/xf-doc-gen` | 📋 规划中 | 技术文档生成 |
| xf-debug | — | `/xf-debug` | 📋 规划中 | 调试分析助手 |

---

## 7. 版本管理

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

## 8. 开发工作流

### 新建 Skill 流程

```
1. 复制脚手架       shared/templates/skill-template/ → .github/skills/<name>/
2. 修改 SKILL.md    填写 name、description、正文
3. 添加资源         references/、scripts/ 按需添加
4. 本地测试         在 VS Code 中输入 / 验证发现 → 触发 → 输出
5. 提交 PR          附带测试场景说明
6. Code Review      至少 1 人 review
7. 合并发布         更新 CHANGELOG、打 tag
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

## 9. 反模式 & 最佳实践

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

## 10. 迭代路线图

### 阶段 1：基础搭建 ✅

- [x] 建立标准目录结构 `.github/skills/`
- [x] 完成首个 Skill `xf-review` 并通过 VS Code 识别验证
- [x] 编写架构设计文档

### 阶段 2：夯实基础

- [ ] 补充 `shared/` 共享资源目录
- [ ] 创建 Skill 脚手架模板 `shared/templates/skill-template/`
- [ ] 编写 `docs/how-to-create-skill.md` 开发指南
- [ ] 添加 `CHANGELOG.md`

### 阶段 3：扩展 Skill

- [ ] 开发 `xf-doc-gen`（文档生成）
- [ ] 开发 `xf-debug`（调试助手）
- [ ] 对 `xf-review` 进行迭代优化（支持更多语言、输出格式优化）

### 阶段 4：工程化

- [ ] 添加 CI/CD：Skill 格式校验、安全扫描（`.github/workflows/skill-validation.yml`）
- [ ] 自动同步 `shared/` → 各 Skill 的 `references/`
- [ ] 建立 Skill review 流程和检查清单

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
