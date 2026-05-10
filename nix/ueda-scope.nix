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
  in
  {
    inherit inputs;

    inherit (inputs.tools.packages.${system}) nix-flake-check-changed nix-grep-to-build;

    terraform = pkgs.terraform.withPlugins (
      _: with tfProviders; [
        hashicorp.aws
        integrations.github
      ]
    );

    sopsWrapper = callPackage ./sops-wrapper.nix { };

    nix2terraform = callPackage ./nix2terraform.nix { };
  }
  // lib.packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ../packages;
  }
)
