import os
import subprocess
from tkinter import Tk, Text, filedialog, messagebox
from tkinter import ttk
import imageio_ffmpeg as ffmpeg

# 设置自定义样式
def setup_styles(root):
    style = ttk.Style(root)
    style.theme_use('alt')
    style.configure('TFrame', background='#f0f0f0')
    style.configure('TLabel', font=('Helvetica', 12), foreground='#333333')
    style.configure('TButton', font=('Helvetica', 12), padding=10, relief='flat', borderwidth=1)
    style.map('TButton', background=[('active', '!disabled', '#dddddd')], foreground=[('active', '!disabled', '#333333')])
    style.configure('TEntry', font=('Helvetica', 12), padding=5)
    return style

# 提取帧函数
def extract_frames_with_builtin_ffmpeg(input_file, frame_interval, status_text):
    input_dir = os.path.dirname(input_file)
    input_name = os.path.basename(input_file)
    output_file = os.path.join(input_dir, f"processed_{input_name}")

    ffmpeg_path = ffmpeg.get_ffmpeg_exe()

    command = [
        ffmpeg_path, "-i", input_file,
        "-vf", f"select='not(eq(mod(n,{frame_interval}),0))',setpts=N/FRAME_RATE/TB",
        "-af", f"aselect='not(eq(mod(n,{frame_interval}),0))',asetpts=N/SR/TB",
        output_file
    ]

    status_text.insert('end', f"正在处理视频：{input_file}\n")
    status_text.insert('end', f"输出文件将保存到：{output_file}\n")
    status_text.update_idletasks()

    try:
        subprocess.run(command, check=True)
        messagebox.showinfo("处理完成", f"视频处理完成！\n输出文件路径：\n{output_file}")
        os.startfile(input_dir)
    except subprocess.CalledProcessError as e:
        messagebox.showerror("处理失败", f"处理失败：{e}")
    except Exception as e:
        messagebox.showerror("未知错误", f"发生未知错误：{e}")

# 开始处理函数
def start_processing(frame_interval_entry, status_text):
    input_file = filedialog.askopenfilename(
        title="选择视频文件",
        filetypes=[("视频文件", "*.mp4 *.avi *.mov *.mkv"), ("所有文件", "*.*")],
        initialdir=os.path.expanduser("~")
    )
    if not input_file:
        messagebox.showwarning("未选择文件", "您未选择任何文件！")
        return

    try:
        frame_interval = int(frame_interval_entry.get())
        if frame_interval < 1:
            raise ValueError("抽帧间隔必须大于0")
    except ValueError as e:
        messagebox.showerror("输入错误", f"抽帧间隔输入错误：{e}")
        return

    extract_frames_with_builtin_ffmpeg(input_file, frame_interval, status_text)
    status_text.insert('end', "处理完成！\n")

# 主函数
def main():
    root = Tk()
    root.title("视频抽帧工具")
    root.geometry("600x400")
    root.resizable(False, False)

    # 设置自定义样式
    setup_styles(root)

    # 主框架
    main_frame = ttk.Frame(root, padding=20)
    main_frame.pack(fill='both', expand=True)

    # 应用标题
    app_label = ttk.Label(main_frame, text="视频抽帧工具", font=('Helvetica', 24))
    app_label.pack(pady=10)

    # 抽帧间隔输入框
    frame_interval_label = ttk.Label(main_frame, text="抽帧间隔：")
    frame_interval_label.pack(pady=5)

    frame_interval_entry = ttk.Entry(main_frame)
    frame_interval_entry.pack(pady=5)

    # 开始处理按钮
    run_button = ttk.Button(main_frame, text="选择视频并开始处理", command=lambda: start_processing(frame_interval_entry, status_text))
    run_button.pack(pady=20)

    # 状态信息框
    status_text = Text(main_frame, height=10, wrap='word', state='normal', bg='#f9f9f9', fg='#333333', font=('Helvetica', 10))
    status_text.pack(fill='both', expand=True, pady=10)

    root.mainloop()

if __name__ == "__main__":
    main()
