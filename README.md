# AI Skills Library 🤖

面向 VS Code Copilot 的自定义 Skill 集合，支持**公共 Skill + 项目专属 Skill** 双层架构。

> 架构详情请参阅 [Skill-Architecture_Design.md](Skill-Architecture_Design.md)

## 📂 目录结构

```
.github/
  skills/                         # VS Code Skill 发现区（公共 + 项目专属）
    xf-review/                    # [公共] 代码审查
    xf-project-ctx/               # [公共] 项目上下文加载器/调度器
    demo-review/ → (symlink)      # [项目专属] 由 sync 脚本链接
  instructions/                   # File Instructions（自动注入）
    project-context.instructions.md
projects/                         # 子项目区
  demo-project/                   # 示例子项目
    context/                      # 项目上下文 .md 文档
    skills/                       # 项目专属 Skill 源码
    src/                          # 项目源码
scripts/                          # 运维脚本
  sync-project-skills.sh          # 同步项目 Skill → .github/skills/
shared/                           # 跨 Skill 共享资源
docs/                             # 开发文档
```

## 📋 可用 Skills

### 公共 Skill

| Skill | 版本 | 斜杠命令 | 说明 |
|-------|------|---------|------|
| xf-review | v1.0.0 | `/xf-review` | 通用代码审查 |
| xf-project-ctx | v1.0.0 | `/xf-project-ctx` | 项目上下文加载 + 项目 Skill 调度 |

### 项目专属 Skill

| Skill | 所属项目 | 斜杠命令 | 说明 |
|-------|---------|---------|------|
| demo-review | demo-project | `/demo-review` | 结合项目上下文的代码审查 |

## 🚀 使用方法

### 日常使用

1. 在 Copilot Chat 输入 `/xf-project-ctx demo-project` 加载项目上下文
2. 然后使用 `/demo-review` 进行项目专属代码审查
3. 或直接在对话中描述需求，Agent 会自动匹配合适的 Skill

### Linux 服务器同步

```bash
# 拉取最新代码后，同步项目 Skill
git pull
bash scripts/sync-project-skills.sh
```

## 🛠 添加新子项目

1. 在 `projects/` 下创建项目目录
2. 在 `context/` 下编写项目上下文 `.md` 文件
3. 在 `skills/` 下开发项目专属 Skill
4. 运行 `bash scripts/sync-project-skills.sh` 注册

详见 [docs/how-to-create-skill.md](docs/how-to-create-skill.md)

## 📚 文档

- [架构设计](Skill-Architecture_Design.md) — 双层架构、子项目机制、同步策略
- [创建指南](docs/how-to-create-skill.md) — 从零创建 Skill 的完整步骤
- [最佳实践](docs/best-practices.md) — 设计原则与反模式清单
- [问题排查](docs/troubleshooting.md) — Skill 无法识别等常见问题解决
- [变更日志](CHANGELOG.md) — 版本历史
