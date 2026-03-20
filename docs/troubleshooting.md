# 常见问题排查

---

## Skill 无法被 VS Code 识别

### 症状
在 Copilot Chat 输入 `/` 时看不到自定义 Skill。

### 排查步骤

1. **检查文件路径**
   - 必须为 `.github/skills/<name>/SKILL.md`
   - 不能是 `skills/`、`src/skills/` 等其他路径

2. **检查 name 与文件夹名**
   - YAML frontmatter 中的 `name` 必须与文件夹名**完全一致**
   - 只能用小写字母、数字、连字符
   - 此错误不会报任何警告，静默失败

3. **检查 YAML 语法**
   - 必须有开头和结尾的 `---`
   - 包含冒号的值必须加引号：`description: "Use when: xxx"`
   - 缩进使用空格，不能用 Tab

4. **重新加载窗口**
   - `Ctrl+Shift+P` → `Developer: Reload Window`
   - VS Code 可能缓存了旧的 Skill 索引

---

## Skill 不会自动触发

### 症状
对话中提到相关关键词，但 Skill 没被加载。

### 排查步骤

1. 检查 `description` 是否包含对话中的关键词
2. 确认 `disable-model-invocation` 未设为 `true`
3. 尝试使用 `/skill-name` 手动触发测试

---

## 引用的资源文件没被加载

### 症状
SKILL.md 中引用了 references/ 下的文件，但 Skill 执行时没有使用相关内容。

### 排查步骤

1. 确认使用**相对路径**：`./references/xxx.md`
2. 确认文件在 SKILL.md 同级或一级子目录下
3. 确认文件不是空文件
4. 确认 Markdown 链接语法正确：`[名称](./references/xxx.md)`

---

## YAML Frontmatter 常见错误

```yaml
# ❌ 冒号未加引号
description: Use when: code review

# ✅ 正确
description: "Use when: code review"
```

```yaml
# ❌ 使用了 Tab 缩进
name:	my-skill

# ✅ 使用空格
name: my-skill
```

```yaml
# ❌ 缺少结束的 ---
---
name: my-skill
description: "xxx"

# ✅ 有开头和结尾
---
name: my-skill
description: "xxx"
---
```
