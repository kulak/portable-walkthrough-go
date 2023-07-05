all: release/portable-walkthrough-go.raw

# Build the static service binary from the Go source file
build/portable-walkthrough-go: build main.go
	mkdir -p build/usr/bin
	go build -tags netgo -o build/usr/bin/portable-walkthrough-go

# Build a a squashfs file system from the static service binary, the
# two unit files and the os-release file (together with some auxiliary
# empty directories and files that can be over-mounted from the host.
build: build/portable-walkthrough-go
	mkdir -p build/usr/bin build/usr/lib/systemd/system build/etc build/proc build/sys build/dev build/run build/tmp build/var/tmp build/var/lib/walkthrough-go
	rsync -a ./fs-img-templ/ ./build/

release/portable-walkthrough-go.raw: build
	rm -f release/portable-walkthrough-go.raw
	mkdir -p release/
	mksquashfs build/ release/portable-walkthrough-go.raw

# A shortcut for installing all needed build-time dependencies on Fedora
install-tools-fedora:
	dnf install squashfs-tools

install-tools-arch:
	sudo pacman -S squashfs-tools

clean:
	go clean
	rm -rf build
	rm -rf release

inspect:
	sudo portablectl inspect ./release/portable-walkthrough-go.raw

.PHONY: all install-tools-fedora install-tools-arch clean inspect
