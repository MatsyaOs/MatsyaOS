sudo apt install -y --no-install-recommends \
  build-essential cmake extra-cmake-modules \
  gcc pkg-config \
  qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev qttools5-dev qttools5-dev-tools \
  libkf5windowsystem-dev libkf5kio-dev libkf5config-dev libkf5solid-dev libkf5globalaccel-dev \
  libkf5coreaddons-dev libkf5idletime-dev libkf5networkmanagerqt-dev libkf5screen-dev \
  libkf5bluezqt-dev \
  modemmanager-qt-dev libqt5sensors5-dev libqapt-dev libmpv-dev \
  libpam0g-dev libx11-dev libx11-xcb-dev libxcb1-dev libxcb-shape0-dev \
  libxcb-icccm4-dev libxcb-randr0-dev libxcb-xfixes0-dev libxcb-composite0-dev \
  libxcb-damage0-dev libxcb-image0-dev libxcb-util-dev libxcb-keysyms1-dev \
  libxcb-shm0-dev libxcb-dpms0-dev libxcb-dri2-0-dev libxcb-dri3-dev \
  libxcb-ewmh-dev libxcb-glx0-dev libxcb-record0-dev libxcb-xfixes0-dev \
  libxcursor-dev libxtst-dev libsm-dev \
  libpolkit-qt5-1-dev libpolkit-agent-1-dev \
  libicu-dev libcrypt-dev libfreetype6-dev libfontconfig1-dev \
  libcanberra-dev libpulse-dev libcanberra-pulse \
  libapt-pkg-dev xserver-xorg-dev xserver-xorg-input-libinput-dev \
  xserver-xorg-input-synaptics-dev \
  qml-module-qtquick-controls2 qml-module-qtquick2 qml-module-qtquick-layouts \
  qml-module-qt-labs-platform qml-module-qt-labs-settings qml-module-qtqml \
  qml-module-qtquick-window2 qml-module-qtquick-shapes qml-module-qtquick-dialogs \
  qml-module-qtquick-particles2 qml-module-org-kde-kwindowsystem \
  libicu67 mpv sddm kscreen \
  debhelper equivs curl git devscripts lintian automake autotools-dev

sudo mk-build-deps -i -t "apt-get --yes" -r
sudo apt --fix-broken install
