{ stdenv, fetchurl, meson, ninja, pkgconfig, vala, gettext
, libxml2, desktop-file-utils, wrapGAppsHook
, glib, gtk3, libgtop, gnome3 }:

let
  pname = "gnome-usage";
  version = "3.28.0";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "0130bwinpkz307nalw6ndi5mk38k5g6jna4gbw2916d54df6a4nq";
  };

  patches = [
    # Fails to build with vala-0.42
    # upstream issue and fix: https://gitlab.gnome.org/GNOME/gnome-usage/issues/46
    (fetchurl {
      url = https://gitlab.gnome.org/GNOME/gnome-usage/uploads/fec685e39a06f1c90f207415a0964e56/0001-Fix-build-with-vala-0.42.patch;
      sha256 = "0d7cak480xfkgndhykhjk3zlk1mk152sgg53vsm4lpvg73l8vzlz";
    })
  ];

  nativeBuildInputs = [ meson ninja pkgconfig vala gettext libxml2 desktop-file-utils wrapGAppsHook ];

  buildInputs = [ glib gtk3 libgtop gnome3.defaultIconTheme ];

  postPatch = ''
    chmod +x build-aux/meson/postinstall.sh
    patchShebangs build-aux/meson/postinstall.sh
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    description = "";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
  };
}
