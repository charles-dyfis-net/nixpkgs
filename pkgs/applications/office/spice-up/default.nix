{ stdenv , fetchFromGitHub , gettext , libxml2 , pkgconfig , gtk3 , granite
, gnome3 , gobjectIntrospection , json-glib , cmake , ninja , libgudev
, libevdev , vala_0_40 , wrapGAppsHook, libsoup }:

stdenv.mkDerivation rec {
  name = "spice-up-${version}";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "Philip-Scott";
    repo = "Spice-up";
    rev = version;
    sha256 = "121yaa8vpvr37nlpl52wf5pqnanhbxlaz25a1qb4k3yiv2jm4vqi";
  };

  USER = "nix-build-user";

  nativeBuildInputs = [
    pkgconfig wrapGAppsHook vala_0_40 cmake ninja
    gettext libxml2 gobjectIntrospection # For setup hook
  ];
  buildInputs = [
    gtk3 granite gnome3.libgee json-glib
    libgudev libevdev libsoup
  ];

  meta = with stdenv.lib; {
    description = "Create simple and beautiful presentations on the Linux desktop";
    homepage = https://github.com/Philip-Scott/Spice-up;
    maintainers = with maintainers; [ samdroid-apps ];
    platforms = platforms.linux;
    # The COPYING file has GPLv3; some files have GPLv2+ and some have GPLv3+
    license = licenses.gpl3Plus;
  };
}
