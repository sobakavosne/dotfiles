prerequisites:

sudo apt install xmonad libghc-xmonad-contrib-dev \ 
  nitrogen compton xmobar suckless-tools libxpm-dev \ 
  acpi dunst playerctl flameshot

Ubuntu notes

- Change the touch-pad direction to the natural scrolling

  cd /usr/share/X11/xorg.conf.d/
  sudo vim 40-libinput.conf

      Identifier "touchpad"
      ...
  >     Option "NaturalScrolling" "true"  # Adjust to match your preference
  EndSection
