{ inputs, ... }:
{
  flake.homeModules.common =
    {
      self,
      pkgs,
      config,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      imports = [
        inputs.nocommit.homeModules.default
        inputs.sops-nix.homeManagerModules.sops
        self.homeModules.ghq
        self.homeModules.qutebrowser
      ];
      xdg.enable = true;
      programs = {
        # keep-sorted start block=yes
        alacritty = {
          enable = true;
          theme = "alabaster";
          settings = {
            window = {
              padding = {
                x = 10;
                y = 10;
              };
            };
            font = {
              normal = {
                family = "JetBrains Mono";
                style = "Regular";
              };
              size = 13;
            };
          };
        };
        bash = {
          enable = true;
          shellOptions = [
            "globstar"
            "histreedit"
            "extglob"
          ];
          historyControl = [
            "ignorespace"
            "ignoredups"
          ];
          historySize = 1000000;
          historyFileSize = 1000000;
          historyFile = "${config.home.homeDirectory}/.sh_history";
          bashrcExtra = ''
            sops-read() {
              local KEY_NAME="$1"

              if [[ -z "$KEY_NAME" ]]; then
                >&2 echo "Usage: sops-read <KEY_NAME>"
                return 1
              fi

              sops -d --output-type=json "${../../secrets/common.yaml}" |
                jq -r ".''${KEY_NAME}"
            }
          '';
        };
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        emacs = {
          enable = true;
          overrides = self: super: {
            direnv = super.direnv.overrideAttrs (_: {
              src = inputs.emacs-direnv-async;
            });
          };
          extraPackages =
            epkgs: with epkgs; [
              # keep-sorted start
              avy
              corfu
              direnv
              exec-path-from-shell
              fzf
              ghq
              git-gutter
              gptel
              kotlin-ts-mode
              magit
              markdown-mode
              multiple-cursors
              nix-ts-mode
              ocaml-eglot
              orderless
              paredit
              rust-mode
              smartparens
              sops
              super-save
              treesit-grammars.with-all-grammars
              tuareg
              typst-ts-mode
              undo-tree
              vertico
              zenburn-theme
              # keep-sorted end
            ];
        };
        firefox = {
          enable = true;
        };
        fzf.enable = true;
        ghq = {
          enable = true;
          settings = {
            root = "${config.home.homeDirectory}/code";
          };
        };
        git = {
          enable = true;
          settings = {
            init = {
              defaultBranch = "master";
            };
            user = {
              name = "Shun Ueda";
              email = "me@shu.nu";
            };
            diff.algorithm = "histogram";
            rebase = {
              autosquash = true;
              autostash = true;
              stat = true;
            };
            merge.directoryRenames = true;
            rerere = {
              autoupdate = true;
              enabled = true;
            };
            pull.rebase = true;
            push.autoSetupRemote = true;
          };
        };
        gpg = {
          enable = true;
          scdaemonSettings = {
            disable-ccid = true;
          };
        };
        home-manager.enable = true;
        mergiraf = {
          enable = true;
          enableGitIntegration = true;
        };
        nix-search-tv = {
          enable = true;
          settings = {
            indexes = [
              "home-manager"
              "noogle"
              "nixpkgs"
            ];

            update_interval = "3h";
            enable_waiting_message = true;
          };
        };
        nocommit = {
          enable = true;
          enableGitIntegration = true;
          useConfigBasedHook = true;
        };
        password-store.enable = true;
        screen = {
          enable = true;
        };
        ssh = {
          enable = true;
          enableDefaultConfig = false;
        };
        starship = {
          enable = true;
          settings = {
            add_newline = false;
            format = "$git_branch:$directory $character ";
            character = {
              format = "[\\$](white)";
            };
            directory = {
              format = "[$path]($style)";
              style = "bold blue";
            };
            git_branch = {
              format = "[$branch]($style)";
              style = "bold green";
            };
          };
        };
        zoxide.enable = true;
        # keep-sorted end
      };
      services = {
        gpg-agent = {
          enable = true;
          enableSshSupport = true;
          pinentry.package = pkgs.pinentry_mac;
          defaultCacheTtl = 600;
          maxCacheTtl = 7200;
        };
      };
      fonts.fontconfig.enable = true;
      home = {
        packages =
          (with pkgs; [
            maccy
            orbstack
            sops
            steam
            jetbrains-mono
          ])
          ++ (with self.packages.${system}; [
            homerow
            ensure-jupyter-no-output
          ]);
        file = {
          ".emacs.d" = {
            source = ../../.emacs.d;
            recursive = true;
          };
          ".hushlogin" = {
            text = "";
          };
        };
      };
      sops = {
        gnupg.sshKeyPaths = [ ];
        defaultSopsFile = ../../secrets/default.yaml;
        secrets = { };
      };
    };
}
