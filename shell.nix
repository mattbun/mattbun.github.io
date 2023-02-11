with import <nixpkgs> { };
mkShell {
  nativeBuildInputs = [
    bashInteractive
    gnumake
    hugo
  ];
}
