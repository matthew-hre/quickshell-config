{
  description = "Quickshell configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    quickshell,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn system);
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      src = pkgs.lib.cleanSource ./.;
    in {
      quickshell-config = pkgs.stdenvNoCC.mkDerivation {
        pname = "quickshell-config";
        version = "0.1.0";
        inherit src;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/quickshell
          cp -r Commons Components shell.qml README.md $out/share/quickshell/
          runHook postInstall
        '';
      };

      default = self.packages.${system}.quickshell-config;
    });

    homeManagerModules.default = {
      pkgs,
      ...
    }: let
      system = pkgs.stdenv.hostPlatform.system;
      configPackage = self.packages.${system}.quickshell-config;
    in {
      home.packages = [
        quickshell.packages.${system}.default
        pkgs.qt6Packages.qt5compat
        pkgs.libsForQt5.qt5.qtgraphicaleffects
        pkgs.kdePackages.qtbase
        pkgs.kdePackages.qtdeclarative
        pkgs.kdePackages.qtsvg
        pkgs.kdePackages.qtstyleplugin-kvantum
        pkgs.wallust
        pkgs.material-symbols
        pkgs.material-icons
        pkgs.cava
        pkgs.slurp
      ];

      xdg.configFile."quickshell".source = "${configPackage}/share/quickshell";

      home.sessionVariables = {
        QML_IMPORT_PATH =
          "${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml";
      };
    };
  };
}
