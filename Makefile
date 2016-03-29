
all: openocd-build/.ready.built

openocd-build/.ready.git:
	rm -rf openocd-build
	git clone git://git.code.sf.net/p/openocd/code openocd-build
	touch openocd-build/.ready.git

openocd-build/.ready.built: ./create_rpi_openocd_image.sh openocd-build/.ready.builder
	./create_rpi_openocd_image.sh && touch $@

openocd-build/.ready.builder: ./create_rpi_builder_image.sh openocd-build/.ready.git
	./create_rpi_builder_image.sh && touch $@

publish:
	docker push waltplatform/walt-node:rpi-openocd
