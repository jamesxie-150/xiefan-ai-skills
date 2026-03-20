# Skill 脚手架模板

## 使用方法

1. 复制本文件夹到 `.github/skills/<你的skill名>/`
2. 将 `SKILL.md.template` 重命名为 `SKILL.md`
3. 修改 `name` 为文件夹名（小写字母 + 连字符）
4. 填写 `description`，务必包含触发关键词
5. 编写正文（When to Use、Procedure、Output Format、Limitations）
6. 在 `references/` 下添加参考资料
7. 在 VS Code 中输入 `/` 验证 Skill 是否可发现

## 目录结构

```
your-skill-name/
├── SKILL.md              ← 入口文件（从 SKILL.md.template 重命名）
├── references/            ← 参考文档
│   └── (添加你的参考文件)
├── scripts/               ← 可执行脚本（可选）
└── templates/             ← 输出模板（可选）
```

## 检查清单

- [ ] `name` 与文件夹名一致
- [ ] `description` ≤ 1024 字符，包含 "Use when:" + 关键词
- [ ] SKILL.md < 500 行
- [ ] 无硬编码敏感信息
- [ ] 资源文件用相对路径 `./references/xxx` 引用
