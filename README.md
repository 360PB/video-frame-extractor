# 视频自动抽帧工具

这是一个基于 Flask 的视频自动抽帧工具，支持在 Windows 11 下运行。用户可以通过简单的交互页面上传视频，并自动处理抽帧。

## 功能
- 支持上传视频文件
- 使用 FFmpeg 实现视频抽帧，每隔 30 帧抽取一帧
- 自动生成处理后的视频并提供下载

## 安装与运行

### 环境要求
- Windows 11
- Python 3.7+
- FFmpeg 已安装并配置到系统 PATH

### 安装步骤
1. 克隆项目到本地：
   ```bash
   git clone https://github.com/your-username/video-frame-extractor.git
   cd video-frame-extractor
   

1. 安装依赖：

   ```
   pip install -r requirements.txt
   ```

2. 运行程序：

   ```
   python app.py
   ```

## 使用方法

1. 打开窗口后上传视频文件。
2. 点击“开始处理”按钮，等待处理完成。
3. 下载处理后的视频文件。

## 开源协议

本项目基于 MIT 协议开源，欢迎自由使用与修改。
