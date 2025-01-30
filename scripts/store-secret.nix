{ pkgs ? (import (import ../nix/sources.nix).nixpkgs {}) }:
let
  curl = "${pkgs.curl}/bin/curl";
  openssl = "${pkgs.openssl}/bin/openssl";
in pkgs.writeShellScriptBin "store_secret" ''
   export NEW_SECRET=$(${openssl} rand -base64 20) && \
     echo "Generated $NEW_SECRET (stored under $TEST_SECRET_NAME)" && \
     curl \
       --header "X-Vault-Token: $OPENBAO_TOKEN" \
       --header "Content-Type: application/json" \
       --request POST \
       --data "{\"data\": {\"password\": \"$NEW_SECRET\"}}" \
       $BAO_ADDR/v1/secret/data/$TEST_SECRET_NAME && \
      echo "Secret $TEST_SECRET_NAME written successfully."
'' 
