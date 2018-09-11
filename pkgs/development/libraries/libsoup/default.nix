{ stdenv, fetchurl, glib, libxml2, meson, ninja, pkgconfig, gnome3
, gnomeSupport ? true, sqlite, glib-networking, gobjectIntrospection, vala
, libpsl, python3, fetchpatch }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "libsoup";
  version = "2.64.0";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "09z7g3spww3f84y8jmicdd6lqp360mbggpg5h1fq1v4p5ihcjnyr";
  };

  patches = [
    # Meson patches from upstream
    (fetchpatch {
      url = https://gitlab.gnome.org/GNOME/libsoup/commit/f134b372d34131d94a6aadd44f351e52a005f8d6.patch;
      sha256 = "1zd5mg7g4scyf5akvaygydi5w7r7x44n8cazl618c9k56fly55kb";
    })
    (fetchpatch {
      url = https://gitlab.gnome.org/GNOME/libsoup/commit/79526c35779ccfc932bda3c0ea3f05785b89a46a.patch;
      sha256 = "1v8x4cxbhbsy2wp4ihzivafhpjlv6wcq7nr4nrh2p9chs5jc1dgj";
    })
    (fetchpatch {
      url = https://gitlab.gnome.org/GNOME/libsoup/commit/6dc3f241cfe11b31fdbccf65d35aac45c3aaf6bc.patch;
      sha256 = "13gzrq76hhyjc09b6qv4q6xq2wsxf3gpdf02v0jn0ikf5flqb0ln";
    })
    (fetchpatch {
      url = https://gitlab.gnome.org/GNOME/libsoup/commit/dfaca0bd03a35426b629278067019dcc129a948d.patch;
      sha256 = "1g10839ybmkjigr6bpx4irng5129nbgcgwzv9sgrbq6i1ndgk8k0";
    })
    (fetchpatch {
      url = https://gitlab.gnome.org/GNOME/libsoup/commit/2a7ff0ab0b81c3d4b8be217786b41b016fa56623.patch;
      sha256 = "06sb7swzgmxqa4kjqh5a77x0wnl4dv590d999z1fjqiad88n5d55";
    })
    (fetchpatch {
      url = https://gitlab.gnome.org/GNOME/libsoup/commit/1dd3333a793089768506ad07fbf328ac13fd2897.patch;
      sha256 = "1d5816sg808dnx0vfqpnprz3xx61f71q8wj6akrbljxczkwkv6g7";
    })
  ];

  postPatch = ''
    patchShebangs libsoup/
  '';

  outputs = [ "out" "dev" ];

  buildInputs = [ python3 sqlite libpsl ];
  nativeBuildInputs = [ meson ninja pkgconfig gobjectIntrospection vala ];
  propagatedBuildInputs = [ glib libxml2 ];

  mesonFlags = [
    "-Dtls_check=false" # glib-networking is a runtime dependency, not a compile-time dependency
    "-Dgssapi=false"
    "-Dvapi=true"
    "-Dgnome=${if gnomeSupport then "true" else "false"}"
  ];

  doCheck = false; # ERROR:../tests/socket-test.c:37:do_unconnected_socket_test: assertion failed (res == SOUP_STATUS_OK): (2 == 200)

  passthru = {
    propagatedUserEnvPackages = [ glib-networking.out ];
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = {
    description = "HTTP client/server library for GNOME";
    homepage = https://wiki.gnome.org/Projects/libsoup;
    license = stdenv.lib.licenses.gpl2;
    inherit (glib.meta) maintainers platforms;
  };
}
