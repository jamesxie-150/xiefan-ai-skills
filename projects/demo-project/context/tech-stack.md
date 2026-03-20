# Demo Project — 技术栈

## 后端

| 组件 | 技术选型 | 版本 |
|------|---------|------|
| API Gateway | Kong | 3.4 |
| 主语言 | Go | 1.22 |
| 辅助语言 | Python | 3.12 |
| 数据库 | PostgreSQL | 16 |
| 缓存 | Redis | 7.2 |
| 消息队列 | RabbitMQ | 3.13 |
| 服务间通信 | gRPC + protobuf | proto3 |
| 容器编排 | Kubernetes | 1.29 |

## 前端

| 组件 | 技术选型 | 版本 |
|------|---------|------|
| 框架 | React | 18 |
| 语言 | TypeScript | 5.4 |
| UI 库 | Ant Design | 5.x |
| 构建工具 | Vite | 5.x |

## DevOps

| 组件 | 技术选型 |
|------|---------|
| CI/CD | GitLab CI |
| 镜像仓库 | Harbor |
| 监控 | Prometheus + Grafana |
| 日志 | ELK Stack |
| 链路追踪 | Jaeger |

## 编码约定（补充）

- Go 服务统一使用 `chi` 路由器
- Python 服务使用 FastAPI
- 所有 API 返回统一 JSON 格式：`{"code": 0, "message": "ok", "data": {}}`
- 错误码前缀：ORDER_xxx、PAY_xxx、LOG_xxx
