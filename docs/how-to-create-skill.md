# 如何创建新 Skill

本文档指导你从零创建一个符合 VS Code Copilot 规范的 Skill。

---

## 前置知识

- Skill 是 Copilot Agent 按需加载的能力模块
- 在 Copilot Chat 中输入 `/` 可触发 Skill
- Agent 也会根据对话内容自动匹配 Skill

## 步骤

### 1. 确定 Skill 名称

- 仅使用 **小写字母、数字和连字符**
- 长度 1-64 字符
- 建议格式：`xf-<功能>`，如 `xf-review`、`xf-doc-gen`

### 2. 创建目录

从脚手架模板复制：

```powershell
Copy-Item -Recurse shared/templates/skill-template .github/skills/<skill-name>
Rename-Item .github/skills/<skill-name>/SKILL.md.template SKILL.md
```

最终结构：

```
.github/skills/<skill-name>/
├── SKILL.md
├── references/
│   └── (你的参考文件)
├── scripts/       # 可选
└── templates/     # 可选
```

### 3. 编写 SKILL.md

#### YAML Frontmatter

```yaml
---
name: skill-name                # 必须与文件夹名一致！
description: "功能描述。Use when: 关键词1, 关键词2。"  # 必须包含触发关键词
argument-hint: "参数提示"        # 可选
---
```

**关键要求**：
- `name` 必须等于文件夹名，否则**静默失败**
- `description` 是 Agent 发现 Skill 的唯一线索，用 "Use when:" 列出触发词
- 包含冒号的值必须用引号包裹（YAML 语法要求）

#### Markdown 正文

```markdown
# Skill 标题

## When to Use
- 触发场景列表

## Procedure
1. 步骤 1
2. 步骤 2 — 引用 [参考文档](./references/xxx.md)

## Output Format
输出格式说明

## Limitations
- 边界说明
```

**正文控制在 500 行以内**，详细内容放到 `references/` 下。

### 4. 添加参考资料

将参考文档放入 `references/` 目录，在 SKILL.md 正文中用相对路径引用：

```markdown
请参考 [编码规范](./references/coding-standards.md)
```

如需使用共享资源，从 `shared/standards/` 复制到 Skill 内部的 `references/`。

### 5. 本地测试

1. 在 VS Code 中打开工作区
2. 可能需要重新加载窗口：`Ctrl+Shift+P` → `Developer: Reload Window`
3. 在 Copilot Chat 输入 `/`，确认列表中出现你的 Skill
4. 触发 Skill，验证输出是否符合预期

### 6. 提交

- 更新根目录 `CHANGELOG.md`
- 提交 PR，附带测试场景说明

---

## 常见问题

### Skill 没出现在 `/` 列表中

1. 检查文件夹路径：必须是 `.github/skills/<name>/SKILL.md`
2. 检查 `name` 字段是否与文件夹名完全一致
3. 检查 YAML frontmatter 语法：`---` 包裹，值含冒号需加引号
4. 尝试 `Developer: Reload Window`

### Skill 没被自动触发

- 检查 `description` 是否包含对话中的关键词
- 确认 `disable-model-invocation` 未设为 `true`

### 引用的资源文件没被加载

- 确认使用相对路径 `./references/xxx.md`
- 确认文件在 SKILL.md 的同级或一级子目录下
