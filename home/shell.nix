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
      # Some useful helpers managed by nix
      #[[ $- == *i* ]] && source ~/.bash_functions
      # Always source
      source ~/.bash_functions

      # Decorate prompt with k8s context, cwd, and git branch. Uses exported funcs from ~/.bash_functions
      export PS1="\[\033[06;31m\]\$(parse_k8s_ctx)\[\033[00m\]:\[\033[06;32m\]\u@\h\[\033[00m\]:\[\033[06;34m\]\$(parse_cwd)\[\033[00m\]:\[\033[33m\]\$(parse_git_branch)\[\033[00m\] \$ "

      # Append to the history file, don't overwrite it
      shopt -s histappend

      # K3d runs into the low macos default file ulimit setting of 256.
      # This also requires launchctl setup, see /usr/local/bin/bootconfig.sh
      ulimit -n 16384

      # PATH modifications using path_prepend/append/path_promote from `~/.bash_functions`
      # Note that the last promoted entry will be the first in $PATH!
      # The order is:
      # - Nix
      # - Homebrew
      # - macOS, including path_helper entries
      # - personal tools

      # nix-darwin resets PATH in /etc/bashrc after /etc/profile ran macOS path_helper.
      # Run path_helper here again so fresh login shells and nested login shells see the same macOS PATH entries.
      if [ -x /usr/libexec/path_helper ]; then
          eval "$(/usr/libexec/path_helper -s)"
      fi

      ## Add Homebrew before macOS system paths. Nix profile paths are moved in front below.
      path_promote "/opt/homebrew/bin"

      ### Add some homebrew keg-only paths. These disabled ones are managed by nix
      #path_promote "/opt/homebrew/opt/binutils/bin"
      #path_promote "/opt/homebrew/opt/curl/bin"
      #path_promote "/opt/homebrew/opt/lsof/bin"
      #path_promote "/opt/homebrew/opt/openjdk/bin" # handled through MacOS wrapper, does not need to be on PATH

      ### add all the gnubin paths
      for GPATH in /opt/homebrew/opt/*/libexec/gnubin ; do
          path_promote "''${GPATH}"
      done

      # Regular Ruby executables. Must win over /usr/bin/ruby, but not over Nix.
      path_promote "/opt/homebrew/opt/ruby/bin"

      ## Keep Nix profile paths before Homebrew, Ruby, and macOS system paths.
      path_promote "/nix/var/nix/profiles/default/bin"
      path_promote "/run/current-system/sw/bin"
      path_promote "/etc/profiles/per-user/$USER/bin"
      path_promote "$HOME/.nix-profile/bin"

      ## personal bin
      path_append "$HOME/bin"

      ## rust bin (created by homebrew rustup-init)
      path_append "$HOME/.cargo/bin"

      ## kubectl krew binaries
      path_append "$HOME/.krew/bin"

      ## commonly used wrapper script dir
      path_append "$HOME/.local/bin"

      ## Obsidian tui
      path_append "/Applications/Obsidian.app/Contents/MacOS"

      # Ruby executables added by "gem install ..."
      path_append "/opt/homebrew/lib/ruby/gems/4.0.0/bin"
      # User-installed Ruby gem executables
      path_append "$HOME/.local/share/gem/ruby/4.0.0/bin"


      ## finally export
      export PATH

      # shellcheck source=/dev/null
      #. ~/.iterm2_shell_integration."$(basename "''${SHELL}")"

      # AWS autocomplete
      #complete -C aws_completer aws
      # OpenStack autocomplete, takes several seconds
      #eval "$(openstack complete)"

      # source homebrew completions
      [[ $- == *i* ]] && source "/opt/homebrew/etc/profile.d/bash_completion.sh"
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

      # atuin history sync
      # Conflicts with fzf keybindings
      # atuin requires ble.sh or bash-preexec. Tha latter is much simpler.
      [ -f /opt/homebrew/etc/profile.d/bash-preexec.sh ] && . /opt/homebrew/etc/profile.d/bash-preexec.sh
      # Normal history search on arrow up. Invoke atuin only on Ctrl-r
      eval "$(atuin init bash --disable-up-arrow)"

      # fzf
      ## Auto-completion
      ### brew-fzf, usually not used
      #[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.bash" 2> /dev/null
      ### nix-fzf, disabled in favour of atuin
      #[[ $- == *i* ]] && source "$(fzf-share)/completion.bash" 2> /dev/null
      ## Key bindings
      ### brew-fzf, usually not used
      #source "/opt/homebrew/opt/fzf/shell/key-bindings.bash"
      ### nix-fzf, disabled in favour of atuin
      #source "$(fzf-share)/key-bindings.bash"

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
    '';
  };

  home.shellAliases = {
    k = "kubectl";
    ls = "ls --color=auto";
    ll = "ls -l";
    la = "ll -a";
    grep = "grep --color=auto";
    # make vscode accept <file>:<line> arg
    code = "code -g";
    # quieter ffmpeg output
    ffmpeg = "ffmpeg -hide_banner";
    ffprobe = "ffprobe -hide_banner";
    ffplay = "ffplay -hide_banner";

  };
}
