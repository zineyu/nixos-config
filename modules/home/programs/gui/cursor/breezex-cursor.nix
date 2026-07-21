{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  resvg,
  clickgen,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "breezex-cursor";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "ful1e5";
    repo = "BreezeX_Cursor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-P9LgQb3msq6YydK5RIk5yykUd9SL2GQbC4aH4F8LUF0=";
  };

  nativeBuildInputs = [
    resvg
    clickgen
  ];

  buildPhase = ''
    runHook preBuild

    # Theme-specific color substitutions, matching the upstream render.json
    declare -A themes
    themes=(
      ["BreezeX-Dark"]="#00FF00 #4D4D4D #0000FF #FFFFFF"
      ["BreezeX-Black"]="#00FF00 #000000 #0000FF #FFFFFF"
      ["BreezeX-Light"]="#00FF00 #FFFFFF #0000FF #4D4D4D"
    )

    for theme in "''${!themes[@]}"; do
      read -r baseFrom baseTo outlineFrom outlineTo <<< "''${themes[$theme]}"
      outDir="bitmaps/$theme"
      install -dm 0755 "$outDir"

      find svg -type f -name '*.svg' -print0 | while IFS= read -r -d ''' svg; do
        name=''${svg#svg/}
        name=''${name%.svg}
        pngName=''${name##*/}
        tmpSvg=$(mktemp --suffix=.svg)
        sed \
          -e "s|$baseFrom|$baseTo|g" \
          -e "s|$outlineFrom|$outlineTo|g" \
          "$svg" > "$tmpSvg"
        resvg "$tmpSvg" "$outDir/$pngName.png"
        rm -f "$tmpSvg"
      done
    done

    mkdir -p themes
    for theme in BreezeX-Dark BreezeX-Black BreezeX-Light; do
      variant=''${theme#BreezeX-}
      ctgen configs/x.build.toml \
        -p x11 \
        -d "bitmaps/$theme" \
        -o themes \
        -n "$theme" \
        -c "Extended KDE $variant XCursors"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -dm 0755 $out/share/icons
    cp -r themes/BreezeX-* $out/share/icons/

    runHook postInstall
  '';

  meta = {
    description = "Extended KDE cursor theme";
    homepage = "https://github.com/ful1e5/BreezeX_Cursor";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
})
