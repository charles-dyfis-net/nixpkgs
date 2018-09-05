{ stdenv, meson, ninja, gettext, fetchurl, pkgconfig
, wrapGAppsHook, itstool, desktop-file-utils, python3
, glib, gtk3, evolution-data-server
, libuuid, webkitgtk, zeitgeist
, gnome3, libxml2 }:

let
  version = "3.30.0";
in stdenv.mkDerivation rec {
  name = "bijiben-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/bijiben/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "1xcbbhg7ldpl9mrdl5m6gk9pfakbmmam008n212d6317y3i2r78l";
  };

  doCheck = true;

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  nativeBuildInputs = [
    meson ninja pkgconfig gettext itstool libxml2 desktop-file-utils python3 wrapGAppsHook
  ];

  buildInputs = [
    glib gtk3 libuuid webkitgtk gnome3.tracker
    gnome3.gnome-online-accounts zeitgeist
    gnome3.gsettings-desktop-schemas
    evolution-data-server
    gnome3.defaultIconTheme
  ];

  mesonFlags = [
    "-Dzeitgeist=true"
    "-Dupdate_mimedb=false"
  ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = "bijiben";
      attrPath = "gnome3.bijiben";
    };
  };

  meta = with stdenv.lib; {
    description = "Note editor designed to remain simple to use";
    homepage = https://wiki.gnome.org/Apps/Bijiben;
    license = licenses.gpl3;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
