# My Custom Nix Packages Collection

These are a few packages that I use and are not available on nixpkgs.

## How to use it

```
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tscolari-pkgs.url = "github:yourusername/my-nixos-packages";
  };

  outputs = { self, nixpkgs, your-packages, ... }: {
    nixosConfigurations.yourSystem = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ tscolari-pkgs.overlays.default ];

          # Now your packages are available in pkgs
          environment.systemPackages = [
            pkgs.diagridcli
            pkgs.vanta-agent
            # ... etc
          ];
        })
      ];
    };
  };
}
```

## Packages

* [diagridcli](https://diagrid.io)
* [vanta-agent](https://vanta.com)

## nixosModules

* `tscolari-pkgs.nixosModules.default` -> everything
* `tscolari-pkgs.nixosModules.vanta` -> vanta-agent : `service.vanta-agent.enable = true` (systemd units)
