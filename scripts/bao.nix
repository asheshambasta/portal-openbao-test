{ pkgs ? (import (import ../nix/sources.nix).nixpkgs {}) }:
let
  aws = "${pkgs.awscli2}/bin/aws";
  # the following steps need to be taken:
  # AWS Credentials must be set up, or we should be running under some sort of IAM role
  # Generate a KMS key & grant decrypt permission to the IAM role 
  # AWS SSM parameter store should have a dev root token (see below), this key should be readable by the role
in pkgs.writeShellScriptBin "bao_setup" ''
  # first, we get the dev token (encrypted by an KMS key that our role can access) 
  # IAM credentials can be provided in multiple ways. Here we'll just employ the "discover" method. 
  # /local/portal/bao/devRootToken
  # PARAM_NAME=$1
  # echo "Getting dev-root-token-id $PARAM_NAME"
  echo "Starting the server in dev mode"
  # OPENBAO_TOKEN=$(${aws} ssm get-parameter --name "$PARAM_NAME" --with-decryption --query Parameter.Value) && \
  ${pkgs.openbao}/bin/bao server -dev -dev-root-token-id=$OPENBAO_TOKEN
''
