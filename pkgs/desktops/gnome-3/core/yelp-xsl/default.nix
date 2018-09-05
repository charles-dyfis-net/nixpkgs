{ stdenv, intltool, fetchurl, pkgconfig
, itstool, libxml2, libxslt, gnome3 }:

stdenv.mkDerivation rec {
  name = "yelp-xsl-${version}";
  version = "3.30.0";

  src = fetchurl {
    url = "mirror://gnome/sources/yelp-xsl/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "1k8670n77kl11vmz0z8qhbz017dz45isyljf03nrq65hs8v48v4p";
  };

  passthru = {
    updateScript = gnome3.updateScript { packageName = "yelp-xsl"; attrPath = "gnome3.yelp-xsl"; };
  };

  doCheck = true;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ intltool itstool libxml2 libxslt ];

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Yelp;
    description = "Yelp's universal stylesheets for Mallard and DocBook";
    maintainers = gnome3.maintainers;
    license = [licenses.gpl2 licenses.lgpl2];
    platforms = platforms.linux;
  };
}
