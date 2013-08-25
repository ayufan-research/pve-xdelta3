RELEASE=2.1

PACKAGE=pve-xdelta3
PKGREL=1
SDVER=3.0.6
URL=http://xdelta.googlecode.com/files

ARCH:=$(shell dpkg-architecture -qDEB_BUILD_ARCH)
DEB=${PACKAGE}_${SDVER}-${PKGREL}_${ARCH}.deb

SDDIR=xdelta3-${SDVER}
SDSRC=${SDDIR}.tar.gz

all: ${DEB}

${DEB} deb: ${SDSRC}
	rm -rf ${SDDIR}
	tar xf ${SDSRC}
	cp -av debian ${SDDIR}/debian
	cd ${SDDIR}; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian ${DEB}

.PHONY: download
${SDSRC} download:
	rm -rf ${SDSRC}
	wget ${URL}/${SDSRC}

.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/pve-xdelta3*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

clean:
distclean: clean
	rm -rf xdelta3.svn

.PHONY: clean
clean:
	rm -rf *~ debian/*~ *.deb *.changes *.dsc ${SDDIR} ${SDSRC}.tmp

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}

