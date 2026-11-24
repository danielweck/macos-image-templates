#!/bin/sh

tee -a "$HOME/.zshrc" >/dev/null <<EOF
export HOMEBREW_NO_ANALYTICS=1 # duplicate from base.pkr.hcl
export CLICOLOR=1
## export GPG_TTY=\$(tty)

export PI_CLIPBOARD_OSC52=1
export CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-xxx

setopt HIST_IGNORE_SPACE
setopt PROMPT_SUBST

autoload -Uz compinit && compinit
autoload -U colors && colors

if command -v wt >/dev/null 2>&1; then eval "\$(command wt config shell init zsh)"; fi
EOF

tee -a "$HOME/.zprofile" >/dev/null <<EOF
unalias lss >/dev/null 2>&1 || true
alias lss="ls -alshFGt --color=auto"

unalias psaux >/dev/null 2>&1 || true
alias psaux="ps aux --sort=-pcpu | head -n 11"

export NPM_CONFIG_CACHE="\$HOME/.cache/npmglobal/NPM_CACHE"
export NPM_CONFIG_PREFIX="\$HOME/.cache/npmglobal/NPM_PREFIX"
export PATH="\$NPM_CONFIG_PREFIX/bin:\$HOME/.local/bin:/opt/homebrew/opt/python@3.15/libexec/bin:\$PATH"
export NODE_PATH="\$NPM_CONFIG_PREFIX/lib/node_modules"

git config --global user.email daniel.weck@gmail.com
git config --global user.name "Daniel Weck"
git config --global http."https://github.com".proxy ""
git config --global uploadpack.allowFilter true
git config --global uploadpack.allowAnySHA1InWant true
git config --global core.editor vi

alias cp-cow="cp -c"
alias cp-cow-r="cp -cR"

#sudo -nv
unalias sudok >/dev/null 2>&1 || true
function sudo_k() {
    sudo "\$@"
    sudo -k
    sudo -K
}
alias sudok="sudo_k"

unalias virtiofs-remount >/dev/null 2>&1 || true
function virtiofs_remount() {
    sudo umount "/Volumes/My Shared Files"
    #sudo rm -rf ~/Desktop/virtiofs
    #sudo mkdir -p ~/Desktop/virtiofs
    #sudo chmod 700 ~/Desktop/virtiofs
    mkdir -p "/Volumes/My Shared Files" || true
    ls -alshFGt --color=auto "/Volumes/My Shared Files"
    sudo_k mount_virtiofs com.apple.virtio-fs.automount "/Volumes/My Shared Files"
    mkdir -p "/Volumes/My Shared Files" || true
    ls -alshFGt --color=auto "/Volumes/My Shared Files"
}
alias virtiofs-remount="virtiofs_remount"

unalias rsync-in >/dev/null 2>&1 || true
function rsync_in() {
    #sudo_k
    #--chown=admin:staff
    rsync -a --filter=':- .gitignore' --no-p --no-o --no-g --exclude '.git' --exclude '.bare' --exclude '.DS_Store' --exclude '.flox/' --exclude 'node_modules/' --exclude 'out/' --exclude 'dist/' --exclude 'release/' "/Volumes/My Shared Files/workspace/" "\$HOME/Desktop/_/"
}
alias rsync-in="rsync_in"

unalias rsync-out >/dev/null 2>&1 || true
function rsync_out() {
    #sudo_k
    #--chown=admin:staff
    rsync -av --filter=':- .gitignore' --no-p --no-o --no-g --exclude '.git' --exclude '.bare' --exclude '.DS_Store' --exclude '.flox/' --exclude 'node_modules/' --exclude 'out/' --exclude 'dist/' --exclude 'release/' "\$HOME/Desktop/_/" "/Volumes/My Shared Files/workspace/"
}
alias rsync-out="rsync_out"

unalias git-shallow-clone-branch >/dev/null 2>&1 || true
function git_shallow_clone_branch() {
    git clone --filter=blob:none --depth 1 --no-local --shallow-submodules "\$1" "\$2"
    git -C "\$2" status
    git -C "\$2" branch -vv
    git -C "\$2" remote -v
    git -C "\$2" log
}
alias git-shallow-clone-branch="git_shallow_clone_branch"

