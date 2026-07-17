# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"


# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 1

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	dnf
	git 
	vscode 
	yarn 
	tmux 
	systemd 
	sudo 
	sdk 
	scala 
	sbt 
	rust 
	python 
	pip 
	pyenv
  conda
	nvm 
	npm 
	node 
	man 
	kubectx 
	kubectl 
	httpie 
	history 
	helm 
	emoji 
	dotenv 
	docker 
	docker-compose 
	cp 
	aliases
	zsh-syntax-highlighting 
	zsh-autosuggestions
	zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias projects="cd $HOME/Projects"
alias myubuntu="cd $HOME/Projects/ubuntu-bootstrap"
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --git'
alias lsa='eza -lha --icons --git'
alias lsda="lsd -la"
alias lsdar="lsd -laR"
alias df='df -h'
alias chmox='chmod +x'
alias temp='cd $(mktemp -d)'
alias gtop='docker run --rm -it --name gtop --net="host" --pid="host" aksakalli/gtop'
alias wezterm='flatpak run org.wezfurlong.wezterm'

alias sudonvim='sudo -E XDG_CONFIG_HOME=$HOME/.config XDG_DATA_HOME=$HOME/.local/share XDG_CACHE_HOME=$HOME/.cache nvim'
alias droidcam='XDG_RUNTIME_DIR="/run/user/$(id -u)" scrcpy --video-source=camera --camera-size=1920x1080 --v4l2-sink=/dev/video0 --no-playback'


alias update="$HOME/system-update.sh"

export PATH="$PATH:$HOME/.local/bin"

# >>> go install directory >>>
export PATH="$PATH:$HOME/.go/bin"
# <<< go install directory <<<

# >>> minikube install directory >>>
export PATH="$PATH:$HOME/.apps/minikube/bin"
# <<< minikube install directory <<<

# >>> kubectl install directory >>>
export PATH="$PATH:$HOME/.apps/kubectl/bin"
# <<< kubectl install directory <<<

# >>> nvim install directory >>>
export PATH="$PATH:$HOME/.apps/neovim/bin"
# <<< nvim install directory <<<

# >>> lazygit install directory >>>
export PATH="$PATH:$HOME/.apps/lazygit/bin"
# <<< lazygit install directory <<<

# >>> helm install directory >>>
export PATH="$PATH:$HOME/.apps/helm/bin"
# <<< helm install directory <<<

# >>> kind install directory >>>
export PATH="$PATH:$HOME/.apps/kind/bin"
# <<< kind install directory <<<

# >>> kind install directory >>>
export PATH="$PATH:$HOME/.apps/zellij/bin"
# <<< kind install directory <<<

# >>> kustomize install directory >>>
export PATH="$PATH:$HOME/.apps/kustomize/bin"
# <<< kustomize install directory <<<

# >>> neovide install directory >>>
export PATH="$PATH:$HOME/.apps/neovide/bin"
# <<< neovide install directory <<<

# >>> xplr install directory >>>
export PATH="$PATH:$HOME/.apps/xplr/bin"
# <<< xplr install directory <<<

# >>> xplr install directory >>>
export PATH="$PATH:$HOME/.apps/jujutsu/bin"
# <<< xplr install directory <<<

# >>> zig install directory >>>
export PATH="$PATH:$HOME/.apps/zig/bin"
# <<< zig install directory <<<
 
# >>> coursier install directory >>>
export PATH="$PATH:$HOME/.local/share/coursier/bin"
# <<< coursier install directory <<<

# >>> kitty install directory >>>
export PATH="$PATH:$HOME/.local/kitty.app/bin"
# <<< kitty install directory <<<

# >>> platformio install directory >>>
export PATH="$PATH:$HOME/.platformio/penv/bin"
# <<< platformio install directory <<<

# >>> kitty install directory >>>
export PATH="$PATH:$HOME/.apps/dotbot/bin"
# <<< kitty install directory <<<

# >>> yazi install directory >>>
export PATH="$PATH:$HOME/.apps/yazi/bin"
# <<< yazi install directory <<<

export PATH="$PATH:$HOME/.local/bin"

export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps"

export PATH="$PATH:$HOME/.local/share/flatpak/exports/bin"

export DENO_INSTALL="$HOME/.deno"
export PATH="$PATH:$DENO_INSTALL/bin"

# Override the default go path and specify a custom workspace
export GOPATH="$HOME/.go-workspace"
export GOCACHE="$GOPATH/pkg/cache"
export GOMODCACHE="$GOPATH/pkg/mod"
export PATH="$PATH:$GOPATH/bin"


### EZA Themes
export EZA_COLORS="
di=1;38;5;110:
fi=38;5;252:
ex=1;38;5;114:
ln=1;38;5;183:
or=1;38;5;203:
sb=38;5;221:
da=38;5;245:
ga=1;38;5;114:
gm=1;38;5;221:
gd=1;38;5;203:
gu=38;5;245
"
### 


# Not all systems have this file
[[ -d "$HOME/.nimble/bin" ]] && export PATH=$HOME/.nimble/bin:$PATH


eval "$(starship init zsh)"

# User configuration
if [[ $WITH_TMUX = true ]]; then 
    if [[ $DISPLAY ]]; then
        [[ $- != *i* ]] && return
        if [[ -z "$TMUX" ]] ;then
            ID="$( tmux ls | grep -vm1 attached | cut -d: -f1 )"
            if [[ -z "$ID" ]] ;then
                tmux new-session
            else
                tmux attach-session -t "$ID" 
            fi
        fi  
    fi
fi

if [[ -n "$KITTY_WINDOW_ID" ]]; then 
	if [[ $WITH_ZELLIJ == true ]]; then
		export ZELLIJ_AUTO_ATTACH=true
		export ZELLIJ_AUTO_EXIT=true
		eval "$(zellij setup --generate-auto-start zsh)"
	fi
fi

fpath+=${ZDOTDIR:-~}/.zsh_functions

export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

#ALL CUSTOMIZATIONS THAT IS NOT A PART OF SHARED ZSH CONFIG SHOULD DEFINED HERE 
[ -f ~/.custom.zsh ] && source ~/.custom.zsh

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# pnpm
export PNPM_HOME="/home/worxbend/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/worxbend/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<

source /home/worxbend/.config/broot/launcher/bash/br

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/worxbend/.miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/worxbend/.miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/worxbend/.miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/worxbend/.miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/home/worxbend/.miniforge3/bin/mamba';
export MAMBA_ROOT_PREFIX='/home/worxbend/.miniforge3';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -s "/usr/bin/zoxide" ] && eval "$(zoxide init zsh)"

[ -f ~/.cache/mill/download/mill-completion.sh ] && source ~/.cache/mill/download/mill-completion.sh # MILL_SOURCE_COMPLETION_LINE

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME="$HOME/.config/.android"
export ANDROID_AVD_HOME="$ANDROID_USER_HOME/avd"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
