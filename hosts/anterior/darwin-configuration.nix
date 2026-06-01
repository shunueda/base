{ self, inputs, ... }:
let
  user = "me";
  specialArgs = { inherit self inputs; };
  system = "aarch64-darwin";
in
{
  flake.darwinConfigurations.anterior = inputs.nix-darwin.lib.darwinSystem {
    inherit specialArgs;
    modules = [
      self.darwinModules.common
      self.darwinModules.linux-builder
      {
        nixpkgs.hostPlatform = system;
        users.users.${user}.home = "/Users/${user}";
        system.primaryUser = user;
        system.stateVersion = 6;
        environment.systemPackages = [
          self.packages.${system}.ensure-jupyter-no-output
          inputs.nocommit.packages.${system}.default
        ];
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.${user} = {
          imports = [ ./users/me.nix ];
          home.stateVersion = "26.05";
        };
      }
    ];
  };
}
