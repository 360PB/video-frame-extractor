import os
import subprocess
from tkinter import Tk, Text, filedialog, messagebox, BooleanVar, Checkbutton
from tkinter import ttk
import threading
import json

FFMPEG_PATH = "ffmpeg"  # 直接使用环境变量中的ffmpeg
FFPROBE_PATH = "ffprobe"  # 直接使用环境变量中的ffprobe

def log_message(status_text, message):
    """统一的日志输出函数"""
    print(message)  # 控制台输出
    status_text.insert('end', f"{message}\n")
    status_text.see('end')
    status_text.update_idletasks()

def get_video_info(input_file, status_text):
    """获取视频信息"""
    try:
        probe_cmd = [
            FFPROBE_PATH,
            "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            "-show_streams",
            input_file
        ]
        
        log_message(status_text, f"执行命令: {' '.join(probe_cmd)}")
        result = subprocess.check_output(probe_cmd, universal_newlines=True)
        
        # 解析JSON输出
        info = json.loads(result)
        video_streams = [s for s in info['streams'] if s['codec_type'] == 'video']
        if not video_streams:
            raise ValueError("没有找到视频流")
        
        video_stream = video_streams[0]
        
        # 尝试获取总帧数
        nb_frames = video_stream.get('nb_frames', '0')
        if nb_frames != '0':
            nb_frames = int(nb_frames)
        else:
            # 如果没有直接的帧数信息，从帧率和时长计算
            fps_parts = video_stream['r_frame_rate'].split('/')
            fps = float(fps_parts[0]) / float(fps_parts[1])
            duration = float(info['format']['duration'])
            nb_frames = int(fps * duration)
            
        log_message(status_text, f"视频信息:")
        log_message(status_text, f"- 分辨率: {video_stream.get('width')}x{video_stream.get('height')}")
        log_message(status_text, f"- 帧率: {video_stream['r_frame_rate']}")
        log_message(status_text, f"- 时长: {info['format']['duration']}秒")
        log_message(status_text, f"- 总帧数: {nb_frames}")
        
        return nb_frames
            
    except Exception as e:
        log_message(status_text, f"获取视频信息失败: {str(e)}")
    return 0

def check_gpu_support(status_text):
    """检查GPU支持情况"""
    try:
        cmd = [FFMPEG_PATH, "-hide_banner", "-hwaccels"]
        result = subprocess.check_output(cmd, universal_newlines=True)
        log_message(status_text, f"支持的硬件加速方式: \n{result}")
        return 'cuda' in result.lower()
    except Exception as e:
        log_message(status_text, f"检查GPU支持失败: {str(e)}")
        return False

def extract_frames(input_file, frame_interval, status_text, use_gpu):
    input_dir = os.path.dirname(input_file)
    input_name = os.path.basename(input_file)
    output_file = os.path.join(input_dir, f"processed_{input_name}")

    # 检查GPU支持
    if use_gpu:
        gpu_supported = check_gpu_support(status_text)
        if not gpu_supported:
            log_message(status_text, "警告：GPU加速不可用，将使用CPU处理")
            use_gpu = False

    # 获取视频总帧数
    total_frames = get_video_info(input_file, status_text)

    # 构建FFmpeg命令
    command = [FFMPEG_PATH]
    
    if use_gpu:
        command.extend(['-hwaccel', 'cuda', '-hwaccel_output_format', 'cuda'])
        log_message(status_text, "已启用GPU加速")
    
    command.extend([
        "-i", input_file,
        "-vf", f"select='not(eq(mod(n,{frame_interval}),0))',setpts=N/FRAME_RATE/TB",
        "-af", f"aselect='not(eq(mod(n,{frame_interval}),0))',asetpts=N/SR/TB",
        "-progress", "pipe:1",
        "-y",  # 自动覆盖输出文件
        output_file
    ])

    log_message(status_text, f"执行命令: {' '.join(command)}")

    try:
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            bufsize=1
        )

        while True:
            line = process.stdout.readline()
            if not line and process.poll() is not None:
                break

            if line.startswith('frame='):
                try:
                    current_frame = int(line.split('=')[1].strip())
                    if total_frames > 0:
                        progress = (current_frame / total_frames) * 100
                        log_message(status_text, f"处理进度: {progress:.1f}% (帧: {current_frame}/{total_frames})")
                except ValueError as e:
                    log_message(status_text, f"处理帧数据出错: {str(e)}")

        # 检查处理结果
        if process.returncode == 0:
            log_message(status_text, "视频处理成功完成！")
            messagebox.showinfo("处理完成", f"视频处理完成！\n输出文件路径：\n{output_file}")
            os.startfile(input_dir)
        else:
            error_output = process.stderr.read()
            log_message(status_text, f"处理失败，错误信息：\n{error_output}")
            raise subprocess.CalledProcessError(process.returncode, command)

    except Exception as e:
        log_message(status_text, f"处理过程中发生错误: {str(e)}")
        messagebox.showerror("错误", f"处理失败：{str(e)}")

