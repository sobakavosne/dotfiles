prerequisites:

sudo apt install xmonad libghc-xmonad-contrib-dev \ 
  nitrogen compton xmobar suckless-tools libxpm-dev \ 
  acpi dunst playerctl flameshot xautolock scrot \
  i3lock xset \
  starship zoxide \
  numlockx vim pulseaudio-utils

Ubuntu notes

- Change the touch-pad direction to the natural scrolling

  sudo vim /usr/share/X11/xorg.conf.d/40-libinput.conf

      Identifier "touchpad"
      ...
  >     Option "NaturalScrolling" "true"  # Adjust to match your preference
  EndSection
