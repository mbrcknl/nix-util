{ nixpkgs, systems }:

let

  inherit (builtins) typeOf;
  inherit (nixpkgs.lib) attrNames mapAttrs foldl';
  inherit (nixpkgs.lib.attrsets) unionOfDisjoint;

  mkFlake = { inputs ? {}, flake ? _: {}, perSystem ? _: {} }:
    let
      merge_perSystem = outputs: system:
        let
          new = mapAttrs (_: v: { ${system} = v; }) (perSystem {
            inherit inputs nixpkgs system;
            pkgs = nixpkgs.legacyPackages.${system};
          });
          merge = attrs: n:
            attrs // { ${n} = (outputs.${n} or {}) // new.${n}; };
        in foldl' merge outputs (attrNames new);

      perSystem_outputs = foldl' merge_perSystem {} systems;
      flake_outputs = flake { inherit inputs nixpkgs systems; };

      expand_apps = mapAttrs (key: val:
        if key == "apps" && typeOf val == "set"
        then expand_system_apps val
        else val
      );

      expand_system_apps = mapAttrs (system: val:
        if typeOf val == "set"
        then set_app_types val
        else val
      );

      set_app_types = mapAttrs (name: attrs:
        if typeOf attrs == "set" && attrs ? "program"
        then { type = "app"; } // attrs
        else attrs
      );

      outputs = expand_apps (
        unionOfDisjoint perSystem_outputs flake_outputs
      );
    in outputs;

in { inherit mkFlake; }
