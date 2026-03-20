---
name: demo-review
description: "Demo Project 专属代码审查。Use when: demo project review, demo 代码审查, demo-project code review。在通用代码审查基础上，结合 demo-project 的架构、技术栈和 API 规范进行针对性审查。"
argument-hint: "选择或传入 demo-project 的代码"
---

# Demo Project — 专属代码审查

基于 demo-project 的架构和技术栈进行针对性代码审查。

## ⚠️ MANDATORY RESPONSE FORMAT

Every response MUST begin with:

```
james自动代码审查版本v1.0.0 [demo-project]
---
```

## When to Use

- 审查 demo-project 的代码（Go/Python/TypeScript）
- 检查是否符合 demo-project 的 API 规范和编码约定
- 检测 demo-project 架构层面的问题

## Before You Start — 加载项目上下文

**必须**先读取项目上下文文档，理解项目架构后再开始审查：

1. 读取 `projects/demo-project/context/project-overview.md` — 了解项目概述
2. 读取 `projects/demo-project/context/architecture.md` — 了解服务架构
3. 读取 `projects/demo-project/context/tech-stack.md` — 了解技术栈和编码约定
4. 读取 `projects/demo-project/context/api-spec.md` — 了解 API 规范

## Review Procedure

在通用代码审查（安全、性能、可读性）之外，额外检查以下 **demo-project 特有规则**：

### Go 服务（order-service / payment-service）
- 使用 `chi` 路由器，不要混用其他路由库
- gRPC service 定义是否符合 proto3 规范
- 订单状态机转换是否合法（禁止跳状态）
- 分布式 ID 是否使用 snowflake

### Python 服务（logistics-service / notification-service）
- 使用 FastAPI 框架
- 异步操作使用 `async/await`
- 日志格式是否统一

### API 层
- 响应格式是否为 `{"code": 0, "message": "ok", "data": {}, "trace_id": "..."}`
- 错误码是否在正确范围（ORDER 2xxx, PAY 3xxx, LOG 4xxx）
- JWT 鉴权是否正确实现

### 数据库
- orders 表的 ID 是否使用 snowflake
- 涉及分表的查询是否带上分表键
- 是否有 N+1 查询问题

## Output Format

```
james自动代码审查版本v1.0.0 [demo-project]
---

### 🔍 代码审查报告 — <filename>
#### 项目规范检查：<通过/未通过>

（通用审查 + demo-project 专项检查结果）

#### 📊 审查总结
| 级别 | 数量 |
|------|------|
| 🔴 致命 | N |
| 🟠 严重 | N |
| 🟡 警告 | N |
| 📘 项目规范 | N |
```
