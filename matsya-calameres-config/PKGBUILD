# Maintainer: Aditya Shakya <adi1090x@gmail.com>

pkgname=matsya-calamares-config
pkgver=1.0
pkgrel=6
pkgdesc="Calamares configuration for Archcraft."
url="https://github.com/matsyaos/"
arch=('any')
license=('GPL')
provides=($pkgname)
conflicts=($pkgname)
depends=()

prepare() {
	cp -af ../etc/. ${srcdir}
}

package() {
	# copy all files recursively in /etc/calamares
	(find calamares -type f -exec install -Dm 644 "{}" "$pkgdir/etc/{}" \;)
	# make scripts executable
	chmod 755 "$pkgdir"/etc/calamares/launch.sh
	chmod 755 "$pkgdir"/etc/calamares/branding/matsya/test-slides.sh
}