unalias git-shallow-clone-bare >/dev/null 2>&1 || true
function git_shallow_clone_bare() {
    git clone --filter=blob:none --depth 1 --no-local --shallow-submodules --bare "\$1" "\$2"
    git -C "\$2" status
    git -C "\$2" branch -vv
    git -C "\$2" remote -v
    git -C "\$2" log
}
alias git-shallow-clone-bare="git_shallow_clone_bare"

unalias git-in >/dev/null 2>&1 || true
function git_in() {

    dest="\$HOME/Desktop/_"
    if [[ "\$1" == ".bare" ]]; then
        dest="\$HOME/Desktop/_/\$1"
        rm -rf "\$HOME/Desktop/_/\$1"
        git clone --filter=blob:none --depth 1 --no-local --shallow-submodules --no-checkout --bare "/Volumes/My Shared Files/workspace/\$1" "\$HOME/Desktop/_/\$1"
    else
        if [[ ! -n "\$1" ]]; then
            dest="\$HOME/Desktop/_"
            git clone --filter=blob:none --depth 1 --no-local --shallow-submodules --no-checkout "/Volumes/My Shared Files/workspace" "\$HOME/Desktop/__GIT"
            rm -rf "\$HOME/Desktop/_/.git"
            mv "\$HOME/Desktop/__GIT/.git" "\$HOME/Desktop/_/"
            rm -rf "\$HOME/Desktop/__GIT"
        else
            dest="\$HOME/Desktop/_/\$1"
            git clone --filter=blob:none --depth 1 --no-local --shallow-submodules --no-checkout "/Volumes/My Shared Files/workspace/\$1" "\$HOME/Desktop/_/\$1_GIT"
            rm -rf "\$HOME/Desktop/_/\$1/.git"
            mv "\$HOME/Desktop/_/\$1_GIT/.git" "\$HOME/Desktop/_/\$1/"
            rm -rf "\$HOME/Desktop/_/\$1_GIT"
        fi
    fi

    git -C "\$dest" reset --mixed
    git -C "\$dest" status
    git -C "\$dest" branch -vv
    git -C "\$dest" remote -v
    git -C "\$dest" log
}
alias git-in="git_in"

EOF

source "$HOME/.zprofile"

mkdir -p "$NPM_CONFIG_CACHE"
mkdir -p "$NPM_CONFIG_PREFIX"

brew --version
brew update
brew upgrade

brew install jq

brew install python
which python ; whereis python ; python --version
which python3 ; whereis python3 ; python3 --version

brew install node
which node ; whereis node ; node --version
which npm ; whereis npm ; npm --version

npm config get cache ; npm config get prefix

npm install --ignore-scripts --foreground-scripts --min-release-age=0 --allow-git=root -g sfw
which sfw ; whereis sfw ; sfw --version

sfw --verbose npm install --ignore-scripts --foreground-scripts --min-release-age=0 --allow-git=root -g npm@latest
which npm ; whereis npm ; npm --version ; "$NPM_CONFIG_PREFIX/bin/npm" --version

sfw --verbose npm install --ignore-scripts --foreground-scripts --min-release-age=0 --allow-git=root -g @earendil-works/pi-coding-agent || curl -fsSL https://pi.dev/install.sh | sh
which pi ; whereis pi ; pi --version

curl -fsSL https://claude.ai/install.sh | bash
which claude ; whereis claude ; claude --version

brew install pnpm
which pnpm ; whereis pnpm ; pnpm --version

brew install worktrunk
which wt ; whereis wt ; wt --version
#wt config shell install || FAIL: wt config shell install'

rm -rf "$HOME/.pi" || true
rm "$HOME/.pi" || true ; ln -s "/Volumes/My Shared Files/.pi" "$HOME/.pi" || true

rm -rf "$HOME/.claude" || true
rm "$HOME/.claude" || true ; ln -s "/Volumes/My Shared Files/.claude" "$HOME/.claude" || true

rm -rf "$HOME/_" || true
rm "$HOME/_" || true ; ln -s "/Volumes/My Shared Files/workspace" "$HOME/_" || true

#curl -fsSL https://pkgs.superlogical.com/rex/install.sh | sh -s -- --user
#which rex ; whereis rex ; rex version

#brew install flox
