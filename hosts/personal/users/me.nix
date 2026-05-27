{ self, pkgs, ... }:
{
  imports = [ self.homeModules.common ];

  home.packages = with pkgs; [ leetgo ];

  programs = {
    discord.enable = true;
    prismlauncher.enable = true;
  };
}
