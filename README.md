# AI Skills Library 🤖

面向 VS Code Copilot 的自定义 Skill 集合，用于增强编码、写作和分析效率。

> 架构详情请参阅 [Skill-Architecture_Design.md](Skill-Architecture_Design.md)

## 📂 目录结构

```
.github/
  skills/                         # VS Code Skill 存放区
    xf-review/                    # 代码审查 Skill
      SKILL.md
      references/
shared/                           # 跨 Skill 共享资源
  standards/                      # 团队规范
  templates/skill-template/       # 新 Skill 脚手架
  utils/                          # 通用脚本（预留）
docs/                             # 开发文档
  how-to-create-skill.md          # 创建指南
  best-practices.md               # 最佳实践
  troubleshooting.md              # 问题排查
CHANGELOG.md                      # 全局变更日志
Skill-Architecture_Design.md      # 架构设计文档
```

## 📋 可用 Skills

| Skill | 版本 | 斜杠命令 | 说明 |
|-------|------|---------|------|
| xf-review | v1.0.0 | `/xf-review` | 代码审查：安全性、性能、最佳实践 |

## 🚀 使用方法

1. 将本仓库克隆或放置到你的项目根目录
2. 确保 `.github/skills/` 目录存在于工作区中
3. 在 Copilot Chat 中输入 `/` 即可看到可用 Skill
4. 或直接在对话中使用关键词（如 "code review"、"security check"）触发

## 🛠 创建新 Skill

详见 [docs/how-to-create-skill.md](docs/how-to-create-skill.md)

快速开始：

```powershell
Copy-Item -Recurse shared/templates/skill-template .github/skills/<skill-name>
Rename-Item .github/skills/<skill-name>/SKILL.md.template SKILL.md
# 编辑 SKILL.md，修改 name、description、正文
```

## 📚 文档

- [架构设计](Skill-Architecture_Design.md) — 整体架构、目录规范、设计原则
- [创建指南](docs/how-to-create-skill.md) — 从零创建 Skill 的完整步骤
- [最佳实践](docs/best-practices.md) — 设计原则与反模式清单
- [问题排查](docs/troubleshooting.md) — Skill 无法识别等常见问题解决
- [变更日志](CHANGELOG.md) — 版本历史
