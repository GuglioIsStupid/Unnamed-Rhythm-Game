all: clean desktop dist

desktop: lovefile win64 dist
gitbuilds: clean lovefile win64 win64_launcher gitdist
console: lovefile switch

GameName = Rit
GameVersion = $(shell cat src/Assets/Data/Version.txt)

# get git_sha argument that is given with make <target> git_sha=<sha>

clean:
	rm -rf build

lovefile: 
	mkdir build
	mkdir build/$(GameName)-lovefile
	# zip all files in src/ into a love file
	cd src && zip -9 -r ../build/$(GameName)-lovefile/$(GameName).love *

win64: lovefile
	mkdir build/$(GameName)-win64

	wget https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip
	mv -f love-11.5-win64.zip requirements/win64/
	unzip requirements/win64/love-11.5-win64.zip -d requirements/win64
	mv -f requirements/win64/love-11.5-win64 requirements/win64/love
	
	rm requirements/win64/love-11.5-win64.zip

	cp -r requirements/win64/love/* build/$(GameName)-win64
	rm -rf requirements/win64/love

	cp requirements/steam_appid.txt build/$(GameName)-win64
	cp requirements/alsoft.ini build/$(GameName)-win64


	cat build/$(GameName)-win64/love.exe build/$(GameName)-lovefile/$(GameName).love > build/$(GameName)-win64/$(GameName).exe
	rm build/$(GameName)-win64/love.exe
	rm build/$(GameName)-win64/lovec.exe

macos: lovefile
	mkdir build/$(GameName)-macos
	cp -r requirements/macos/love.app build/$(GameName)-macos
	cp requirements/macos/libdiscord-rpc.dylib build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/macos/luasteam.so build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/macos/libsteam_api.dylib build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/steam_appid.txt build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/macos/alsoft.ini build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/macos/https.so build/$(GameName)-macos/love.app/Contents/MacOS
	mv build/$(GameName)-macos/love.app build/$(GameName)-macos/$(GameName).app
	cp build/$(GameName)-lovefile/$(GameName).love build/$(GameName)-macos/$(GameName).app/Contents/Resources/

# love nx loll
switch: lovefile
	rm -rf build/$(GameName)-switch
	mkdir -p "build/$(GameName)-switch"

	nacptool --create "Rit" "AGORI Studios" "$(GameVersion)" build/$(GameName)-switch/Rit.nacp
	mkdir build/$(GameName)-switch/romfs
	cp build/$(GameName)-lovefile/$(GameName).love build/$(GameName)-switch/romfs/game.love

	elf2nro requirements/switch/love.elf build/$(GameName)-switch/Rit.nro --nacp=build/$(GameName)-switch/Rit.nacp --romfsdir=build/$(GameName)-switch/romfs

	rm -r build/$(GameName)-switch/romfs
	rm build/$(GameName)-switch/Rit.nacp

appimage: lovefile
	rm -rf build/$(GameName)-appimage
	mkdir -p "build/$(GameName)-appimage"

	chmod +x ./requirements/appimage/appimagetool-x86_64.AppImage
	./requirements/appimage/love.AppImage --appimage-extract
	
	sed -i 's|Exec=love %f|Exec=Rit %f|' ./squashfs-root/love.desktop
	sed -i 's|Exec=/home/runner/work/love-appimage-source/love-appimage-source/installdir/bin/love %f| Exec=/home/runner/work/love-appimage-source/love-appimage-source/installdir/bin/Rit %f|' ./squashfs-root/share/applications/love.desktop
	
	sed -i 's|/bin/love"|/bin/Rit"|' ./squashfs-root/AppRun
	
	cat ./squashfs-root/bin/love build/$(GameName)-lovefile/$(GameName).love > ./squashfs-root/bin/Rit
	cp ./requirements/appimage/video.so ./squashfs-root/lib/
	chmod +x ./squashfs-root/bin/Rit
	./requirements/appimage/appimagetool-x86_64.AppImage ./squashfs-root/ build/$(GameName)-appimage/$(GameName).AppImage

	rm -rf squashfs-root
dist:
	rm -rf build/dist
	mkdir build/dist
	cd build/$(GameName)-win64 && zip -9 -r ../../build/dist/$(GameName)-win64.zip *
	cp build/$(GameName)-lovefile/$(GameName).love build/dist/$(GameName).love

win64_launcher:
	# make .love first
	mkdir build/$(GameName)-lovefile-launcher
	# zip all files in git-launcher-src/ into a love file
	cd git-launcher-src && zip -9 -r ../build/$(GameName)-lovefile-launcher/$(GameName)-launcher.love *

	mkdir build/$(GameName)-win64-launcher

	wget https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip
	mv -f love-11.5-win64.zip requirements/win64/
	unzip requirements/win64/love-11.5-win64.zip -d requirements/win64
	mv -f requirements/win64/love-11.5-win64 requirements/win64/love
	
	rm requirements/win64/love-11.5-win64.zip

	cp -r requirements/win64/love/* build/$(GameName)-win64-launcher
	rm -rf requirements/win64/love

	if [ -n "$(git_sha)" ]; then echo "$(git_sha)" > build/$(GameName)-win64-launcher/git_sha.txt; fi

	cat build/$(GameName)-win64-launcher/love.exe build/$(GameName)-lovefile-launcher/$(GameName)-launcher.love > build/$(GameName)-win64-launcher/$(GameName)-launcher.exe
	rm build/$(GameName)-win64-launcher/love.exe
	rm build/$(GameName)-win64-launcher/lovec.exe

gitdist:
	rm -rf build/dist
	mkdir build/dist
	cd build/$(GameName)-win64 && zip -9 -r ../../build/dist/$(GameName)-win64.zip *
	cd build/$(GameName)-win64-launcher && zip -9 -r ../../build/dist/$(GameName)-win64-launcher.zip *
	cp build/$(GameName)-lovefile/$(GameName).love build/dist/$(GameName).love