def start_processing(frame_interval_entry, status_text, use_gpu_var, run_button):
    """开始处理函数"""
    try:
        # 禁用按钮，防止重复点击
        run_button.configure(state='disabled')
        
        input_file = filedialog.askopenfilename(
            title="选择视频文件",
            filetypes=[("视频文件", "*.mp4 *.avi *.mov *.mkv"), ("所有文件", "*.*")],
            initialdir=os.path.expanduser("~")
        )
        
        if not input_file:
            log_message(status_text, "未选择文件")
            run_button.configure(state='normal')
            return

        try:
            frame_interval = int(frame_interval_entry.get()) if frame_interval_entry.get() else 30
            if frame_interval < 1:
                raise ValueError("抽帧间隔必须大于0")
        except ValueError as e:
            log_message(status_text, f"输入错误：{str(e)}")
            messagebox.showerror("输入错误", f"抽帧间隔输入错误：{e}")
            run_button.configure(state='normal')
            return

        use_gpu = use_gpu_var.get()
        
        # 使用线程处理视频
        def process_thread():
            try:
                extract_frames(input_file, frame_interval, status_text, use_gpu)
            finally:
                # 确保按钮最终被重新启用
                run_button.configure(state='normal')
        
        threading.Thread(target=process_thread, daemon=True).start()

    except Exception as e:
        log_message(status_text, f"启动处理时发生错误: {str(e)}")
        run_button.configure(state='normal')

def main():
    root = Tk()
    root.title("视频抽帧工具")
    root.geometry("800x600")
    root.resizable(True, True)

    # 设置自定义样式
    style = ttk.Style(root)
    style.theme_use('alt')
    style.configure('TFrame', background='#f0f0f0')
    style.configure('TLabel', font=('Helvetica', 12), foreground='#333333')
    style.configure('TButton', font=('Helvetica', 12), padding=10)
    style.configure('TEntry', font=('Helvetica', 12), padding=5)

    # 主框架
    main_frame = ttk.Frame(root, padding=20)
    main_frame.pack(fill='both', expand=True)

    # 抽帧间隔输入框
    frame_interval_label = ttk.Label(main_frame, text="抽帧间隔（默认30）：", background='#f0f0f0')
    frame_interval_label.pack(pady=5)

    frame_interval_entry = ttk.Entry(main_frame)
    frame_interval_entry.insert(0, "30")
    frame_interval_entry.pack(pady=5)

    # GPU加速选项
    use_gpu_var = BooleanVar()
    gpu_checkbutton = Checkbutton(main_frame, text="使用GPU加速", variable=use_gpu_var, background='#f0f0f0')
    gpu_checkbutton.pack(pady=5)

    # 开始处理按钮
    run_button = ttk.Button(main_frame, text="选择视频并开始处理")
    run_button.configure(command=lambda: start_processing(frame_interval_entry, status_text, use_gpu_var, run_button))
    run_button.pack(pady=20)

    # 状态信息框
    status_text = Text(main_frame, height=20, wrap='word', state='normal', font=('Courier New', 10))
    status_text.pack(fill='both', expand=True, pady=10)

    # 添加滚动条
    scrollbar = ttk.Scrollbar(main_frame, orient='vertical', command=status_text.yview)
    scrollbar.pack(side='right', fill='y')
    status_text.configure(yscrollcommand=scrollbar.set)

    root.mainloop()

if __name__ == "__main__":
    main()
