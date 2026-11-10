PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

.PHONY: build install uninstall clean bootstrap

build: bin/nkspfetch

bin/nkspfetch: nkspfetch.sh
	@mkdir -p bin
	install -m 0755 nkspfetch.sh bin/nkspfetch

install: build
	install -d "$(DESTDIR)$(BINDIR)"
	install -m 0755 bin/nkspfetch "$(DESTDIR)$(BINDIR)/nkspfetch"

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/nkspfetch"

clean:
	rm -rf bin

bootstrap:
	git config core.hooksPath .githooks
