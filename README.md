# Vim and tmux configuration

这个仓库保存了常用的 Vim、tmux 以及 Zsh 配置文件。

## 包含文件

- `vimrc`: Vim 配置文件
- `vim/`: Vim 插件及相关配置
- `tmux.conf`: tmux 配置文件
- `p10k.zsh`: Powerlevel10k Zsh 主题配置
- `zshrc`: 共享的 Zsh 启动入口
- `zprofile`: Homebrew shell 环境初始化
- `zshrc.local.example`: 机器私有配置示例
- `setup-mac.sh`: 新 Mac 恢复脚本
- `com.googlecode.iterm2.plist`: iTerm2 偏好设置导出

---

## Vim 快捷键与特性

当前配置使用 `desert` 主题，并启用了 **背景透明**，适合在支持透明度的终端中使用。

### 常用快捷键

| 功能 | 快捷键 | 说明 |
| --- | --- | --- |
| 自动缩进全文 | `F12` | 执行 `gg=G` |
| 删除所有空行 | `F2` | 清理代码中的多余空行 |
| 垂直对比 | `Ctrl-F2` | 开启垂直分屏对比 |
| 新建标签页 | `Alt-F2` / `F3` | 快速开启新 tab |
| 编译并运行 | `F5` | 支持 C, C++, Java, Shell, Python |
| GDB 调试 | `F8` | 自动带 `-g` 编译并启动 GDB |
| NERDTree | `F7` / `<leader>n` | 开启/切换文件浏览器 |
| 切换行号模式 | `Ctrl-n` | 在相对行号与绝对行号间切换 |
| 保存并 Make | `<leader><Space>` | C/C++ 专用，保存并执行 `make` |

### 核心特性

- **自动文件头**: 新建 `.sh`, `.c`, `.cpp`, `.java` 等文件时自动生成作者信息和日期。
- **括号自动补全**: 输入 `(`, `[`, `{` 自动补全另一半并定位光标。
- **剪贴板共享**: 自动根据系统（macOS/Linux）集成系统剪贴板。
- **搜索优化**: 启用高亮搜索、递进搜索及匹配括号高亮。
- **鼠标支持**: 启用了 `set mouse=a`，支持滚动和点击。

---

## tmux 快捷键速查

当前 `tmux.conf` 将前缀键改成了 `Ctrl-a`，默认的 `Ctrl-b` 已禁用。

### 面板与窗口管理

| 功能 | 快捷键 | 说明 |
| --- | --- | --- |
| 重新加载配置 | `Ctrl-a r` | 重新读取 `~/.tmux.conf` |
| 发送前缀给程序 | `Ctrl-a Ctrl-a` | 将字面量 `Ctrl-a` 发送给当前 pane 内程序 |
| 左右分屏 | `Ctrl-a \|` / `Ctrl-a v` | `v` 会继承当前工作目录 |
| 上下分屏 | `Ctrl-a -` / `Ctrl-a n` | `n` 会继承当前工作目录 |
| 切换 pane | `Ctrl-a h/j/k/l` | Vim 风格方向键 |
| 切换 window | `Ctrl-a Ctrl-h/l` | 上一个/下一个 window |
| 调整 pane 大小 | `Ctrl-a H/J/K/L` | 每次调整 5 格 |

### 复制与粘贴

配置启用了 `vi` 风格复制模式：

1. 按 `Ctrl-a [` 进入 copy-mode。
2. 用 `v` 开始选择文本，`y` 复制选区并退出。
3. **粘贴 tmux buffer**: `Ctrl-a p`。
4. **复制到系统剪贴板**: `Ctrl-a Ctrl-c` (macOS `pbcopy` / Linux `xclip`)。
5. **从系统剪贴板粘贴**: `Ctrl-a Ctrl-v`。

---

## Zsh 配置

集成了 `p10k.zsh` (Powerlevel10k)，提供美观且功能丰富的终端提示符。

- **图标支持**: 需要安装 [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)。
- **即时响应**: 采用 Instant Prompt 技术，终端启动更迅速。
- **Git 集成**: 实时显示分支、待提交项、冲突等状态。

---

## 在新 Mac 上恢复环境

这套仓库现在可以恢复以下共享环境：

- Vim 配置与 `~/.vim` 插件目录
- tmux 配置
- Oh My Zsh + Powerlevel10k + 常用 Zsh 插件
- iTerm2 偏好设置
- Maple Mono Nerd Font CN 字体
- Monaco Nerd Font v0.2.1 的四个 release zip 字体

### 一键恢复

在新机器上克隆仓库后运行：

```bash
cd ~/code/vim
./scripts/setup-mac.sh
```

如果想先看脚本会做什么：

```bash
cd ~/code/vim
DRY_RUN=1 ./scripts/setup-mac.sh
```

### 脚本会做什么

- 检查 Xcode Command Line Tools
- 安装 Homebrew
- 安装 `tmux`、`python`、`iTerm2`、`font-maple-mono-nf-cn`
- 从 `https://github.com/thep0y/monaco-nerd-font/releases/tag/v0.2.1` 下载四个 Monaco 字体 zip，并解压到 `~/Library/Fonts`
- 安装 Oh My Zsh
- 安装 `powerlevel10k`、`zsh-autosuggestions`、`zsh-completions`、`zsh-syntax-highlighting`
- 复制 `~/.vimrc`、`~/.vim`、`~/.tmux.conf`、`~/.p10k.zsh`、`~/.zshrc`、`~/.zprofile`
- 如果 `~/.zshrc.local` 不存在，则从 `zshrc.local.example` 复制一份
- 导入 `com.googlecode.iterm2.plist`

### 仍需手动处理的部分

- 私有 AK/SK、token、PATH 覆盖、机器专属 alias：写到 `~/.zshrc.local`
- macOS 隐私授权：例如辅助功能、自动化、输入监控
- 语言工具链：例如 Java、Go、Node.js、Docker 等，按项目需要再安装
- `gdb`：macOS 上通常还需要额外 code signing，脚本不会自动处理
- 如果你后续修改了仓库里的配置，想同步到家目录，请重新运行一次脚本

### 恢复后检查

- 重启 iTerm2，确认 `Ghostty DropDown` 等 profile 已恢复
- 确认 iTerm2 能选择 `Maple Mono NF CN` 和 `MonacoLigaturizedNF` 字体
- 新开一个 shell，确认 Powerlevel10k 和 Zsh 插件正常工作
