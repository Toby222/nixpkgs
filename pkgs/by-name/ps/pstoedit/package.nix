{
  stdenv,
  fetchurl,
  pkg-config,
  lib,
  zlib,
  ghostscript,
  imagemagick,
  plotutils,
  gd,
  libjpeg,
  libwebp,
  libiconv,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "pstoedit";
  version = "4.02";

  src = fetchurl {
    url = "mirror://sourceforge/pstoedit/pstoedit-${version}.tar.gz";
    hash = "sha256-VYi0MtLGsq2YKLRJFepYE/+aOjMSpB+g3kw43ayd9y8=";
  };

  outputs = [
    "out"
    "dev"
  ];
  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];
  buildInputs =
    [
      zlib
      ghostscript
      imagemagick
      plotutils
      gd
      libjpeg
      libwebp
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
    ];

  # '@LIBPNG_LDFLAGS@' is no longer substituted by autoconf (the code is commented out)
  # so we need to remove it from the pkg-config file as well
  preConfigure = ''
    substituteInPlace config/pstoedit.pc.in --replace '@LIBPNG_LDFLAGS@' ""
  '';

  postInstall = ''
    wrapProgram $out/bin/pstoedit \
      --prefix PATH : ${lib.makeBinPath [ ghostscript ]}
  '';

  meta = with lib; {
    description = "Translates PostScript and PDF graphics into other vector formats";
    homepage = "https://sourceforge.net/projects/pstoedit/";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.marcweber ];
    platforms = platforms.unix;
    mainProgram = "pstoedit";
  };
}
