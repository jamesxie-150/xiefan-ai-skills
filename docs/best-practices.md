# 最佳实践

在开发和维护 Skill 过程中，遵循以下实践可以避免常见陷阱。

---

## 设计原则

### 单一职责
每个 Skill 只做一件事。如果发现一个 Skill 在做多件不相关的事，应该拆分为多个 Skill。

### 渐进加载
- SKILL.md 正文 < 500 行
- 详细规范、示例放到 `references/`
- Agent 只在需要时才加载引用的资源

### 关键词驱动发现
`description` 是 Agent 能否找到 Skill 的**唯一关键**。务必包含用户可能使用的关键词：

```yaml
# ✅ 好的 description
description: "代码审查助手。Use when: code review, review this code, lint, security check。"

# ❌ 差的 description
description: "一个有用的辅助工具"
```

### 自包含
Skill 文件夹包含自身所需的全部资源，不依赖外部相对路径。共享资源复制到 Skill 内部使用。

### 明确边界
在 SKILL.md 的 Limitations 部分清楚说明 Skill 能做什么、不能做什么，避免用户产生错误期望。

---

## 反模式清单

| 反模式 | 正确做法 |
|--------|---------|
| 一个 Skill 做所有事情 | 拆分为多个单一职责的小 Skill |
| description 模糊不清 | 使用 "Use when:" + 具体关键词 |
| SKILL.md 堆砌所有内容 | 核心指令在正文，详细内容放 references/ |
| name 与文件夹名不一致 | 严格保持一致（静默失败，无报错） |
| 硬编码密钥和密码 | 使用环境变量 |
| 脚本缺少错误处理 | 捕获具体异常，返回有意义的错误信息 |
| 跨目录引用资源 | 资源复制到 Skill 内部 |
| 文档不随代码更新 | 修改逻辑时同步更新 SKILL.md |

---

## 开发建议

1. **从 MVP 开始** — 先做最小可用版本，先跑通再优化
2. **先手动测试** — 在 VS Code Chat 中实际触发，验证发现 → 加载 → 输出
3. **控制开发时间** — 第一版不超过半天，快速验证价值
4. **记录问题** — 遇到的坑写入 troubleshooting.md，避免重复踩坑
5. **版本迭代** — 每次改动更新版本号和 CHANGELOG
