{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #zshrcExtra = ''
    #  export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    #'';
  };
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
    # functions used for shell prompt
    parse_git_branch() {
        local BRANCH
        BRANCH="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
        if (( ''${#BRANCH} > 8 )) ; then
            BRANCH="''${BRANCH:0:3}..''${BRANCH: -3}"
        fi
        echo "''${BRANCH}"
    }
    parse_cwd() {
        if [[ $(pwd) == "''${HOME}" ]] ; then
            CWD="~"
        else
            local CWD
            CWD="$(basename "$(pwd)")"
            if (( ''${#CWD} > 12 )) ; then
                CWD="''${CWD:0:5}..''${CWD: -5}"
            fi
        fi
        echo "''${CWD}"
    }
    # Using separate config files instead of contexts
    parse_k8s_ctx() {
        local CONTEXT
        CONTEXT="$(kc)"
        if (( ''${#CONTEXT} > 6 )) ; then
            CONTEXT="''${CONTEXT:0:2}..''${CONTEXT: -2}"
        fi
        echo "''${CONTEXT}"
    }

    # other useful functions
    ## dump plist file as json
    plview() {
        for FILE in $@ ; do
            plutil -convert json "''${FILE}" -o - | jq
        done
    }

    # export functions to child processes. Make sure to capture all funcs from above
    export -f parse_git_branch parse_cwd parse_k8s_ctx plview

    # macos bash
    export PS1="\[\033[06;31m\]\$(parse_k8s_ctx)\[\033[00m\]:\[\033[06;32m\]\u@\h\[\033[00m\]:\[\033[06;34m\]\$(parse_cwd)\[\033[00m\]:\[\033[33m\]\$(parse_git_branch)\[\033[00m\] \$ "

    # append to the history file, don't overwrite it
    shopt -s histappend

    # K3d runs into the low macos default file ulimit setting of 256.
    # This also requires launchctl setup, see /usr/local/bin/bootconfig.sh
    ulimit -n 16384

    # PATH modifications

    ## Prefer homebrew tools. This might impact installers and other mechanisms which build on apple specifics
    PATH="/opt/homebrew/bin:$PATH"
    ### Add some homebrew keg-only paths
    #PATH="/opt/homebrew/opt/binutils/bin:$PATH"
    #PATH="/opt/homebrew/opt/curl/bin:$PATH"
    #PATH="/opt/homebrew/opt/lsof/bin:$PATH"
    #PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    #PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    #PATH="/opt/homebrew/opt/unzip/bin:$PATH"
    #PATH="/opt/homebrew/opt/man-db/libexec/bin:$PATH"
    ### add all the gnubin paths
    #for GPATH in /opt/homebrew/opt/*/libexec/gnubin ; do
    #    PATH="''${GPATH}:''${PATH}"
    #done

    ## personal bin
    PATH=''${PATH}:''${HOME}/bin

    ## rust bin (created by homebrew rustup-init
    PATH=''${PATH}:''${HOME}/.cargo/bin

    ## kubectl krew binaries
    PATH=''${PATH}:''${HOME}/.krew/bin

    ## pipx wrappers
    PATH=''${PATH}:~/.local/bin

    ## finally export
    export PATH

    # shellcheck source=/dev/null
    #. ~/.iterm2_shell_integration."$(basename "''${SHELL}")"

    # k9s editor
    export KUBE_EDITOR="code -w"

    # AWS autocomplete
    #complete -C aws_completer aws
    # OpenStack autocomplete, takes several seconds
    #eval "$(openstack complete)"

    # source homebrew completions
    #. "/opt/homebrew/etc/profile.d/bash_completion.sh"
    #eval "$(/opt/homebrew/bin/brew shellenv)"

    # Context aliases for k8s commands
    # Collides with OpenShift auto-generated names
    for FILE in ~/.kube/*kubeconfig ; do
        CL="$(basename "''${FILE}")"
        CL="''${CL%.*}"
        alias kubectl-''${CL}="kubectl --kubeconfig ''${FILE}"
        alias helm-''${CL}="helm --kubeconfig ''${FILE}"
        alias k9s-''${CL}="k9s --kubeconfig ''${FILE}"
        alias stern-''${CL}="stern --kubeconfig ''${FILE}"
    done

    # Choose java, see https://knasmueller.net/how-to-install-java-openjdk-16-on-macos-big-sur
    #export JAVA_HOME=/opt/homebrew/opt/openjdk

    # SAP
    ## Default hashi-vault settings
    #export VAULT_ADDR=https://vault.tools.sap
    #export VAULT_NAMESPACE_ADDR=ecs/unicorn-dev

    # GEC
    ## Tell golang to not go over proxy for this
    #export GOPRIVATE=git.mgmt.innovo-cloud.de
    ## Use OOE default remote user for ansible
    ## Using "Host 100..." in ~/.ssh/config instead
    #export ANSIBLE_REMOTE_USER=ssteinert

    # DB
    ## use surge in shell processes
    #export http_proxy=http://127.0.0.1:6152
    #export https_proxy=''${http_proxy}
    #export all_proxy=socks5://127.0.0.1:6153

    # fzf
    ## Auto-completion
    ### brew-bash
    #[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.bash" 2> /dev/null
    ### nix-bash
    [[ $- == *i* ]] && source "$(fzf-share)/completion.bash" 2> /dev/null
    ## Key bindings
    ### brew-bash
    #source "/opt/homebrew/opt/fzf/shell/key-bindings.bash"
    ### nix-bash
    source "$(fzf-share)/key-bindings.bash"
    '';
  };

  home.shellAliases = {
    k = "kubectl";

    # ststefa
    ls = "ls --color=auto";
    ll = "ls -l";
    la = "ll -A";
    # make vscode accept <file>:<line> arg
    code = "code -g";

    ffmpeg = "ffmpeg -hide_banner";
    ffprobe = "ffprobe -hide_banner";
    ffplay = "ffplay -hide_banner";

  };
}
