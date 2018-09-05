{ stdenv, fetchurl, substituteAll, pkgconfig, libxslt, which, libX11, gnome3, gtk3, glib
, gettext, libxml2, xkeyboard_config, isocodes, itstool, wayland
, libseccomp, bubblewrap, gobjectIntrospection, gtk-doc, docbook_xsl }:

stdenv.mkDerivation rec {
  name = "gnome-desktop-${version}";
  version = "3.30.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-desktop/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "1zcmyxxf61hrmba2g5d7zhck4pfc5x2gf90hznh2b4cdy5m4yja5";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    pkgconfig which itstool gettext libxslt libxml2 gobjectIntrospection
    gtk-doc docbook_xsl
  ];
  buildInputs = [
    libX11 bubblewrap xkeyboard_config isocodes wayland
    gtk3 glib libseccomp
  ];

  propagatedBuildInputs = [ gnome3.gsettings-desktop-schemas ];

  patches = [
    (substituteAll {
      src = ./bubblewrap-paths.patch;
      BUBBLEWRAP_BIN = "${bubblewrap}/bin/bwrap";
    })
  ];

  configureFlags = [
    "--enable-gtk-doc"
  ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = "gnome-desktop";
      attrPath = "gnome3.gnome-desktop";
    };
  };

  meta = with stdenv.lib; {
    description = "Library with common API for various GNOME modules";
    license = with licenses; [ gpl2 lgpl2 ];
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
  };
}
