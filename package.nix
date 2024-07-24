{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  name = "libnss_shim";

  src = fetchFromGitHub {
    owner = "xenago";
    repo = name;
    rev = "f9f8bb7";
    sha256 = "sha256-kTZoBpQH7KbmkKrpgt9Ou9/d35rIi3PA0LOgB2kg1FA=";
  };

  postInstall = ''
    mv "$out/libnss_shim.so" "$out/libnss_shim.so.2"
  '';

  cargoHash = "sha256-aZRu9MpU8oYeFMMzDWAvor8yAYZkXDe81GMt29ewcqs=";
}