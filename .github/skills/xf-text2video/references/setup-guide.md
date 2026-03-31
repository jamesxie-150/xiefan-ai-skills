# ComfyUI + AnimateDiff 环境配置指南

## 1. 安装 ComfyUI

```bash
# 克隆 ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# 安装依赖
pip install -r requirements.txt

# 启动 ComfyUI
python main.py --listen 0.0.0.0 --port 8188
```

## 2. 安装 AnimateDiff 节点

```bash
cd ComfyUI/custom_nodes

# AnimateDiff Evolved（推荐）
git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
cd ComfyUI-AnimateDiff-Evolved
pip install -r requirements.txt

# Video Helper Suite（视频输出）
cd ..
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
```

## 3. 下载模型

### Checkpoint 模型（二选一）

```bash
# Counterfeit V3（动漫风格，推荐）
# 下载到 ComfyUI/models/checkpoints/
wget -P models/checkpoints/ \
  "https://civitai.com/api/download/models/counterfeitV30_v30.safetensors"

# 或 Anything V5
wget -P models/checkpoints/ \
  "https://civitai.com/api/download/models/anythingV5_v5.safetensors"
```

### AnimateDiff 运动模型

```bash
# 下载到 ComfyUI/models/animatediff_models/
wget -P models/animatediff_models/ \
  "https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt"
```

## 4. 配置 ComfyUI MCP 服务器

### 方案 A: 使用 mcp-comfyui（npm）

```bash
npm install -g mcp-comfyui
```

### 方案 B: 使用 comfyui-mcp-server（Python）

```bash
pip install comfyui-mcp-server
```

### VS Code MCP 配置

在项目根目录创建 `.vscode/mcp.json`：

```json
{
  "servers": {
    "comfyui": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "mcp-comfyui", "--comfyui-url", "http://127.0.0.1:8188"]
    }
  }
}
```

## 5. 验证安装

```bash
# 检查 ComfyUI 是否运行
curl http://127.0.0.1:8188/system_stats

# 检查可用模型
curl http://127.0.0.1:8188/object_info/CheckpointLoaderSimple

# 检查 AnimateDiff 节点是否加载
curl http://127.0.0.1:8188/object_info/ADE_AnimateDiffLoaderWithContext
```

## 6. 常见问题

| 问题 | 解决方案 |
|------|---------|
| CUDA out of memory | 降低分辨率为 256×256 或减少帧数为 8 |
| AnimateDiff 节点未找到 | 重启 ComfyUI，检查 custom_nodes 目录 |
| 模型加载失败 | 确认模型路径和文件名正确 |
| MCP 连接失败 | 确认 ComfyUI 在 8188 端口监听 |
| 生成全黑视频 | 升级 AnimateDiff Evolved 版本 |
