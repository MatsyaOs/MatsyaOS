# matsyaos-dependencies
### For Debian/Ubuntu
```
sudo apt install extra-cmake-modules qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev libmpv-dev equivs curl git devscripts lintian build-essential automake autotools-dev --no-install-recommends
sudo mk-build-deps -i -t "apt-get --yes" -r
sudo apt install extra-cmake-modules qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev qttools5-dev libkf5windowsystem-dev -y cmake qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev qttools5-dev qttools5-dev-tools qml-module-qtquick-controls2 qml-module-qtquick2 qml-module-qtquick-layouts qml-module-qt-labs-platform qml-module-qt-labs-settings qml-module-qtqml qml-module-qtquick-window2 qml-module-qtquick-shapes qml-module-qtquick-dialogs qml-module-qtquick-particles2
sudo apt install libpam0g-dev libx11-dev -y
sudo apt install libqt5x11extras5-dev libkf5windowsystem-dev qtbase5-private-dev libxcb1-dev libxcb-shape0-dev libxcb-icccm4-dev -y
sudo apt install cmake libqapt-dev -y
sudo apt install gcc cmake qtbase5-dev qml-module-qtquick-controls2 qml-module-org-kde-kwindowsystem qtdeclarative5-dev qtquickcontrols2-5-dev qttools5-dev libkf5windowsystem-dev -y
sudo apt install qtbase5-dev qtquickcontrols2-5-dev modemmanager-qt-dev libqt5sensors5-dev libkf5networkmanagerqt-dev libkf5screen-dev libkf5bluezqt-dev libkf5kio-dev cmake qtdeclarative5-dev libcanberra-dev libpulse-dev libcanberra-pulse extra-cmake-modules qttools5-dev qttools5-dev-tools  -y
sudo apt install equivs curl git devscripts lintian build-essential automake autotools-dev --no-install-recommends

sudo mk-build-deps -i -t "apt-get --yes" -r
build-essential cmake extra-cmake-modules libkf5kio-dev libkf5solid-dev libkf5windowsystem-dev libkf5config-dev qtbase5-dev qtbase5-private-dev qtdeclarative5-dev qtquickcontrols2-5-dev qttools5-dev qttools5-dev-tools cmake debhelper qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev libqapt-dev libapt-pkg-dev cmake libqapt-dev libpolkit-agent-1-dev libpolkit-qt5-1-dev libsm-dev libxtst-dev libxcb-randr0-dev libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-image0-dev libxcb-util0-dev libkf5idletime-dev extra-cmake-modules pkg-config xserver-xorg-input-libinput-dev libx11-xcb-dev libxcb1-dev libxcb-randr0-dev libxcb-keysyms1-dev libxcursor-dev libxcb-xfixes0-dev libxcb-damage0-dev libxcb-composite0-dev libxcb-shm0-dev libxcb-util-dev libxcb-image0-dev libxcb-dpms0-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-ewmh-dev libxcb-glx0-dev libxcb-record0-dev xserver-xorg-dev xserver-xorg-input-synaptics-dev libxtst-dev libsm-dev libpolkit-qt5-1-dev libpolkit-agent-1-dev libkf5windowsystem-dev libkf5globalaccel-dev libkf5coreaddons-dev libkf5idletime-dev libqt5x11extras5-dev qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev qttools5-dev qttools5-dev-tools cmake gcc qtbase5-dev qtdeclarative5-dev qml-module-qtquick2 qml-module-qtquick-controls2 cmake debhelper extra-cmake-modules libicu-dev libcrypt-dev libfreetype6-dev libfontconfig1-dev libkf5networkmanagerqt-dev libkf5config-dev modemmanager-qt-dev qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev qttools5-dev qttools5-dev-tools qml-module-qtquick-controls2 qml-module-qtquick2 qml-module-qtquick-layouts qml-module-qt-labs-platform qml-module-qt-labs-settings qml-module-qtqml qml-module-qtquick-window2 qml-module-qtquick-shapes qml-module-qtquick-dialogs qml-module-qtquick-particles2
   
```
###For Arch/Manjaro
```
sudo pacman -S extra-cmake-modules qt5-base qt5-quickcontrols2 gcc cmake qt5-base qt5-quickcontrols2 kwindowsystem gcc cmake qt5-base qt5-quickcontrols2 networkmanager-qt modemmanager-qt extra-cmake-modules qt5-base qt5-declarative kconfig kdecoration kguiaddons kcoreaddons kconfigwidgets kwindowsystem kwayland kwin extra-cmake-modules qt5-base qt5-quickcontrols2 taglib kio gcc cmake qt5-base qt5-quickcontrols2 kwindowsystem extra-cmake-modules pkgconf qt5-base qt5-quickcontrols2 qt5-x11extras qt5-tools  kwindowsystem polkit polkit-qt5 xorg-server-devel xf86-input-libinput xf86-input-synaptics extra-cmake-modules qt5-base qt5-quickcontrols2 freetype2 fontconfig networkmanager-qt modemmanager-qt

sudo pacman -S base-devel kidletime
bluedevil
bluez-qt
fishui
fontconfig
freetype2
icu
kwindowsystem
libdbusmenu-qt5
libqtxdg
qt5-quickcontrols2
extra-cmake-modules (make)
ninja (make)
qt5-tools (make)
kconfig
kconfigwidgets
kcoreaddons
kdeclarative
kdecoration
kguiaddons
kwayland
kwin
plasma-framework
qt5-tools
libxcursor
modemmanager-qt
networkmanager-qt
qt5-quickcontrols
libpulse
libxcb
libxtst
polkit-qt5
xf86-input-libinput
xf86-input-synaptics
xorg-server-devel (make)
qt5-svg
qt5-declarative
qt5-graphicaleffects
kio
solid
accountsservice
kscreen

````    
### For batch build
It is advised that you run commands by sudo and not by ROOT USER while building pkg.

#RUN THE FOLLOWING CODE after download 

sudo chmod 700 * 
```
./repoclone.sh
./install-arch-deps.sh
./archpkgbuild.sh
for ARCH
or
./repoclone.sh
install-deb-deps.sh
./batchbuild.sh
if DEBIAN
```

### For build
```
mkdir build
cd build
cmake ..
make
sudo make install

```



