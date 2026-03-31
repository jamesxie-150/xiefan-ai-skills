# AnimateDiff 参数说明

## 核心参数

| 参数 | 推荐值 | 范围 | 说明 |
|------|--------|------|------|
| `steps` | 20 | 15-30 | 采样步数，越高质量越好但越慢 |
| `cfg_scale` | 7.0 | 5-12 | CFG 引导强度，过高会过饱和 |
| `sampler_name` | `euler_ancestral` | — | 推荐采样器，出图快且质量好 |
| `scheduler` | `normal` | — | 调度器 |
| `width` | 512 | 256-768 | 宽度，必须是 8 的倍数 |
| `height` | 512 | 256-768 | 高度，必须是 8 的倍数 |
| `seed` | -1 (random) | — | 随机种子，-1 为随机 |
| `denoise` | 1.0 | 0-1 | 去噪强度，文生动画固定 1.0 |

## AnimateDiff 专属参数

| 参数 | 推荐值 | 说明 |
|------|--------|------|
| `video_frames` | 16 | 生成帧数（16帧=2秒@8fps） |
| `motion_scale` | 1.0 | 运动幅度，0.5=微动，1.5=大幅运动 |
| `fps` | 8 | 输出帧率 |
| `beta_schedule` | `linear` | 噪声调度 |
| `model` | `mm_sd_v15_v2.ckpt` | AnimateDiff 运动模型 |

## 推荐模型组合

### 沙雕动漫风格

| 组件 | 推荐模型 | 备选 |
|------|---------|------|
| Checkpoint | `counterfeitV30_v30.safetensors` | `anythingV5_v5.safetensors` |
| Motion Model | `mm_sd_v15_v2.ckpt` | `mm_sd_v14.ckpt` |
| VAE | `vae-ft-mse-840000` | 模型自带 |

### 模型放置路径

```
ComfyUI/
├── models/
│   ├── checkpoints/          ← Checkpoint 模型
│   ├── animatediff_models/   ← AnimateDiff 运动模型
│   └── vae/                  ← VAE 模型
```

## 分辨率建议

| 用途 | 分辨率 | 显存需求 |
|------|--------|---------|
| 快速预览 | 256×256 | ~4GB |
| 标准质量 | 512×512 | ~8GB |
| 高质量 | 512×768 | ~10GB |
| 最高质量 | 768×768 | ~12GB+ |

## 运动强度参考

| motion_scale | 效果 | 适用场景 |
|-------------|------|---------|
| 0.5 | 微微晃动 | 静态表情、说话 |
| 0.8 | 轻微运动 | 点头、转头 |
| 1.0 | 标准运动 | 走路、手势 |
| 1.2 | 较大运动 | 跑步、夸张反应 |
| 1.5 | 剧烈运动 | 大幅度动作、搞笑动作 |
