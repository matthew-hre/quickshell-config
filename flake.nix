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
      config,
      lib,
      pkgs,
      ...
    }: let
      system = pkgs.stdenv.hostPlatform.system;
      configPackage = self.packages.${system}.quickshell-config;
      cfg = config.programs.quickshellConfig;
      settingsJson = pkgs.writeText "quickshell-settings.json" (builtins.toJSON cfg.settings);
      configSource =
        if cfg.devPath == null
        then "${configPackage}/share/quickshell"
        else config.lib.file.mkOutOfStoreSymlink cfg.devPath;
    in {
      options.programs.quickshellConfig = {
        devPath = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Local Quickshell config path for live editing.";
        };
        settings = lib.mkOption {
          type = lib.types.submodule {
            options = {
              showClock = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Show the clock indicator.";
              };
              showVolume = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Show the volume indicator.";
              };
              showNetwork = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Show the network indicator.";
              };
              showBluetooth = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Show the Bluetooth indicator.";
              };
              showBattery = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Show the battery indicator.";
              };
              showActiveWindow = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Show the active window title.";
              };
              showNotificationStack = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Show the notification stack window.";
              };
              showVolumeNotifier = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Enable volume change notifications.";
              };
              showBrightnessNotifier = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Enable brightness change notifications.";
              };
            };
          };
          default = {};
          description = "Settings for Quickshell UI visibility.";
        };
      };

      config = {
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

        xdg.configFile."quickshell".source = configSource;
        xdg.configFile."quickshell/Commons/Settings.json".source = lib.mkForce settingsJson;

        home.sessionVariables = {
          QML_IMPORT_PATH = "${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml";
        };
      };
    };
  };
}
