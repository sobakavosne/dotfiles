UBUNTU distro
_____________

  Quick Installation:
  
    cd /path/to/ASUS-Zenbook-Ubuntu
    ./install.sh
    
    This will automatically copy all configuration files and scripts to their proper locations.

  Prerequisites:
  
    sudo apt install xmonad libghc-xmonad-contrib-dev \
      nitrogen compton xmobar suckless-tools libxpm-dev \
      acpi dunst playerctl flameshot xautolock scrot \
      i3lock \
      zoxide \
      numlockx vim pulseaudio-utils \
      imagemagick pavucontrol \
      stacer flatpak \
      neovim fzf \
      fonts-firacode \
      radeontop nvidia-smi \
      lm-sensors bc \
      bluetooth bluez-tools \
      xrandr setxkbmap
    
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    
    flatpak install flathub net.mkiol.SpeechNote
    
    sudo snap refresh --hold=forever

  Oh-my-posh:

    curl -s https://ohmyposh.dev/install.sh | bash -s
    ~/.cache/oh-my-posh/themes/paradox.omp.json
    
  "xset" will be installed within the nvidia driver
  
  ASUS Zenbook (NVidia) requires some libraries from the cooler control for Linux:
  
    sudo apt install curl apt-transport-https
    curl -1sLf   'https://dl.cloudsmith.io/public/coolercontrol/coolercontrol/setup.deb.sh'   | sudo -E bash
    sudo apt update
    sudo apt install coolercontrol

  For the newest version also the following driver should be installed:

    sudo apt install nvidia-driver-580-open
  
  Ubuntu notes
  
  - Change the touch-pad direction to the natural scrolling
  
    sudo vim /usr/share/X11/xorg.conf.d/40-libinput.conf
  
        Identifier "touchpad"
        ...
    +>    Option "NaturalScrolling" "true"  # Adjust to match your preference
    +>    Option "Tapping" "on"
  
    EndSection
