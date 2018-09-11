{ stdenv, fetchurl, buildPythonPackage, pkgconfig, glib, gobjectIntrospection,
pycairo, cairo, which, ncurses, meson, ninja, isPy3k }:

buildPythonPackage rec {
  major = "3.30";
  minor = "0";
  version = "${major}.${minor}";
  format = "other";
  pname = "pygobject";
  name = pname + "-" + version;

  src = fetchurl {
    url = "mirror://gnome/sources/pygobject/${major}/${name}.tar.xz";
    sha256 = "1l3bsnpm7p5dr936ir01446p7rzpi6mp94n64r62z4nzflabl83x";
  };

  outputs = [ "out" "dev" ];

  mesonFlags = [
    "-Dpython=python${if isPy3k then "3" else "2" }"
  ];

  nativeBuildInputs = [ pkgconfig meson ninja ];
  buildInputs = [ glib gobjectIntrospection ]
                 ++ stdenv.lib.optionals stdenv.isDarwin [ which ncurses ];
  propagatedBuildInputs = [ pycairo cairo ];

  meta = {
    homepage = https://pygobject.readthedocs.io/;
    description = "Python bindings for Glib";
    platforms = stdenv.lib.platforms.unix;
  };
}
