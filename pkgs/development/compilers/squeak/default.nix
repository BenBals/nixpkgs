{ stdenv, fetchurl, lib, alsaLib, autoconf, automake, bash, clang, coreutils
, freetype, git, glib, libpulseaudio, libtool, libuuid, makeWrapper, openssl
, pango, perl, xorg }:

stdenv.mkDerivation rec {
  pname = "squeak";
  version = "202003021730";

  src = fetchurl {
    sha256 = "0bpwbnpy2sb4gylchfx50sha70z36bwgdxraym4vrr93l8pd3dix";
    url = "https://github.com/OpenSmalltalk/opensmalltalk-vm/archive/${version}.zip";
  };

  buildInputs = [
    alsaLib
    autoconf
    automake
    bash
    clang
    coreutils
    freetype
    git
    glib
    libpulseaudio
    libtool
    makeWrapper
    openssl
    pango
    perl
  ];

  ldLibraryPath = stdenv.lib.makeLibraryPath  [
    libuuid
    xorg.libX11
  ];

  buildPhase = ''
   find . -type f -exec sed -i -e 's/\/usr\/bin\/env/${lib.escape ["/"] coreutils.outPath}\/bin\/env/g' {} \;
   ./scripts/updateSCCSVersions
   cd build.linux64x64/squeak.cog.spur/build.debug
   printf "\n" | ./mvm
   make
  '';

  installPhase = ''
    ls -lha
    mkdir -p $out/bin
    cp -a . $out/bin
    wrapProgram "$out/bin/squeak" --prefix LD_LIBRARY_PATH ${ldLibraryPath}
  '';

  meta = with stdenv.lib; {
    description = "Smalltalk programming language and environment";
    longDescription = ''
      Squeak is a full-featured implementation of the Smalltalk programming
      language and environment based on (and largely compatible with) the
      original Smalltalk-80 system. Squeak has very powerful 2- and 3-D
      graphics, sound, video, MIDI, animation and other multimedia
      capabilities. It also includes a customisable framework for creating
      dynamic HTTP servers and interactively extensible Web sites.
    '';
    homepage = http://squeakvm.org/;
    downloadPage = http://squeakvm.org/unix/index.html;
    license = with licenses; [ asl20 mit ];
    platforms = platforms.linux;
  };
}
