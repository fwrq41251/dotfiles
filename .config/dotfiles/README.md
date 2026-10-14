# Dotfiles

使用 bare Git 仓库 `~/.cfg` 管理配置，工作目录为 `$HOME`。主要配置包括 Zsh、Powerlevel10k、Git、Neovim、Doom Emacs、Zed、WezTerm、tmux、Zellij、btop、Hammerspoon 和 IdeaVim。

## 恢复到新机器

先准备 Git 和 Homebrew，将本仓库的 `.config/dotfiles/bootstrap.sh` 下载到临时目录并阅读，再运行：

```sh
bash /path/to/bootstrap.sh
brew bundle --file="$HOME/.config/dotfiles/Brewfile"
bash "$HOME/.config/dotfiles/bootstrap.sh" --dependencies
```

脚本会 clone 到 `~/.cfg` 并恢复配置。它会检查所有目标文件，遇到不同内容、目录或符号链接冲突时停止；请先手动备份列出的文件后重试。已有依赖目录不会被更新或覆盖。

安装脚本固定 Doom Emacs、Oh My Zsh、Powerlevel10k 和 TPM 的提交版本；这些安装目录不纳入 dotfiles。需要升级时，更新脚本中的版本，并在现有依赖目录中单独升级。

依赖安装完成后运行：

```sh
"$HOME/.config/emacs/bin/doom" install
"$HOME/.config/emacs/bin/doom" sync
```

Doom 安装过程中保留本仓库提供的 `.config/doom` 配置。首次启动 Neovim 时，Lazy 会安装插件；`lazy-lock.json` 用于固定插件版本，可在 Lazy 界面执行 Restore 恢复锁定版本。启动 tmux 后按前缀键（反引号）再按 `I`，安装 TPM 声明的插件。

Brewfile 只列出配置直接使用的工具和字体，不是整台机器的软件快照。WezTerm 和 Zed task 使用的 Ghostty 需单独安装；Hammerspoon 需授予辅助功能权限。Flutter、Bun、Coursier、Antigravity 等按需单独安装，在本地 Shell 文件中添加路径。mise 的项目版本通过各项目的 `mise.toml` 管理。

## 本地身份与机器设置

`.gitconfig` 不保存姓名和邮箱，通过 `~/.gitconfig.local` 加载本机身份：

```sh
git config --file "$HOME/.gitconfig.local" user.name 'Your Name'
git config --file "$HOME/.gitconfig.local" user.email 'you@example.com'
```

机器专属 Shell 配置放在 `.zshrc.local`；登录 Shell 集成放在 `.zprofile.local`，非交互 Shell 也需要的环境变量放在 `.zshenv.local`。这些文件被忽略。可从 `.config/dotfiles/zshrc.local.example` 复制模板。现有机器的身份及本地设置在整理时已保留。

## 日常维护

仓库使用白名单：默认忽略整个主目录，只开放 `.gitignore` 中列出的配置。Neovim 的 `lua/**/*.lua`、Doom 顶层 `*.el` 和 Hammerspoon 顶层 `*.lua` 等新增配置会自动成为候选文件；无需逐个修改忽略规则。`*.local.*`、缓存、备份、安装目录和未开放的应用目录继续忽略。

Git 会显示白名单范围内的所有未跟踪文件。允许被发现不代表自动提交，仍需暂存并检查内容：

```sh
config status
config add -- .zshrc .config/nvim/lua
config diff --cached
config commit -m 'Update configuration'
config push origin main
```

也可以用 `config add -A` 批量暂存白名单内的新增文件及所有已跟踪文件的改动和删除，提交前检查 `config diff --cached`。白名单按路径筛选，不能判断配置内容是否含凭证；不要使用 `config add -f` 绕过规则。

新增一种应用时，先在根 `.gitignore` 开放目录，再明确开放配置文件。例如纳入一个应用的 `config.toml`：

```gitignore
!/.config/my-app/
/.config/my-app/*
!/.config/my-app/config.toml
```

将以上规则放在 `.config` 白名单区域、最终的本地文件排除规则之前。仅开放必需文件，避免开放整个应用目录。

检查某个文件为何被忽略：

```sh
config check-ignore -v -- .config/my-app/config.toml
```

查看包括隐藏目录中的未跟踪文件时，要显式指定目录：

```sh
config status --ignored --untracked-files=all -- .config/my-app
```

Neovim 插件锁文件应保留。忽略规则不会自动停止跟踪已纳入仓库的文件，也不会清理历史。
