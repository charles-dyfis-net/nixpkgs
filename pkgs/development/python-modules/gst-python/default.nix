{ buildPythonPackage, fetchurl, meson, ninja, stdenv, pkgconfig, python, pygobject3
, gst-plugins-base, ncurses, isPy3k
}:

let
  pname = "gst-python";
  version = "1.14.2";
  name = "${pname}-${version}";
in buildPythonPackage rec {
  inherit pname version;
  format = "other";

  outputs = [ "out" "dev" ];

  src = fetchurl {
    urls = [
      "${meta.homepage}/src/gst-python/${name}.tar.xz"
      "mirror://gentoo/distfiles/${name}.tar.xz"
      ];
    sha256 = "08nb011acyvlz48fqh8c084k0dlssz9b7wha7zzk797inidbwh6w";
  };

  patches = [
    # Meson build does not support Python 2 at the moment
    # https://bugzilla.gnome.org/show_bug.cgi?id=797138
    (fetchurl {
      name = "0001-meson-Allow-building-with-Python-2.patch";
      url = "https://bugzilla.gnome.org/attachment.cgi?id=373641";
      sha256 = "18m95f8kdz8g4djhpwdmp190cliz29z3vidhshqa3956i246gszm";
    })
  ];

  nativeBuildInputs = [ meson ninja pkgconfig python ];

  # XXX: in the Libs.private field of python3.pc
  buildInputs = stdenv.lib.optional isPy3k ncurses;

  mesonFlags = [
    "-Dpython_version=${if isPy3k then "3" else "2"}"
  ];

  propagatedBuildInputs = [ gst-plugins-base pygobject3 ];

  meta = {
    homepage = https://gstreamer.freedesktop.org;

    description = "Python bindings for GStreamer";

    license = stdenv.lib.licenses.lgpl2Plus;
  };
}
