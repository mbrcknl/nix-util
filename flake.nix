{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, systems, ... }: {
    lib = import ./lib.nix {
      inherit nixpkgs;
      systems = import systems;
    };
  };
}
