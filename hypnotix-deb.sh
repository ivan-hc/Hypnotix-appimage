#!/usr/bin/env bash

APP=hypnotix

# CREATE A TEMPORARY DIRECTORY
mkdir -p tmp
cd tmp

# DOWNLOADING THE DEPENDENCIES
if test -f ./appimagetool; then
	echo " appimagetool already exists" 1> /dev/null
else
	echo " Downloading appimagetool..."
	wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
fi
if test -f ./pkg2appimage; then
	echo " pkg2appimage already exists" 1> /dev/null
else
	echo " Downloading pkg2appimage..."
	wget -q https://raw.githubusercontent.com/ivan-hc/AM-application-manager/main/tools/pkg2appimage
fi
chmod a+x ./appimagetool ./pkg2appimage
rm -f ./recipe.yml

# CREATING THE HEAD OF THE RECIPE
echo "app: $APP
binpatch: true

ingredients:

  dist: stable
  script:
    - wget http://packages.linuxmint.com/$(wget -q "http://packages.linuxmint.com/search.php?release=any&section=any&keyword=hypnotix" -O - | grep -Po '(?<=href=")[^"]*' | grep "_all.deb" | sort | tail -1)
    - wget http://packages.linuxmint.com/$(wget -q "http://packages.linuxmint.com/search.php?release=any&section=any&keyword=imdb" -O - | grep -Po '(?<=href=")[^"]*' | grep "python" | grep "_all.deb" | sort | tail -1)
    - wget http://packages.linuxmint.com/$(wget -q "http://packages.linuxmint.com/search.php?release=any&section=any&keyword=circle-flags-svg" -O - | grep -Po '(?<=href=")[^"]*' | grep "_all.deb" | sort | tail -1)
  sources:
    - deb http://ftp.debian.org/debian/ stable main contrib non-free
    - deb http://security.debian.org/debian-security/ stable-security main contrib non-free
    - deb http://ftp.debian.org/debian/ stable-updates main contrib non-free
  packages:
    - $APP
    - yt-dlp
    - xapp
    - gir1.2-xapp-1.0
    - libxapp1
    - xapps-common
    - python3
    - python3-gi
    - python3-configobj
    - python3-imdbpy
    - python3-setproctitle
    - python3-tldextract
    - libmpv-dev
    - libimdb-film-perl
    - circle-flags-svg" >> recipe.yml


# DOWNLOAD ALL THE NEEDED PACKAGES AND COMPILE THE APPDIR
./pkg2appimage ./recipe.yml

# LIBUNIONPRELOAD
wget https://github.com/project-portable/libunionpreload/releases/download/amd64/libunionpreload.so
chmod a+x libunionpreload.so
mv ./libunionpreload.so ./$APP/$APP.AppDir/

# COMPILE SCHEMAS
glib-compile-schemas ./$APP/$APP.AppDir/usr/share/glib-2.0/schemas/ || echo "No ./usr/share/glib-2.0/schemas/"

# CUSTOMIZE THE APPRUN
rm -R -f ./$APP/$APP.AppDir/AppRun
cat >> ./$APP/$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export LD_PRELOAD="${HERE}"/libunionpreload.so
export LD_LIBRARY_PATH=/lib/:/lib64/:/lib/x86_64-linux-gnu/:/usr/lib/:"${HERE}"/usr/lib/:"${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${LD_LIBRARY_PATH}"
#export LD_LIBRARY_PATH="${HERE}"/usr/lib/:"${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${LD_LIBRARY_PATH}"
export PATH="${HERE}"/usr/bin/:"${HERE}"/usr/sbin/:"${HERE}"/usr/games/:"${HERE}"/bin/:"${HERE}"/sbin/:"${PATH}"

PYTHON_VERSION=$(find "${HERE}"/usr/lib -name *python* -type d | head -1 | sed 's:.*/::')
export PYTHONPATH="${HERE}/usr/lib/$PYTHON_VERSION":$"${PYTHONPATH}"

export XDG_DATA_DIRS="${HERE}"/usr/share/:"${XDG_DATA_DIRS}"
export PERLLIB="${HERE}"/usr/share/perl5/:"${HERE}"/usr/lib/perl5/:"${PERLLIB}"

mkdir -p ~/.cache/hypnotix/favorites
touch ~/.cache/hypnotix/favorites/list

mkdir -p ~/.cache/hypnotix/yt-dlp
if [ $(gsettings get org.x.hypnotix use-local-ytdlp) = true ]
then
	echo "Local version of yt-dlp selected."
	export PATH="${HOME}/.cache/hypnotix/yt-dlp":${PATH}
else
	echo "System version of yt-dlp selected."
fi

"${HERE}"/usr/lib/hypnotix/hypnotix.py &
EOF

# MADE THE APPRUN EXECUTABLE
chmod a+x ./$APP/$APP.AppDir/AppRun
# END OF THE PART RELATED TO THE APPRUN, NOW WE WELL SEE IF EVERYTHING WORKS ----------------------------------------------------------------------

# IMPORT THE LAUNCHER AND THE ICON TO THE APPDIR IF THEY NOT EXIST
if test -f ./$APP/$APP.AppDir/*.desktop; then
	echo "The desktop file exists"
else
	echo "Trying to get the .desktop file"
	cp ./$APP/$APP.AppDir/usr/share/applications/*$(ls . | grep -i $APP | cut -c -4)*desktop ./$APP/$APP.AppDir/ 2>/dev/null
fi

ICONNAME=$(cat ./$APP/$APP.AppDir/*desktop | grep "Icon=" | head -1 | cut -c 6-)
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/22x22/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/24x24/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/32x32/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/48x48/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/64x64/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/128x128/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/256x256/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/512x512/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/scalable/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/applications/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null


# PATCH
sed -i 's/self.dark_mode_manager/#self.dark_mode_manager/g' ./$APP/$APP.AppDir/usr/lib/hypnotix/hypnotix.py

# REMOVE UNNEEDED FILES
find ./$APP/$APP.AppDir/usr/share/doc/* -not -iname "*$APP*" -a -not -name "." -delete
find ./$APP/$APP.AppDir/usr/share/locale/* -not -iname "*$APP*" -a -not -name "." -delete

# EXPORT THE APP TO AN APPIMAGE
ARCH=x86_64 ./appimagetool -n ./$APP/$APP.AppDir
cd ..
mv ./tmp/*.AppImage .
chmod a+x *.AppImage
