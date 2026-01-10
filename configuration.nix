# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, mfwolffe-pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    mfwolffe-pkgs.nixosModules.default
  ];

  programs.mfwolffe-packages = {
    enable = true;
    packages = [
      # Rust
      "fackr" "fussr" "wezztershier-rust" "eyescore" "arco" "hyprkvm" "firp"
      # Go
      "parrot-cli" "shellp"
      # Fortran (FPM)
      "fortress" "facsimile"
      # Fortran (Make)
      "fortsh" "fit" "fuss" "ferp" "fortbite" "sniffert" "fortty"
      # C (CMake)
      "gitswitcher" "gitswitch-c" "shtick" "wmswitch"
      # Python
      "wezztershier" "spotify-cue" "waveterm-vis"
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disable hibernation (causes unrecoverable state with NVIDIA)
  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  networking.hostName = "mizu"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Prioritize wired over WiFi (lower metric = higher priority)
  networking.networkmanager.ensureProfiles.profiles = {
    "DogNet" = {
      connection = {
        id = "DogNet";
        type = "wifi";
      };
      wifi = {
        ssid = "DogNet";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
      };
      ipv4 = {
        method = "auto";
        route-metric = 700;
      };
      ipv6 = {
        method = "auto";
        route-metric = 700;
      };
    };
    "Wired connection 1" = {
      connection = {
        id = "Wired connection 1";
        type = "ethernet";
        interface-name = "enp111s0";
      };
      ipv4 = {
        method = "auto";
        route-metric = 50;
      };
      ipv6 = {
        method = "auto";
        route-metric = 50;
      };
    };
    "Wired connection 2" = {
      connection = {
        id = "Wired connection 2";
        type = "ethernet";
        interface-name = "enp112s0";
      };
      ipv4 = {
        method = "auto";
        route-metric = 50;
      };
      ipv6 = {
        method = "auto";
        route-metric = 50;
      };
    };
  };

  # Ensure all ethernet connections have higher priority than WiFi
  networking.networkmanager.dispatcherScripts = [{
    type = "basic";
    source = pkgs.writeText "nm-prioritize-ethernet" ''
      #!/bin/sh
      # Ensure all ethernet connections use metric 50, WiFi uses 700
      if [ "$1" != "lo" ]; then
        if [ "$2" = "up" ]; then
          INTERFACE_TYPE=$(nmcli -t -f GENERAL.TYPE device show "$1" | cut -d: -f2)
          if [ "$INTERFACE_TYPE" = "ethernet" ]; then
            nmcli connection modify "$(nmcli -t -f GENERAL.CONNECTION device show "$1" | cut -d: -f2)" \
              ipv4.route-metric 50 ipv6.route-metric 50 2>/dev/null || true
          fi
        fi
      fi
    '';
  }];

  # SSL/TLS certificates
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Display manager (greetd + tuigreet - minimal TUI greeter)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  # Prevent console spam from greetd
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
  services.desktopManager.gnome.enable = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable i3 window manager (X11)
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu      # Application launcher
      i3status   # Status bar
      i3lock     # Screen locker
    ];
  };

  # XDG portal for screen sharing, file dialogs, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
      modesetting.enable = true;
      open = false;  # Use proprietary driver (more stable)
      nvidiaSettings = true;  # Adds nvidia-settings GUI
      package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;  # 32-bit libs for Steam/games

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Environment variables for Hyprland + NVIDIA
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Hint Electron apps to use Wayland
    WLR_NO_HARDWARE_CURSORS = "1";  # Fix invisible cursor on NVIDIA
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    TERMINAL = "alacritty";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.mfwolffe = {
    isNormalUser = true;
    description = "Matthew Forrester Wolffe";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    shell = pkgs.fish;
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Steam gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;   # For Steam Remote Play
    dedicatedServer.openFirewall = true;  # For Source dedicated servers
    gamescopeSession.enable = true;   # Optimized gaming session
  };
  programs.gamemode.enable = true;  # Feral GameMode for performance optimization
  hardware.steam-hardware.enable = true;  # Udev rules for Steam controllers/hardware

  # DualSense (PS5) controller support
  hardware.uinput.enable = true;  # Virtual input device support
  services.udev.packages = [ pkgs.dualsensectl ];  # DualSense udev rules

  # Enable fish shell
  programs.fish.enable = true;

  # Enable git
  programs.git.enable = true;

  # Enable zoxide (smarter cd)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Enable nix-ld for running non-NixOS binaries (needed for Claude Code VSCode extension)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Hyprland essentials
    alacritty          # Terminal emulator
    wofi               # Application launcher
    waybar             # Status bar
    wlogout            # Logout menu
    dunst              # Notification daemon
    hyprpaper          # Wallpaper utility
    grim               # Screenshot tool
    slurp              # Screen region selector
    hyprpicker         # Color picker
    jq                 # JSON processor (for active window screenshots)
    wl-clipboard       # Clipboard utilities (wl-copy, wl-paste)
    cliphist           # Clipboard history manager
    brightnessctl      # Brightness control
    playerctl          # Media player control
    networkmanagerapplet  # Network manager tray
    gh                    # GitHub CLI

    # Browsers
    (vivaldi.override { proprietaryCodecs = true; })  # Chromium-based browser with codecs

    # Communication & Collaboration
    slack              # Team messaging
    discord            # Voice/text chat
    ferdium            # All-in-one messaging (Slack, Discord, etc.)

    # Development tools
    vscode             # Visual Studio Code
    jetbrains-toolbox  # JetBrains IDE manager

    # JetBrains IDEs
    # jetbrains.aqua                # Test automation IDE (discontinued, will be removed in NixOS 26.05)
    jetbrains.clion                 # C/C++ IDE
    jetbrains.datagrip              # Database IDE
    jetbrains.dataspell             # Data science IDE
    jetbrains.gateway               # Remote development gateway
    jetbrains.goland                # Go IDE
    jetbrains.idea                  # Java/Kotlin IDE (Ultimate)
    jetbrains.mps                   # Meta Programming System
    jetbrains.phpstorm              # PHP IDE
    jetbrains.pycharm               # Python IDE (Professional)
    jetbrains.rider                 # .NET IDE
    jetbrains.ruby-mine             # Ruby IDE
    jetbrains.rust-rover            # Rust IDE
    jetbrains.webstorm              # JavaScript/TypeScript IDE
    # jetbrains.writerside          # Documentation IDE (discontinued, will be removed in NixOS 26.05)

    # Build tools
    gnumake
    cmake
    ninja
    meson
    gcc
    gfortran
    fortran-fpm    # Fortran Package Manager (fpm command)
    clang
    llvm
    pkg-config
    autoconf
    automake
    libtool
    binutils
    gdb
    lldb

    # Rust toolchain
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    # Audio development
    alsa-lib
    alsa-lib.dev

    # Python with pip and pipx
    (python3.withPackages (ps: with ps; [ pip setuptools wheel ]))
    pipx

    # Libraries commonly needed for builds
    openssl
    openssl.dev
    zlib
    zlib.dev
    glfw
    freetype
    fontconfig

    # Code quality tools
    valgrind
    cppcheck
    clang-tools        # clang-format, clang-tidy
    flawfinder

    # Documentation
    doxygen
    graphviz

    # Terminal & utilities
    wezterm
    bat
    tmux
    tldr
    trash-cli
    pay-respects

    # Gaming utilities
    mangohud        # Performance overlay (FPS, GPU/CPU stats)
    protonup-qt     # Manage Proton-GE versions easily
    lutris          # Game launcher for non-Steam games (GOG, Epic, Wine, etc.)
    dualsensectl    # DualSense controller LED/haptic control

    # Media creation
    audacity        # Audio editing
    reaper          # DAW
    reaper-reapack-extension  # Reaper package manager
    reaper-sws-extension      # Reaper plugin extension
    gimp            # Image editing
    kdePackages.kdenlive  # Video editing
  ];

  # Fonts (Nerd Font for waybar icons)
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable Tailscale VPN
  services.tailscale.enable = true;

  # Waydroid (Android container for running Android apps like Kindle)
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;  # Patched for modern kernels using nftables
  };

  # Ollama with NVIDIA GPU support
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;  # Enable password authentication
    };
    openFirewall = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
