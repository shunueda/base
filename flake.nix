{
  inputs = {
    # keep-sorted start block=yes
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-direnv-async = {
      url = "github:wbolster/emacs-direnv/pull/82/head";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # For flakeModules for darwinModules and darwinConfigurations
    nix-darwin-flake-module = {
      url = "github:nix-darwin/nix-darwin/pull/1690/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-steam.url = "github:nixos/nixpkgs/pull/499915/head";
    nixpkgs-terraform-providers-bin = {
      url = "github:nix-community/nixpkgs-terraform-providers-bin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nocommit = {
      url = "github:shunueda/nocommit";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    tools = {
      url = "github:anteriorcore/tools";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.systems.follows = "systems";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };
  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        # keep-sorted start
        ./hosts/anterior/darwin-configuration.nix
        ./hosts/personal/darwin-configuration.nix
        ./modules/darwin/common.nix
        ./modules/darwin/linux-builder.nix
        ./modules/home/common.nix
        ./modules/home/ghq.nix
        ./modules/home/qutebrowser.nix
        ./modules/home/screen.nix
        ./nix/flake-modules/devshells.nix
        ./nix/flake-modules/misc.nix
        ./nix/flake-modules/treefmt.nix
        ./nix/flake-modules/ueda-scope.nix
        inputs.devshell.flakeModule
        inputs.home-manager.flakeModules.home-manager
        inputs.nix-darwin-flake-module.flakeModules.default
        inputs.tools.flakeModules.checkBuildAll
        inputs.treefmt-nix.flakeModule
        # keep-sorted end
      ];
    };
}
