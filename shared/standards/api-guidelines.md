# API 设计指南

> 版本：v1.0.0 | 维护于 `shared/standards/`

## RESTful 规范

- URL 使用名词复数形式：`/api/v1/users`
- HTTP 方法语义正确：GET 读、POST 创建、PUT 全更新、PATCH 部分更新、DELETE 删除
- 状态码准确：200/201/204/400/401/403/404/500
- 分页使用 `?page=1&size=20`，响应包含 `total`

## 命名规范

- URL 路径：kebab-case（`/user-profiles`）
- JSON 字段：camelCase（`userName`）
- 查询参数：camelCase

## 错误响应格式

```json
{
  "code": "VALIDATION_ERROR",
  "message": "用户名不能为空",
  "details": []
}
```

## 版本管理

- URL 路径版本：`/api/v1/`、`/api/v2/`
- 废弃 API 提前至少一个版本通知
