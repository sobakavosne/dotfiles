prerequisites:

sudo apt install xmonad libghc-xmonad-contrib-dev \
  nitrogen compton xmobar suckless-tools libxpm-dev \
  acpi dunst playerctl flameshot xautolock scrot \
  i3lock \
  zoxide \
  numlockx vim pulseaudio-utils \
  imagemagick

sudo snap refresh --hold=forever

"starship" should be installed separately:

  curl -sS https://starship.rs/install.sh | sh

"xset" will be installed within the nvidia driver

ASUS Zenbook (NVidia) requires some libraries from the cooler control for Linux:

  sudo apt install curl apt-transport-https
  curl -1sLf   'https://dl.cloudsmith.io/public/coolercontrol/coolercontrol/setup.deb.sh'   | sudo -E bash
  sudo apt update
  sudo apt install coolercontrol

Ubuntu notes

- Change the touch-pad direction to the natural scrolling

  sudo vim /usr/share/X11/xorg.conf.d/40-libinput.conf

      Identifier "touchpad"
      ...
  +>    Option "NaturalScrolling" "true"  # Adjust to match your preference
  +>    Option "Tapping" "on"

  EndSection
