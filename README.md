# 视频抽帧工具 (Video Frame Extractor)

## 功能描述

这是一个简单易用的视频抽帧工具，支持：

- 灵活设置抽帧间隔
- GPU 加速处理
- 支持多种视频格式
- 实时处理进度显示



## 系统要求

- Python 3.7+
- Windows 10/11
- NVIDIA GPU（可选，用于GPU加速）

# **项目结构**

```
video-frame-extractor/
│
├── app.py              # 主程序代码
└── tools/             # 工具目录
    └── ffmpeg-7.1/    # FFmpeg 文件夹
        └── bin/       # FFmpeg 可执行文件目录
            ├── ffmpeg.exe
            └── ffprobe.exe
```

## 运行方法

### 方法一：直接运行

```bash
# 克隆项目
git clone https://github.com/yourusername/video-frame-extractor.git
cd video-frame-extractor

# 运行程序
python app.py
```

### 方法二：创建虚拟环境（推荐）

```bash
# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# 运行程序
python app.py
```

## 使用说明

1. 点击 "选择视频并开始处理" 按钮
2. 选择需要抽帧的视频文件
3. 设置抽帧间隔（默认30）
4. 可选择是否使用 GPU 加速
5. 等待处理完成

## 常见问题

- 确保 FFmpeg 在系统 PATH 中
- GPU 加速需要 NVIDIA 显卡支持
- 视频文件路径不要包含中文

## 技术细节

- GUI 框架：Tkinter
- 视频处理：FFmpeg
- 编程语言：Python

## 性能优化

- 支持 GPU 硬件加速
- 多线程处理
- 实时进度显示

## 许可证

[Apache-2.0 license](https://github.com/360PB/video-frame-extractor#)

## 版本

v1.0 - 2024年12月25日

## 贡献

欢迎提交 Issues 和 Pull Requests！
