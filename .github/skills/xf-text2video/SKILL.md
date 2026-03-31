---
name: xf-text2video
description: "文本转沙雕动漫视频生成器。Use when: 文本转视频, text to video, 生成动漫, 沙雕动画, 故事转视频, AnimateDiff, ComfyUI, /xf-text2video。将文本故事拆解为分镜，生成 AnimateDiff prompt，通过 ComfyUI MCP 生成动画视频。"
argument-hint: "粘贴或输入你的故事/笑话文本"
---

# Text-to-Video 沙雕动漫生成器

将文本故事/笑话自动拆解为分镜脚本，生成 AnimateDiff 风格的 Prompt，并通过 ComfyUI MCP 接口提交生成任务。

## ⚠️ MANDATORY RESPONSE FORMAT

Every response MUST begin with these two lines, no exceptions:

```
xf-text2video v1.0.0
---
```

## When to Use

- 用户提供一段文字故事/笑话，想生成沙雕动漫视频
- 用户使用 `/xf-text2video` 命令
- 用户要求将文本转为 AnimateDiff 动画
- 用户要求生成搞笑/沙雕风格的短视频

## Prerequisites

- ComfyUI 服务器已启动并运行（默认 `http://127.0.0.1:8188`）
- AnimateDiff 模型已安装（推荐 `mm_sd_v15_v2.ckpt`）
- ComfyUI MCP 服务器已配置（见 MCP 配置说明）
- 推荐检查点模型：`counterfeitV30_v30.safetensors` 或同类动漫风格模型

## Procedure

### Phase 1: 故事分镜拆解

1. 读取用户提供的文本故事
2. 将故事拆解为 **3-6 个关键分镜**（shot），每个分镜包含：
   - **场景描述**（setting）：环境、光线、氛围
   - **角色动作**（action）：人物正在做什么
   - **情绪/表情**（emotion）：角色表情状态
   - **镜头运动**（camera）：推/拉/摇/移/特写

### Phase 2: Prompt 生成

3. 对每个分镜，按照 [prompt-engineering.md](./references/prompt-engineering.md) 的规范生成：
   - **正向 Prompt**（positive）：画面描述，含画质标签
   - **负向 Prompt**（negative）：排除元素
   - **运动参数**（motion）：AnimateDiff 运动强度
   - **帧数**（frames）：推荐 16 帧
   - **推荐 seed**：随机或用户指定

4. 按照 [animatediff-params.md](./references/animatediff-params.md) 填入工作流参数

### Phase 3: ComfyUI 提交（需 MCP）

5. 检查 ComfyUI MCP 工具是否可用：
   - 尝试调用 `mcp_comfyui_*` 系列工具
   - 如不可用，回退到输出 JSON 工作流供用户手动导入

6. **如果 MCP 可用**：
   - 使用 MCP 工具获取 ComfyUI 系统信息，确认模型可用
   - 逐个分镜提交工作流到 ComfyUI 队列
   - 等待生成结果，返回输出文件路径

7. **如果 MCP 不可用**（回退模式）：
   - 输出完整的 ComfyUI API JSON 工作流
   - 附带手动导入说明
   - 提供 curl 命令供用户自行提交

### Phase 4: 结果输出

8. 汇总所有分镜的生成结果
9. 提供后续建议（如拼接、配音、字幕工具）

## Prompt 风格规范（沙雕动漫）

生成的正向 Prompt **必须包含**以下基础标签：

```
masterpiece, best quality, anime style, chibi, cute, exaggerated expression,
vibrant colors, comedic, cartoon, dynamic pose
```

负向 Prompt 基础模板：

```
worst quality, low quality, blurry, realistic, photorealistic,
3d render, deformed, ugly, bad anatomy, extra limbs
```

## Output Format

每个分镜输出格式：

```markdown
### 🎬 分镜 N: [简短标题]

**场景**: [场景描述]
**动作**: [角色动作]
**情绪**: [表情/氛围]
**镜头**: [镜头运动]

**Positive Prompt**:
> [完整正向提示词]

**Negative Prompt**:
> [完整负向提示词]

**参数**:
| 参数 | 值 |
|------|------|
| Steps | 20 |
| CFG Scale | 7 |
| Sampler | euler_ancestral |
| Scheduler | normal |
| Frames | 16 |
| Motion Scale | 1.0 |
| FPS | 8 |
| Seed | [random] |
```

## Workflow JSON 模板

回退模式下，输出可导入 ComfyUI 的 API 格式 JSON，参考 [comfyui-workflow.md](./references/comfyui-workflow.md)。

## Limitations

- 每个分镜生成约 2 秒动画（16帧 / 8fps），完整故事约 6-12 秒
- 角色一致性跨分镜无法保证（AnimateDiff 限制）
- 复杂场景可能需要手动调整 Prompt
- 首次运行需确认 ComfyUI 模型已下载
- 视频拼接需用户使用外部工具（FFmpeg 等）

## References

- [Prompt 工程指南](./references/prompt-engineering.md)
- [AnimateDiff 参数说明](./references/animatediff-params.md)
- [ComfyUI 工作流模板](./references/comfyui-workflow.md)
- [环境配置指南](./references/setup-guide.md)
