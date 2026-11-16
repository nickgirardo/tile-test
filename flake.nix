{
  description = "Software tile rendering test for GT";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    GameTankEmulator.url = "github:nickgirardo/nix-GameTankEmulator/32aa921c65e9bb480da79eb4e90287f77e94a5fe";
    GTFO.url = "github:nickgirardo/nix-GTFO/e159f175b9ef3c2698f8c81a6843fac2fd3fcef0";
  };

  outputs = { self, nixpkgs, gitignore, GameTankEmulator, GTFO }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # The version of cc65 in nixpkgs is the last stable release
      # This is 6 years old at this point and is missing many important features
      cc65 = pkgs.cc65.overrideAttrs (_: {
        version = "unstable-2026-11-08";
        src = pkgs.fetchFromGitHub {
          owner = "cc65";
          repo = "cc65";
          rev = "eebf54af545f4ae52f8489a2f6d4d5f93e7942d2";
          hash = "sha256-M4DlFSKD1fc2km79xY9v/6kcvx8s66CXISeZd6dKNyI=";
        };
      });

      build_setup = pkgs.buildNpmPackage {
        name = "build_setup";
        src = gitignore.lib.gitignoreSource ./scripts/build_setup;
        npmDepsHash = "sha256-9mNIu6Gk6RIuvKql3BGLkSDghrVsMrvSfIWx7x9QPhY=";
        dontNpmBuild = true;
        installPhase = ''
          mkdir -p $out/bin
          cp -r . $out/bin
        '';
      };

      converters = pkgs.buildNpmPackage {
        name = "converters";
        src = gitignore.lib.gitignoreSource ./scripts/converters;
        npmDepsHash = "sha256-vpPBDNG1Splnja5HdewJW1G3Co2rcW3v3kvCS6AWOuI=";
        dontNpmBuild = true;
        installPhase = ''
          mkdir -p $out/bin
          cp -r . $out/bin
        '';
      };

      rom = pkgs.stdenv.mkDerivation {
        inherit system;
        name = "Tile Rendering Test";

        src = gitignore.lib.gitignoreSource ./.;

        nativeBuildInputs = [
          cc65
          pkgs.gnumake
          pkgs.zip
          pkgs.nodejs
          pkgs.zopfli
        ];

        CC65_LIB="${cc65}/share/cc65/lib";

        BUILD_SETUP = "${build_setup}/bin";
        CONVERTERS = "${converters}/bin";

        phases = [
          "unpackPhase"
          "patchPhase"
          "preBuildPhase"
          "buildPhase"
          "installPhase"
        ];

        preBuildPhase = "node $BUILD_SETUP/build_setup.js";

        buildPhase = "make bin/game.gtr";

        installPhase = ''
            mkdir -p $out/bin
            cp -r bin $out

            # TODO web output not built? why?
            # mkdir -p $out/web
            # cp -r web $out
        '';
      };

      # TODO this will fail as web output is broken
      web-emulator = GameTankEmulator.outputs.packages.${system}.gte-web.overrideAttrs (final: prev: {
        rom = "${rom}/bin/game.gtr";
        WEB_SHELL = "${rom}/web/shell.html";
        WEB_ASSETS = "${rom}/web/assets/";
        WINDOW_TITLE = "Tile Rendering Test";
      });

      # TODO this will fail as web output is broken
      web-emulator-embed = GameTankEmulator.outputs.packages.${system}.gte-web.overrideAttrs (final: prev: {
        rom = "${rom}/bin/game.gtr";
        WEB_SHELL = "web/embedded.html";
      });
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ cc65 pkgs.gnumake pkgs.nodejs pkgs.zip pkgs.zopfli ];
        CC65_LIB="${cc65}/share/cc65/lib";
        BUILD_SETUP = "${build_setup}/bin";
        CONVERTERS = "${converters}/bin";
      };
      packages.${system} = {
          inherit rom web-emulator web-emulator-embed;
          default = rom;
      };
      apps.${system} = let
        emu = pkgs.writeShellApplication {
          name = "emulate";
          runtimeInputs = [ GameTankEmulator.outputs.packages.${system}.default ];
          text = "GameTankEmulator ${rom}/bin/game.gtr";
        };
        emulate = {
          type = "app";
          program = "${emu}/bin/emulate";
        };
        emu-web = pkgs.writeShellApplication {
          name = "emulate-web";
          runtimeInputs = [ pkgs.caddy ];
          text = ''
            # Takes the port as first argument
            # Default to port 8080
            PORT="''${1:-8080}"
            caddy file-server --listen :"$PORT" --root ${web-emulator.outPath}/dist
          '';
        };
        emulate-web = {
          type = "app";
          program = "${emu-web}/bin/emulate-web";
        };
        flash_ = pkgs.writeShellApplication {
          name = "flash";
          runtimeInputs = [ GTFO.outputs.packages.${system}.default ];
          text = ''
               if [ "$#" -ne 1 ]; then
                  echo "Please specify the port to flash onto"
                  exit 1
               fi
               GTFO -p "$1" ${rom}/bin/game.gtr.bank*
            '';
        };
        flash = {
          type = "app";
          program = "${flash_}/bin/flash";
        };
      in {
        inherit emulate emulate-web flash;
        default = emulate;
      };
    };
}
