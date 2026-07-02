# Rust (cargo, rustc, rustup)
. "$HOME/.cargo/env" 2>/dev/null

export PATH=$PATH:/Users/olivertran/.spicetify
export PATH=$PATH:~/.spicetify
export PATH=$PATH:~/.spicetify
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# Added by Antigravity
export PATH="/Users/olivertran/.antigravity/antigravity/bin:$PATH"

# bun completions
[ -s "/Users/olivertran/.bun/_bun" ] && source "/Users/olivertran/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/olivertran/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/.local/bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


PATH="/Users/olivertran/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/olivertran/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/olivertran/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/olivertran/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/olivertran/perl5"; export PERL_MM_OPT;

# onWatch
export PATH="$HOME/.onwatch:$PATH"

# Soundfolio stats → Obsidian
alias soundfolio='python3 /Users/olivertran/Developer/SpotifyStats/scripts/obsidian_stats.py'

# nnn: start at boot volume root (Finder’s “Macintosh HD”) when no path is given
nnn() {
  if [ "$#" -eq 0 ]; then
    command nnn "/Volumes/Macintosh HD"
  else
    command nnn "$@"
  fi
}

# Xcode lives at /Applications/Utilities/Xcode.app (not /Applications/Xcode.app)
export DEVELOPER_DIR="/Applications/Utilities/Xcode.app/Contents/Developer"
