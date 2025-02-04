{ pkgs ? (import (import ../nix/sources.nix).nixpkgs {}) }:
let
  curl = "${pkgs.curl}/bin/curl";
  openssl = "${pkgs.openssl}/bin/openssl";
in pkgs.writeShellScriptBin "store_secret" ''
   export URL=$BAO_ADDR/v1/secret/data/$TEST_SECRET_NAME
   code=$(${curl} -H "x-vault-token: $OPENBAO_TOKEN" -s $URL --write-out '%{http_code}' -o /dev/null) # check if the secret exists. 
   echo "Secret check: $code"
   if [[ $code != 200 ]]; then
     export NEW_SECRET=$(${openssl} rand -base64 20) && \
       echo "Storing $NEW_SECRET as $TEST_SECRET_NAME" && \
       ${curl} \
         --header "X-Vault-Token: $OPENBAO_TOKEN" \
         --header "Content-Type: application/json" \
         --request POST \
         --data "{\"data\": {\"password\": \"$NEW_SECRET\"}}" \
         $URL && \
        echo "Secret $TEST_SECRET_NAME written successfully"
   else
     echo "$TEST_SECRET_NAME exists, nothing to do"
   fi 
'' 
