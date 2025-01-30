let
  sources = import ./nix/sources.nix;
  sourcesNixpkgs = import sources.nixpkgs { };
in { pkgs ? sourcesNixpkgs, baoParamName ? "/local/portal/bao/devRootToken" }:
let
  baoSetup = import ./scripts/bao.nix { inherit pkgs; };
  secretSetup = import ./scripts/store-secret.nix { inherit pkgs; };
  secretRead = import ./scripts/read-secret.nix { inherit pkgs; };
  aws = "${pkgs.awscli2}/bin/aws";
in pkgs.mkShell {
  packages = with pkgs; [ openbao baoSetup secretSetup secretRead ];
  shellHook = ''
    # Add some common env. vars here. 
    export OPENBAO_TOKEN=$(${aws} ssm get-parameter --name "${baoParamName}" --with-decryption --query Parameter.Value) && \
    export BAO_ADDR="http://127.0.0.1:8200" # assuming standard bao address. 
    export TEST_SECRET_NAME="some-test-secret"
  '';
}
