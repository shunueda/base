{ inputs, flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    {
      pkgs,
      lib,
      system,
      ...
    }:
    {
      options.base.scope = lib.mkOption { type = lib.types.raw; };
      config =
        let
          baseScope = pkgs.callPackage ../base-scope.nix { inherit inputs; };
          availableOnSystem = lib.meta.availableOn { inherit system; };
        in
        {
          base.scope = baseScope;
          packages = lib.filterAttrs (_: v: lib.isDerivation v && availableOnSystem v) baseScope;
        };
    }
  );
}
