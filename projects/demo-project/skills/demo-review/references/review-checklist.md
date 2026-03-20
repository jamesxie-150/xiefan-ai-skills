# Demo Project — 审查检查清单

## 通用检查（所有语言）

- [ ] 无硬编码密钥
- [ ] 输入已验证
- [ ] 错误已处理（非裸 catch/except）
- [ ] 日志级别正确

## Go 服务专项

- [ ] 使用 `chi` 路由器
- [ ] gRPC 接口定义符合 proto3
- [ ] 订单状态转换合法
- [ ] 使用 snowflake 生成 ID
- [ ] Context 正确传递和超时处理
- [ ] 避免 goroutine 泄漏

## Python 服务专项

- [ ] 使用 FastAPI（非 Flask）
- [ ] 异步操作使用 async/await
- [ ] Type hints 完整
- [ ] 依赖注入使用 Depends

## API 规范专项

- [ ] 响应格式统一 `{"code", "message", "data", "trace_id"}`
- [ ] 错误码在正确范围
- [ ] JWT 鉴权已配置
- [ ] 分页参数规范

## 数据库专项

- [ ] ID 使用 snowflake
- [ ] 分表查询带分表键
- [ ] 无 N+1 查询
- [ ] 事务边界正确
