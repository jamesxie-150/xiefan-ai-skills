# ComfyUI AnimateDiff 工作流模板

## API 格式 JSON 模板

以下是可直接通过 ComfyUI API `/prompt` 端点提交的工作流模板。

### 基础 AnimateDiff 文生动画工作流

```json
{
  "3": {
    "class_type": "KSampler",
    "inputs": {
      "cfg": 7,
      "denoise": 1,
      "latent_image": ["5", 0],
      "model": ["10", 0],
      "negative": ["7", 0],
      "positive": ["6", 0],
      "sampler_name": "euler_ancestral",
      "scheduler": "normal",
      "seed": {{SEED}},
      "steps": 20
    }
  },
  "4": {
    "class_type": "CheckpointLoaderSimple",
    "inputs": {
      "ckpt_name": "{{CHECKPOINT_MODEL}}"
    }
  },
  "5": {
    "class_type": "EmptyLatentImage",
    "inputs": {
      "batch_size": {{FRAMES}},
      "height": {{HEIGHT}},
      "width": {{WIDTH}}
    }
  },
  "6": {
    "class_type": "CLIPTextEncode",
    "inputs": {
      "clip": ["4", 1],
      "text": "{{POSITIVE_PROMPT}}"
    }
  },
  "7": {
    "class_type": "CLIPTextEncode",
    "inputs": {
      "clip": ["4", 1],
      "text": "{{NEGATIVE_PROMPT}}"
    }
  },
  "8": {
    "class_type": "VAEDecode",
    "inputs": {
      "samples": ["3", 0],
      "vae": ["4", 2]
    }
  },
  "9": {
    "class_type": "VHS_VideoCombine",
    "inputs": {
      "images": ["8", 0],
      "fps": {{FPS}},
      "filename_prefix": "{{OUTPUT_PREFIX}}",
      "format": "video/h264-mp4",
      "pingpong": false,
      "save_output": true
    }
  },
  "10": {
    "class_type": "ADE_AnimateDiffLoaderWithContext",
    "inputs": {
      "model": ["4", 0],
      "model_name": "{{MOTION_MODEL}}",
      "beta_schedule": "linear",
      "motion_scale": {{MOTION_SCALE}},
      "context_options": ["11", 0]
    }
  },
  "11": {
    "class_type": "ADE_StandardStaticContextOptions",
    "inputs": {
      "context_length": 16,
      "context_stride": 1,
      "context_overlap": 4,
      "context_schedule": "uniform",
      "closed_loop": false
    }
  }
}
```

### 模板变量说明

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `{{SEED}}` | 随机种子 | `42` 或随机数 |
| `{{CHECKPOINT_MODEL}}` | Checkpoint 模型名 | `counterfeitV30_v30.safetensors` |
| `{{FRAMES}}` | 帧数 | `16` |
| `{{WIDTH}}` | 宽度 | `512` |
| `{{HEIGHT}}` | 高度 | `512` |
| `{{POSITIVE_PROMPT}}` | 正向提示词 | 见 prompt-engineering.md |
| `{{NEGATIVE_PROMPT}}` | 负向提示词 | 标准负向模板 |
| `{{FPS}}` | 帧率 | `8` |
| `{{OUTPUT_PREFIX}}` | 输出文件前缀 | `shot_01` |
| `{{MOTION_MODEL}}` | 运动模型名 | `mm_sd_v15_v2.ckpt` |
| `{{MOTION_SCALE}}` | 运动强度 | `1.0` |

## 手动导入说明

1. 保存上述 JSON（替换变量后）为 `.json` 文件
2. 打开 ComfyUI Web UI (`http://127.0.0.1:8188`)
3. 点击菜单 → Load → 选择保存的 JSON 文件
4. 或通过 API 直接提交：

```bash
curl -X POST "http://127.0.0.1:8188/prompt" \
  -H "Content-Type: application/json" \
  -d '{"prompt": <上述JSON>, "client_id": "text2video"}'
```

## 查询生成状态

```bash
# 查看队列状态
curl http://127.0.0.1:8188/queue

# 查看历史记录
curl http://127.0.0.1:8188/history

# 查看系统信息（检查模型列表）
curl http://127.0.0.1:8188/system_stats
```

## 多分镜批量提交

每个分镜生成一个独立的 workflow JSON，按顺序提交：

```bash
for i in shot_01.json shot_02.json shot_03.json; do
  curl -X POST "http://127.0.0.1:8188/prompt" \
    -H "Content-Type: application/json" \
    -d "{\"prompt\": $(cat $i), \"client_id\": \"text2video\"}"
  echo "Submitted: $i"
done
```

## 最终拼接

使用 FFmpeg 将多个分镜视频拼接：

```bash
# 创建文件列表
echo "file 'shot_01.mp4'" > concat.txt
echo "file 'shot_02.mp4'" >> concat.txt
echo "file 'shot_03.mp4'" >> concat.txt

# 拼接
ffmpeg -f concat -safe 0 -i concat.txt -c copy final_output.mp4
```
