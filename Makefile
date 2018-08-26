EXECUTALE_NAME=swiftygames

install: build install_bin

build: 
	swift package update
	swift build -c release -Xswiftc -static-stdlib -Xswiftc -lncurses

install_bin:
	mv .build/release/SwiftyGames /usr/local/bin/swiftygames

uninstall:
	rm -f /usr/local/bin/swiftygames
