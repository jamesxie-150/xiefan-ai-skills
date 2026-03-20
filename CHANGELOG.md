# Changelog

本项目所有重要变更记录。格式遵循 [Keep a Changelog](https://keepachangelog.com/)。

## [2.0.0] - 2026-03-20

### Added
- **子项目架构**：新增 `projects/` 子项目区，支持公共 Skill + 项目专属 Skill 双层架构
- 公共 Skill `xf-project-ctx`：项目上下文加载器/调度器
- `.github/instructions/project-context.instructions.md`：处理项目文件时自动注入上下文
- 示例子项目 `demo-project`：含 4 个上下文文档（overview, architecture, tech-stack, api-spec）
- 项目专属 Skill `demo-review`：结合 demo-project 上下文的代码审查
- `scripts/sync-project-skills.sh`：同步项目 Skill 到 `.github/skills/`（symlink）

### Changed
- 架构设计文档升级至 v2.0.0，新增子项目架构章节（§6）
- README 更新为双层架构说明
- 命名规范新增项目 Skill 前缀规则

## [1.0.0] - 2026-03-20

### Added
- 初始架构设计，建立 `.github/skills/` 标准目录结构
- 首个 Skill `xf-review`（代码审查助手 v1.0.0）
- 共享资源目录 `shared/`（coding-standards、api-guidelines、security-checklist）
- Skill 脚手架模板 `shared/templates/skill-template/`
- 架构设计文档 `Skill-Architecture_Design.md`
- 开发指南文档 `docs/`
