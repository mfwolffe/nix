{ config, pkgs, ... }:

{
  # Home Manager needs this info
  home.username = "mfwolffe";
  home.homeDirectory = "/home/mfwolffe";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Packages to install to user profile
  home.packages = with pkgs; [
    # Add user-specific packages here
    # ripgrep
    # fd
    # eza
  ];

  # ──────────────────────────────────────────────────────────────
  # Git configuration
  # ──────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name = "mfwolffe";  # Change to your name
      user.email = "wolffemf@dukes.jmu.edu";  # Change to your email
      init.defaultBranch = "trunk";
      pull.rebase = false;
    };
  };

  # ──────────────────────────────────────────────────────────────
  # Fish shell (managed by Home Manager)
  # ──────────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting  # Disable greeting
      pay-respects --alias | source
    '';
    shellAliases = {
      ll = "ls -la";
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#mizu";
    };
  };

  # ──────────────────────────────────────────────────────────────
  # Starship prompt (CachyOS-style)
  # ──────────────────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        style = "bold purple";
        symbol = " ";
      };

      git_status.style = "bold red";

      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
      };

      # Language icons with brand colors
      rust.symbol = "[](bold #f74c00) ";
      python.symbol = "[](bold #3776ab) ";
      golang.symbol = "[](bold #00add8) ";
      nodejs.symbol = "[](bold #5fa04e) ";
      c.symbol = "[](bold #a8b9cc) ";
      lua.symbol = "[](bold #000080) ";
      nix_shell.symbol = "[](bold #5277c3) ";
    };
  };

  # ──────────────────────────────────────────────────────────────
  # Hyprland config (link your existing config)
  # ──────────────────────────────────────────────────────────────
  # Option 1: Symlink your existing dotfiles
  # home.file.".config/hypr".source = ~/GithubOrgs/tenseleyFlow/ndotfiles/hypr2;

  # Option 2: Manage inline (example)
  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   settings = {
  #     # your hyprland config here
  #   };
  # };

  # ──────────────────────────────────────────────────────────────
  # Waybar (link your existing config)
  # ──────────────────────────────────────────────────────────────
  # home.file.".config/waybar".source = ~/GithubOrgs/tenseleyFlow/ndotfiles/waybar2;

  # ──────────────────────────────────────────────────────────────
  # Wezterm
  # ──────────────────────────────────────────────────────────────
  # home.file.".config/wezterm".source = ~/GithubOrgs/tenseleyFlow/ndotfiles/wezterm;

  # ──────────────────────────────────────────────────────────────
  # Example: Managing a service (dunst notifications)
  # ──────────────────────────────────────────────────────────────
  # services.dunst = {
  #   enable = true;
  #   settings = {
  #     global = {
  #       font = "JetBrainsMono Nerd Font 10";
  #       frame_width = 2;
  #     };
  #   };
  # };

  # This value determines the Home Manager release compatibility.
  # Don't change this unless you know what you're doing.
  home.stateVersion = "24.11";
}
