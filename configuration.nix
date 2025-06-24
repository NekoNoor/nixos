{ pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cuddles = {
    isNormalUser = true;
    description = "cuddles";
    extraGroups = [
      "adbusers"
      "input"
      "kvm"
      "libvirt"
      "libvirtd"
      "networkmanager"
      "plugdev"
      "qemu"
      "spice"
      "wheel"
    ];
    packages = with pkgs; with kdePackages; [
      # utilities
      bitwarden
      filelight
      filezilla
      gparted
      kate
      discover
      kgpg
      libreoffice-qt
      linux-wifi-hotspot
      localsend
      maliit-keyboard
      monero-gui
      okteta
      prusa-slicer
      solaar
      sony-headphones-client
      #varia
      vial
      warpinator
      # online
      (pkgs.ungoogled-chromium.override {
        enableWideVine = true;
      })
      (pkgs.gajim.override {
        enableJingle = true;
        enableE2E = true;
        enableSecrets = true;
        enableRST = true;
        enableSpelling = true;
        enableUPnP = true;
        enableAppIndicator = true;
      })
      zoom-us
      mullvad-browser
      # All Matrix clients suck apparently
      element-desktop
      nextcloud-client
      protonvpn-gui
      signal-desktop
      telegram-desktop
      whatsapp-for-linux
      # media
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          looking-glass-obs
          obs-pipewire-audio-capture
          obs-vaapi
          obs-vkcapture
          wlrobs
        ];
      })
      blender
      chatterino2
      fooyin
      inkscape
      kdenlive
      krita
      mpris-scrobbler
      mpv
      nicotine-plus
      pipe-viewer
      qbittorrent
      spicetify-cli
      spotify
      streamlink
      sublime-music
      syncplay
      syncthingtray
      vlc
      xwaylandvideobridge
      yt-dlp
    ];
  };

  # enable replaysorcery on boot, doesn't work with nvidia :(
  #services.replay-sorcery = {
  #  enable = true;
  #  autoStart = true;
  #  enableSysAdminCapability = true;
  #  settings = {
  #    videoInput = "hwaccel"; # requires `services.replay-sorcery.enableSysAdminCapability = true`
  #    videoFramerate = 60;
  #  };
  #};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; with kdePackages; [
    (python3.withPackages(ps: with ps; [
      capstone
      colorama
      cryptography
      docopt
      keystone-engine
      lxml
      passlib
      pycryptodome
      pycryptodomex
      pyserial
      pyusb
      qrcode
      requests
      wheel
    ]))
    #pypy3
    appimage-run
    edl
    ffmpeg-full
    ghostscript
    git
    grc
    groff
    guile
    home-manager
    htop
    lm_sensors
    ntfs3g
    p7zip
    pandoc
    samba
    sbctl
    sddm-kcm
    unrar
    unzip
    wget
    wineWowPackages.waylandFull
    winetricks
    wl-clipboard
    xclip
    # virtualization
    OVMF
    gnome-boxes
    qemu
    swtpm
    spice-gtk
  ];
  
  security.wrappers.spice-client-glib-usb-acl-helper = {
    owner = "root";
    group = "root";
    source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";
  };

  # Enable libvirtd, ovmf and virt-manager
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ (pkgs.OVMFFull.override {
            secureBoot = true;
            tpmSupport = true;
            tlsSupport = true;
            httpSupport = true;
          }) ];
        };
      };
    };
  };
  programs.virt-manager.enable = true;
  
  # Enable adb
  programs.adb.enable = true;

  # Enable wireshark
  programs.wireshark.enable = true;

  # Add appimages as a binary type to easily run them
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  # Enable Flatpak support
  services.flatpak.enable = true;
  services.packagekit.enable = true;
  services.fwupd.enable = true;
  fonts.fontDir.enable = true;

  # Enable kde partition manager
  programs.partition-manager.enable = true;

  # Set fish as default shell for all users and enable fish in nix-shell and nix run
  programs.fish = {
    enable = true;
    promptInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
  };
  users.defaultUserShell = pkgs.fish;

  # Enable neovim and set as default editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # add udev rules for ns-usbloader as user and sysdvr as user
  programs.ns-usbloader.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="4ee0", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="091e", ATTRS{idProduct}=="2bc3", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", GROUP="users", MODE="0660"
    SUBSYSTEM=="usb_device", GROUP="users", MODE="0660"
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  #programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
