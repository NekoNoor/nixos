{ lib, ...}:

{
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = lib.mkDefault "euro";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    # disabling mouse acceleration
    mouse = {
      accelProfile = "flat";
    };
  };

  hardware.xpadneo.enable = true;
}