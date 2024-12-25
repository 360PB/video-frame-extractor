import os
from tkinter import Tk, filedialog, simpledialog, messagebox
import imageio_ffmpeg as ffmpeg
import subprocess

def extract_frames_with_builtin_ffmpeg(input_file, frame_interval):
    """
    使用 imageio_ffmpeg 的内置 FFmpeg 处理视频抽帧。
    :param input_file: 输入视频文件路径
    :param frame_interval: 抽帧间隔（每隔多少帧保留一帧）
    """
    # 获取输入文件所在目录和文件名
    input_dir = os.path.dirname(input_file)
    input_name = os.path.basename(input_file)
    output_file = os.path.join(input_dir, f"processed_{input_name}")

    # 获取 imageio_ffmpeg 提供的 FFmpeg 可执行文件路径
    ffmpeg_path = ffmpeg.get_ffmpeg_exe()

    # 构造 FFmpeg 命令
    command = [
        ffmpeg_path, "-i", input_file,
        "-vf", f"select='not(eq(mod(n,{frame_interval}),0)+eq(mod(n,{frame_interval}),1))',setpts=N/FRAME_RATE/TB",
        "-af", f"aselect='not(eq(mod(n,{frame_interval}),0)+eq(mod(n,{frame_interval}),1))',asetpts=N/SR/TB",
        output_file
    ]

    print(f"正在处理视频：{input_file}")
    print(f"输出文件将保存到：{output_file}")
    try:
        # 执行 FFmpeg 命令
        subprocess.run(command, check=True)
        # 显示处理完成的消息
        messagebox.showinfo("处理完成", f"视频处理完成！\n输出文件路径：\n{output_file}")
        # 自动打开输出文件所在的文件夹
        os.startfile(input_dir)
    except subprocess.CalledProcessError as e:
        # 如果处理失败，显示错误消息
        messagebox.showerror("处理失败", f"处理失败：{e}")

def main():
    # 创建 Tkinter 主窗口（隐藏主窗口）
    root = Tk()
    root.withdraw()

    # 弹出文件选择对话框
    input_file = filedialog.askopenfilename(
        title="选择视频文件",
        filetypes=[("视频文件", "*.mp4 *.avi *.mov *.mkv"), ("所有文件", "*.*")]
    )
    if not input_file:
        messagebox.showwarning("未选择文件", "您未选择任何文件！程序将退出。")
        return

    # 弹出输入对话框，获取抽帧间隔
    try:
        frame_interval = simpledialog.askinteger(
            "输入抽帧间隔",
            "请输入抽帧间隔（例如 30 表示每隔 30 帧保留 1 帧）：",
            minvalue=1
        )
        if frame_interval is None:
            messagebox.showwarning("未输入间隔", "您未输入抽帧间隔！程序将退出。")
            return
    except ValueError:
        messagebox.showerror("输入错误", "抽帧间隔必须是正整数！程序将退出。")
        return

    # 调用处理函数
    extract_frames_with_builtin_ffmpeg(input_file, frame_interval)

if __name__ == "__main__":
    main()
