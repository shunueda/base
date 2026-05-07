{ ... }:
{
  perSystem =
    { config, ... }:
    {
      config.codegen = {
        enable = true;
        root = ../..;
        files =
          let
            inherit (config.base.scope) base-cdktf-providers;
          in
          {
            "packages/base-cdktf-providers/gen".source = "${base-cdktf-providers.gen}/providers/";
          };
      };
    };
}
