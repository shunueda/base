{
  inputs,
  pkgs,
  lib,
  stdenv,
  ...
}:
let
  inherit (stdenv.hostPlatform) system;
  tfProviders = inputs.nixpkgs-terraform-providers-bin.legacyPackages.${system}.providers;
in
lib.makeScope pkgs.newScope (
  scopeSelf:
  let
    inherit (scopeSelf) callPackage;

    baseTerraformProviders = with tfProviders; [
      hashicorp.aws
      integrations.github
    ];

    pl2nixOverlay = final: prev: {
      mkNpmModule =
        args:
        let
          orig = prev.mkNpmModule args;
        in
        orig.overrideAttrs (
          self:
          lib.optionalAttrs (builtins.pathExists (self.src + "/tsconfig.json")) {
            nativeBuildInputs =
              self.nativeBuildInputs or [ ]
              ++ (with pkgs; [
                jq
                moreutils
              ]);
            prePatch = orig.prePatch or "" + ''
              jq --arg tsconfig ${../tsconfig.json} '
                if has("extends")
                then .extends = $tsconfig
                else .
                end
              ' tsconfig.json | sponge tsconfig.json
            '';
          }
        );
    };
  in
  {
    inherit inputs baseTerraformProviders;

    terraform = pkgs.terraform.withPlugins (_: baseTerraformProviders);
    nodejs = pkgs.nodejs_24;

    package-lock2nix = callPackage inputs.package-lock2nix.lib.package-lock2nix {
      inherit (scopeSelf) nodejs;
      overrideScope = pl2nixOverlay;
    };
  }
  // lib.packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ../packages;
  }
)
