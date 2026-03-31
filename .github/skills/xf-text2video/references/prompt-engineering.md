# AnimateDiff Prompt 工程指南

## 沙雕动漫风格 Prompt 结构

### 正向 Prompt 模板

```
[质量标签], [风格标签], [场景描述], [角色描述], [动作描述], [情绪表情], [光线氛围], [镜头角度]
```

### 质量标签（必填）

```
masterpiece, best quality, highly detailed, anime style
```

### 沙雕风格标签（必填）

```
chibi, cute, exaggerated expression, vibrant colors, comedic,
cartoon style, dynamic pose, funny, humorous, parody
```

### 场景描述

| 场景类型 | 关键词示例 |
|---------|-----------|
| 室内-办公室 | `office, desk, computer, monitor, indoor lighting` |
| 室内-厨房 | `kitchen, counter, stove, warm lighting` |
| 室内-餐厅 | `restaurant, table, food, warm ambiance` |
| 室外-街道 | `city street, sidewalk, buildings, daylight` |
| 室外-公园 | `park, trees, grass, sunny day, blue sky` |

### 角色描述

| 角色类型 | 关键词示例 |
|---------|-----------|
| 程序员 | `1boy, glasses, hoodie, messy hair, tired eyes` |
| 外卖小哥 | `1boy, delivery uniform, helmet, carrying bag` |
| 厨师 | `1boy, chef hat, white uniform, apron` |
| 通用男 | `1boy, casual clothes, black hair` |
| 通用女 | `1girl, casual clothes, long hair` |

### 表情/情绪

| 情绪 | 关键词 |
|------|--------|
| 震惊 | `shocked expression, wide eyes, open mouth, sweat drop` |
| 得意 | `smug face, smirk, confident pose, sparkle eyes` |
| 困惑 | `confused, question mark, tilted head, sweat drop` |
| 大笑 | `laughing, tears of joy, holding stomach` |
| 无语 | `blank stare, deadpan, straight face, dot eyes` |
| 愤怒 | `angry, vein popping, red face, clenched fist` |

### 镜头角度

| 镜头 | 关键词 |
|------|--------|
| 正面中景 | `medium shot, front view, facing viewer` |
| 特写 | `close-up, face focus, portrait` |
| 全身 | `full body, wide shot` |
| 俯视 | `from above, bird eye view` |
| 仰视 | `from below, low angle` |

### 运动描述（AnimateDiff 专用）

在正向 prompt 末尾追加运动关键词：

| 运动类型 | 关键词 |
|---------|--------|
| 角色说话 | `talking, moving lips, head bobbing` |
| 角色走路 | `walking, moving forward, leg movement` |
| 角色转头 | `turning head, looking around` |
| 手势动作 | `gesturing, hand movement, pointing` |
| 环境运动 | `wind blowing, leaves falling, clouds moving` |

## 负向 Prompt 标准模板

```
worst quality, low quality, normal quality, lowres, blurry,
realistic, photorealistic, 3d render, photograph,
deformed, ugly, bad anatomy, extra limbs, extra fingers,
mutated hands, poorly drawn hands, poorly drawn face,
mutation, disfigured, bad proportions, malformed limbs,
missing arms, missing legs, extra arms, extra legs,
fused fingers, too many fingers, long neck,
text, watermark, signature, username
```

## 分镜衔接技巧

1. **保持角色描述一致**：每个分镜使用相同的角色外观关键词
2. **渐进式情绪变化**：按故事节奏递进表情关键词
3. **场景切换用不同环境词**：但保持光线风格统一
4. **笑点分镜放大表情**：使用 `extreme close-up, exaggerated reaction`
