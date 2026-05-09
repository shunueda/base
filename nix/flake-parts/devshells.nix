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
          terraform
          # keep-sorted end
        ];
      };
    };
}
