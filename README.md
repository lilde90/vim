# Vim and tmux configuration

这个仓库保存了常用的 Vim 和 tmux 配置文件：

- `vimrc`
- `tmux.conf`
- `tmux-panes`

## tmux 快捷键速查

当前 `tmux.conf` 将前缀键改成了 `Ctrl-a`，默认的 `Ctrl-b` 已禁用。

### 常用操作

| 功能 | 快捷键 | 说明 |
| --- | --- | --- |
| 重新加载配置 | `Ctrl-a r` | 重新读取 `~/.tmux.conf` |
| 发送前缀给程序 | `Ctrl-a Ctrl-a` | 将字面量 `Ctrl-a` 发送给当前 pane 内程序 |
| 左右分屏 | `Ctrl-a \|` | 基础分屏 |
| 上下分屏 | `Ctrl-a -` | 基础分屏 |
| 左右分屏 | `Ctrl-a v` | 继承当前 pane 工作目录 |
| 上下分屏 | `Ctrl-a n` | 继承当前 pane 工作目录 |
| 切到左侧 pane | `Ctrl-a h` | Vim 风格方向键 |
| 切到下方 pane | `Ctrl-a j` | Vim 风格方向键 |
| 切到上方 pane | `Ctrl-a k` | Vim 风格方向键 |
| 切到右侧 pane | `Ctrl-a l` | Vim 风格方向键 |
| 上一个 window | `Ctrl-a Ctrl-h` | 可按住连续切换 |
| 下一个 window | `Ctrl-a Ctrl-l` | 可按住连续切换 |
| 向左缩 pane | `Ctrl-a H` | 每次调整 5 格 |
| 向下扩 pane | `Ctrl-a J` | 每次调整 5 格 |
| 向上缩 pane | `Ctrl-a K` | 每次调整 5 格 |
| 向右扩 pane | `Ctrl-a L` | 每次调整 5 格 |
| 粘贴 tmux buffer | `Ctrl-a p` | 粘贴 tmux 内部缓冲区内容 |
| tmux buffer 复制到系统剪贴板 | `Ctrl-a Ctrl-c` | 使用 macOS `pbcopy` |
| 从系统剪贴板粘贴到 pane | `Ctrl-a Ctrl-v` | 使用 macOS `pbpaste` |

## pane 内复制与粘贴

配置启用了 `vi` 风格复制模式，因此 pane 内复制推荐使用下面的流程。

### 复制到 tmux buffer

1. 按 `Ctrl-a [` 进入 copy-mode。
2. 用 `h` `j` `k` `l` 或其他 vi 风格移动键移动光标。
3. 按 `v` 开始选择文本。
4. 移动光标扩展选区。
5. 按 `y` 复制选区，并退出 copy-mode。

这时内容进入 tmux 自己的 buffer。

### 粘贴 tmux buffer

在目标 pane 中按 `Ctrl-a p`，将 tmux buffer 的内容直接粘贴进去。

### 复制到 macOS 系统剪贴板

如果希望把刚复制的内容交给系统剪贴板：

1. 先按上面的步骤将内容复制到 tmux buffer。
2. 再按 `Ctrl-a Ctrl-c`。

这样 tmux 当前 buffer 会通过 `pbcopy` 写入 macOS 系统剪贴板。

### 从 macOS 系统剪贴板粘贴到 pane

按 `Ctrl-a Ctrl-v`。

这个绑定会通过 `pbpaste` 读取系统剪贴板，并将内容粘贴到当前 pane。

## 两种粘贴的区别

- `Ctrl-a p` 粘贴的是 tmux buffer。
- `Ctrl-a Ctrl-v` 粘贴的是 macOS 系统剪贴板。
- 如果只是 pane 之间复制粘贴，通常用 `Ctrl-a [` -> `v` -> `y` -> `Ctrl-a p` 就够了。
- 如果要和其他 macOS 应用共享复制内容，再额外执行 `Ctrl-a Ctrl-c`。
