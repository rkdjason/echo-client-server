.PHONY : echo-client echo-server clean install uninstall android-install android-uninstall

all: echo-client echo-server

echo-client: bin/echo-client

echo-server: bin/echo-server

bin/echo-client: echo-client.cpp
	mkdir -p bin
	$(CXX) $(CPPFLAGS) -Wall -O2 $(LDFLAGS) echo-client.cpp $(LDLIBS) -pthread -o bin/echo-client
ifdef ANDROID_NDK_ROOT
	termux-elf-cleaner --api-level 23 bin/echo-client
	llvm-strip bin/echo-client
endif

bin/echo-server: echo-server.cpp
	mkdir -p bin
	$(CXX) $(CPPFLAGS) -Wall -O2 $(LDFLAGS) echo-server.cpp $(LDLIBS) -pthread -o bin/echo-server
ifdef ANDROID_NDK_ROOT
	termux-elf-cleaner --api-level 23 bin/echo-server
	llvm-strip bin/echo-server
endif

clean:
	rm -f bin/echo-client bin/echo-server *.o

install:
	sudo cp bin/echo-client /usr/local/sbi
	sudo cp bin/echo-server /usr/local/sbin

uninstall:
	sudo rm /usr/local/sbin/echo-client /usr/local/sbin/echo-server

android-install:
	adb push bin/echo-client bin/echo-server /data/local/tmp
	adb exec-out "su -c 'mount -o rw,remount /system'"
	adb exec-out "su -c 'cp /data/local/tmp/echo-client /data/local/tmp/echo-server /system/xbin'"
	adb exec-out "su -c 'chmod 755 /system/xbin/echo-client'"
	adb exec-out "su -c 'chmod 755 /system/xbin/echo-server'"
	adb exec-out "su -c 'mount -o ro,remount /system'"
	adb exec-out "su -c 'rm /data/local/tmp/echo-client /data/local/tmp/echo-server'"

android-uninstall:
	adb exec-out "su -c 'mount -o rw,remount /system'"
	adb exec-out "su -c 'rm /system/xbin/echo-client /system/xbin/echo-server'"
	adb exec-out "su -c 'mount -o ro,remount /system'"
