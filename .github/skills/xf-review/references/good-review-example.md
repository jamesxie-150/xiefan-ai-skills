# Good Review Example

## User Input
```
/xf-review
```

## Expected Response

james自动代码审查版本v1.0.0
---

### 🔍 代码审查报告 — example.py

#### 🔴 致命 #1 — 空指针风险 (Line 15)
- **问题**: `user.getName()` 可能在 `user` 为 `None` 时抛出 `AttributeError`。
- **修复**:
```python
if user is not None:
    name = user.getName()
else:
    name = "Unknown"
```

#### 🟠 严重 #2 — SQL 注入 (Line 32)
- **问题**: 直接将用户输入拼接到 SQL 查询中。
- **修复**:
```python
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

#### 🟡 警告 #3 — 缺少类型注解 (Line 5)
- **问题**: 函数参数和返回值缺少类型注解，不符合团队编码规范。
- **修复**:
```python
def get_user(user_id: int) -> Optional[User]:
```

#### 📊 审查总结

| 级别 | 数量 | 说明 |
|------|------|------|
| 🔴 致命 | 1 | 空指针风险 |
| 🟠 严重 | 1 | SQL 注入 |
| 🟡 警告 | 1 | 缺少类型注解 |
