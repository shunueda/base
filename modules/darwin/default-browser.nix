{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.defaultBrowser;
in
{
  options.services.defaultBrowser = {
    enable = lib.mkEnableOption "Set the default browser using defaultbrowser";
    browser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The browser identifier to set as default (e.g. "firefox", "chrome", "safari").
        Run `defaultbrowser` in the terminal to see available options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.user.agents.defaultBrowser = lib.mkIf (cfg.browser != null) {
      serviceConfig = {
        Label = "org.nixos.default-browser";
        ProgramArguments = [
          "/bin/sh"
          "-c"
          ''
            set -euo pipefail

            bin="${lib.getExe pkgs.defaultbrowser}"
            target=${lib.escapeShellArg cfg.browser}

            current=$($bin)

            if [ "$current" != "$target" ]; then
              echo "Setting default browser from '$current' to '$target'"
              $bin "$target"
            fi
          ''
        ];
        RunAtLoad = true;
        StandardErrorPath = "/tmp/org.nixos.default-browser.stderr";
        StandardOutPath = "/tmp/org.nixos.default-browser.stdout";
      };
    };

    system.activationScripts.defaultBrowser = {
      text = lib.optionalString (cfg.browser != null) ''
        echo "Configuring service to set browser to '${cfg.browser}' on login."
      '';
    };
  };
}
