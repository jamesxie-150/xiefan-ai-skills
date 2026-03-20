# Demo Project — API 规范

## 统一响应格式

```json
{
  "code": 0,
  "message": "success",
  "data": {},
  "trace_id": "abc-123"
}
```

## 错误码规范

| 范围 | 模块 | 示例 |
|------|------|------|
| 1000-1999 | 通用错误 | 1001 参数校验失败 |
| 2000-2999 | 订单模块 | 2001 订单不存在 |
| 3000-3999 | 支付模块 | 3001 支付超时 |
| 4000-4999 | 物流模块 | 4001 无可用运力 |

## 核心 API

### 创建订单
```
POST /api/v1/orders
Body: { "user_id": 123, "items": [...], "address_id": 456 }
Response: { "code": 0, "data": { "order_id": "20260320001" } }
```

### 查询订单
```
GET /api/v1/orders/{order_id}
Response: { "code": 0, "data": { "order_id": "...", "status": "paid", ... } }
```

### 支付回调
```
POST /api/v1/payments/callback
Body: { "order_id": "...", "channel": "alipay", "status": "success" }
```

## 鉴权

- 使用 JWT Token，Header: `Authorization: Bearer <token>`
- Token 有效期 2 小时，Refresh Token 7 天
