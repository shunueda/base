{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        packages = with pkgs; [
          # keep-sorted start
          awscli2
          nixd
          nodejs
          terraform
          typescript-language-server
          # keep-sorted end
        ];
      };
    };
}
