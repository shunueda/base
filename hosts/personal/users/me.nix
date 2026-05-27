{ self, ... }:
{
  imports = [ self.homeModules.common ];
  programs = {
    discord.enable = true;
    prismlauncher.enable = true;
  };
}
