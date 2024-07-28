#!/bin/sh

set -u
APP=hypnotix

# CREATE A TEMPORARY DIRECTORY
mkdir -p tmp && cd tmp || exit 1

# DOWNLOADING APPIMAGETOOL
if test -f ./appimagetool; then
	echo " appimagetool already exists" 1> /dev/null
else
	echo " Downloading appimagetool..."
	wget -q "$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')" -O appimagetool
fi
chmod a+x ./appimagetool

# CREATE AND ENTER THE APPDIR
mkdir -p "$APP".AppDir && cd "$APP".AppDir || exit 1

# ICON
if ! test -f ./*.svg; then
	wget -q https://raw.githubusercontent.com/linuxmint/hypnotix/master/usr/share/icons/hicolor/scalable/apps/hypnotix.svg
fi

# LAUNCHER
echo "[Desktop Entry]
Name=Hypnotix
Name[ar]=هيبنوتكس
Name[eo]=TeleVidilo
Name[he]=היפנוטיקס
Name[ko]=힙노틱스
Name[sr]=Хипнотикс
Name[zh_CN]=网络电视 Hypnotix
Comment=Watch TV
Comment[am]=ቲቪ መመልከቻ
Comment[ar]=شاهد التلفاز
Comment[be]=Глядзець тэлебачанне
Comment[bg]=Гледане на телевизия
Comment[br]=Sellout ouzh an tele
Comment[ca]=Mirar TV
Comment[cs]=Sledovat TV
Comment[cy]=Gwylio teledu
Comment[da]=Se TV
Comment[de]=Fernsehen
Comment[el]=Δείτε τηλεόραση
Comment[eo]=Spekti televidon
Comment[es]=Ver la TV
Comment[et]=Vaata TV-d
Comment[eu]=Ikusi TB
Comment[fa]=تماشای تلویزیون
Comment[fi]=Katso televisiota
Comment[fr]=Regarder la télévision
Comment[fr_CA]=Regarder la télévision
Comment[he]=צפיה בטלוויזיה
Comment[hi]=टीवी देखें
Comment[hr]=Gledajte TV
Comment[hu]=TV nézés
Comment[ia]=Reguardar TV
Comment[id]=Tonton TV
Comment[ie]=Regardar TV
Comment[is]=Horfa á sjónvarp
Comment[it]=Visualizzatore TV
Comment[ja]=テレビを視聴
Comment[kab]=Wali tiliẓri
Comment[kn]=ಟಿವಿ ವೀಕ್ಷಿಸು
Comment[ko]=TV 보기
Comment[la]=TV Specta
Comment[lt]=Žiūrėti TV
Comment[nb]=Se TV
Comment[nl]=TV kijken
Comment[oc]=Agachar la TV
Comment[pl]=Oglądaj telewizję
Comment[pt]=Ver TV
Comment[pt_BR]=Assistir TV
Comment[ro]=Privește TV
Comment[ru]=Смотреть ТВ
Comment[sk]=Pozerať TV
Comment[sl]=Glej TV
Comment[sq]=Shiko TV
Comment[sr]=Гледај ТВ
Comment[sr@latin]=Gledaj TV
Comment[sv]=Se på TV
Comment[th]=รับชมทีวี
Comment[tr]=TV Seyret
Comment[uk]=Дивитися TV
Comment[uz]=TV ko‘rish
Comment[vi]=Xem TV
Comment[zh_CN]=观看电视
Comment[zh_TW]=觀賞電視
Exec=AppRun
Icon=hypnotix
Terminal=false
Type=Application
Encoding=UTF-8
Categories=AudioVideo;Video;Player;TV;
Keywords=Television;Stream;
StartupNotify=false" > hypnotix.desktop

# APPRUN
rm -f ./AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
"${HERE}"/conty.sh \
	--bind-try /usr/share/fonts /usr/share/fonts \
	--bind-try /usr/share/themes /usr/share/themes \
	hypnotix "$@"
EOF
chmod a+x ./AppRun

# DOWNLOAD CONTY
if ! test -f ./*.sh; then
	conty_download_url=$(curl -Ls https://api.github.com/repos/ivan-hc/Conty/releases | sed 's/[()",{} ]/\n/g' | grep -oi "https.*hypnotix.*sh$" | head -1)
	echo " Downloading Conty..."
	if wget --version | head -1 | grep -q ' 1.'; then
		wget -q --no-verbose --show-progress --progress=bar "$conty_download_url"
	else
		wget "$conty_download_url"
	fi
	chmod a+x ./conty.sh
fi

# EXIT THE APPDIR
cd .. || exit 1

# EXPORT THE APPDIR TO AN APPIMAGE
VERSION=$(curl -Ls https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=hypnotix-wayland | grep "^pkgver=" | cut -c 8-)
ARCH=x86_64 VERSION="$VERSION-1" ./appimagetool -s ./"$APP".AppDir
cd .. && mv ./tmp/*.AppImage ./ || exit 1

