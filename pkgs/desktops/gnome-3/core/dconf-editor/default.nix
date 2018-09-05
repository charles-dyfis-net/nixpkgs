{ stdenv, fetchurl, meson, ninja, vala, libxslt, pkgconfig, glib, dbus-glib, gtk3, gnome3, python3
, libxml2, gettext, docbook_xsl, wrapGAppsHook, gobjectIntrospection }:

let
  pname = "dconf-editor";
  version = "3.30.0";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "0jzmbdngn4v5dxa6ahca1pydakzmhdww3amv6nxbr38570k63ifg";
  };

  nativeBuildInputs = [ meson ninja vala libxslt pkgconfig wrapGAppsHook gettext docbook_xsl libxml2 gobjectIntrospection python3 ];

  buildInputs = [ glib dbus-glib gtk3 gnome3.defaultIconTheme gnome3.dconf ];

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = "${pname}";
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
  };
}
