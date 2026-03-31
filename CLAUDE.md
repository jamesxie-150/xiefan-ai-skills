# xiefan-ai-skills — AI 行为规范

> **本文件是 AI 助手行为的最高优先级约束。**  
> 当本文件与其他指令文件冲突时，以本文件为准。  
> **作者**: xiefan (个人项目)  
> **更新**: 2026-03-26

---

## 强制约束（MUST）

以下规则 **必须** 在每次回复中执行，无例外：

### 1. 回复头部格式

每次回复的 **第一行** 必须包含项目标识：

```
【项目】xiefan-ai-skills
【时间】YYYY-MM-DD
```

### 2. 首次交互展示 Skill 列表

会话中 **第一条** 回复必须展示可用技能：

```
本项目支持以下技能 (Skill):
✅ 项目上下文加载 → xf-project-ctx
✅ 放射科排班计算 → xf-radiology-schedule
✅ 代码审查助手   → xf-review
✅ 文本转视频生成 → xf-text2video
```

> 如有新增 Skill，请同步更新此列表。

### 3. 每次回复结束时询问后续

每次回答完毕后，**必须** 使用 `vscode_askQuestions` 工具向用户提供选项，格式：

```
请选择下一步:
1. [与当前话题相关的后续选项]
2. [其他可能需要的帮助]
3. 已完成 / 无其他问题
```

> **注意**: 工具名称是 `vscode_askQuestions`（不是 ask_question）。  
> 如果该工具不可用，则在回复末尾以文本形式提供选项。

---

## 项目上下文

### 目录结构

```
xiefan-ai-skills/
├── CLAUDE.md                  # 本文件（AI 行为规范）
├── README.md                  # 项目说明
├── Skill-Architecture_Design.md  # 技能架构设计
├── docs/                      # 文档
│   ├── best-practices.md
│   ├── how-to-create-skill.md
│   └── troubleshooting.md
├── projects/                  # 子项目（含独立上下文和 Skill）
│   └── demo-project/
├── shared/                    # 共享资源（标准、模板、工具）
│   ├── standards/
│   ├── templates/
│   └── utils/
├── scripts/                   # 脚本
├── utils/                     # 实用工具
└── .github/
    ├── skills/                # Skill 定义
    └── instructions/          # 指令文件
```

### 常用操作

| 操作 | 说明 |
|------|------|
| 创建新 Skill | 参考 `docs/how-to-create-skill.md` |
| 查看最佳实践 | 参考 `docs/best-practices.md` |
| 同步项目 Skill | 运行 `scripts/sync-project-skills.sh` |
| Skill 模板 | `shared/templates/skill-template/` |

### MCP 服务器

项目已集成以下 MCP 服务器（配置见 `.vscode/mcp.json`）：

| 服务器 | 用途 | 前置条件 |
|--------|------|----------|
| comfyui | AI 图像/视频生成 | 本地运行 ComfyUI |
| fetch | 网页抓取与 API 调用 | 需安装 uvx |
| filesystem | 文件系统安全操作 | — |
| memory | 跨会话知识图谱记忆 | — |
| sequential-thinking | 复杂问题分步推理 | — |
| github | GitHub 仓库/Issue/PR 操作 | 需设置 GitHub Token |
| playwright | 浏览器自动化与截图 | — |

---

## 禁止事项（NEVER）

- ❌ 不要跳过回复头部格式
- ❌ 不要忘记结尾的后续问题
- ❌ 不要泄露用户凭证或密码
- ❌ 不要未经确认直接删除或覆盖现有 Skill 文件
- ❌ 不要在不了解项目上下文的情况下修改 `projects/` 下的文件
