ZSH=/HOMEPATH/.oh-my-zsh
ZSH_CUSTOM=$ZSH/custom
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
plugins=(git extract colorize encode64 golang docker docker-compose)
source $ZSH/oh-my-zsh.sh
source ~/.p10k.zsh
alias docker='sudo -E docker'
alias docker-compose='sudo -E docker-compose'