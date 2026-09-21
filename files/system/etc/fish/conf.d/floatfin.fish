# Floatfin terminal defaults (fish).
# Prompt via starship when present, else a clean fallback. Aliases glue the
# baked-in CLI tools (eza, bat, rg, duf, btop) to familiar names.

if command -q starship
    starship init fish | source
else
    function fish_prompt
        printf '%s › ' (prompt_pwd)
    end
end

# --- navigation & listing (terminal-first, keyboard-light) ----------------
alias ls 'eza --icons=auto'
alias ll 'eza -la --icons=auto'
alias lt 'eza --tree'
alias cat 'bat'
alias grep 'rg'
alias top 'btop'
alias du 'duf'
alias df 'duf'
alias find 'fd'
alias free 'free -h'
alias ping 'ping -c 4'
alias mkdir 'mkdir -p'

# --- git -------------------------------------------------------------------
alias gst 'git status'
alias ga 'git add -A'
alias gc 'git commit -m'
alias gcam 'git add -A && git commit -m'
alias gl 'git log --oneline --graph --decorate -20'

# --- system shortcuts ------------------------------------------------------
alias update 'sudo bootc upgrade'
alias status 'bootc status'
alias up 'bootc status | head'
alias fastfetch 'fastfetch --config /usr/share/ublue-os/fastfetch.jsonc'

# --- toolbox & nix ---------------------------------------------------------
alias db 'distrobox'
alias dbe 'distrobox enter'
alias nixsh 'nix shell'
alias nixdev 'nix develop'

# --- zoxide: jump anywhere you've already been -----------------------------
if command -q zoxide
    zoxide init fish | source
    alias cd 'z'
    alias zi 'z -i'
end