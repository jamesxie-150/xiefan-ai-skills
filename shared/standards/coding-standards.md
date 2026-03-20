# Team Coding Standards

> 版本：v1.0.0 | 维护于 `shared/standards/`，各 Skill 复制到自身 `references/` 下使用

## Python

- 使用 type hints 标注所有函数参数和返回值
- 严格遵循 PEP 8
- Docstrings 使用 Google 风格
- 使用 f-string 而非 `+` 拼接字符串
- 使用 `with` 语句管理文件和资源

## TypeScript / JavaScript

- 优先使用 `const`，必要时用 `let`，禁止 `var`
- 使用严格等号 `===`
- 异步操作使用 `async/await`
- 组件/类名 PascalCase，函数/变量 camelCase

## Go

- 遵循 Effective Go 和官方 Code Review Comments
- 错误处理不可忽略，必须显式处理
- 公开函数必须有注释

## 安全

- **禁止**硬编码 API Key、密码等敏感信息，一律使用环境变量
- 所有用户输入必须验证和清洗
- SQL 查询使用参数化绑定，禁止拼接
- 使用 HTTPS，禁止明文传输敏感数据

## 异常处理

- 禁止裸 `except:` / `catch {}`，必须捕获具体异常类型
- 异常信息应包含上下文，便于定位
- 资源清理放在 `finally` 或使用上下文管理器
