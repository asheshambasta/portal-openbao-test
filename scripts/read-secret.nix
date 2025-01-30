{ pkgs ? (import (import ../nix/sources.nix).nixpkgs {}) }:
let
  curl = "${pkgs.curl}/bin/curl";
in pkgs.writeShellScriptBin "read_secret" ''
   ${curl} \
     --header "X-Vault-Token: $OPENBAO_TOKEN" \
     $BAO_ADDR/v1/secret/data/$TEST_SECRET_NAME 
'' 
