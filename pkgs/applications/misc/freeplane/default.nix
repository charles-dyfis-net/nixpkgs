{ stdenv, fetchFromGitHub, jdk, jre, gradle, unzip }:

stdenv.mkDerivation rec {
  name = "freeplane-${version}";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "freeplane";
    repo = "freeplane";
    rev = "release-${version}";
    sha256 = "177yvdvh1hb4dl1pdnn42c5mav6h4qn6nwwp0j0dh9gwwkhyrz10";
  };

  buildInputs = [ jdk gradle ];

  buildPhase = ''
    gradle --no-daemon -Dbuild="$out/share/freeplane" binZip
  '';

  installPhase = ''
    mkdir -p -- "$out"/{bin,share}
    zip=( "$PWD"/DIST/*.zip )
    (cd "$out/share" && ${unzip}/bin/unzip "''${zip[0]}" && mv -- */ freeplane)

    cat >$out/bin/freeplane <<EOF
    #! /bin/sh
    JAVA_HOME=${jre} $out/share/freeplane/freeplane.sh
    EOF
    chmod +x $out/bin/freeplane $out/share/freeplane/freeplane.sh
  '';

  meta = with stdenv.lib; {
    description = "Mind-mapping software";
    homepage = https://www.freeplane.org/;
    license = licenses.gpl2Plus;
    #platforms = platforms.linux;
  };
}
