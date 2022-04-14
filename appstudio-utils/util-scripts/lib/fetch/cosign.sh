
chains-public-key() {
  # Todo: There should be another way to access the public key
  # other than having cluster access to the entire secret
  #
  echo "k8s://tekton-chains/signing-secrets"
}

# Todo:
# - Can we reuse the code in ../../../cosign-verify-attestation.sh
#   and ../../../cosign-verify.sh

cosign-signature() {
  local image_url="$1"
  local image_digest="$2"

  local output_file=$( json-data-file cosign signature $image_url $( shorten-sha $image_digest ))
  env COSIGN_EXPERIMENTAL=1 \
    cosign verify --key $(chains-public-key) "$image_url:$image_digest" |
      jq > "$output_file"
}

cosign-attestation() {
  local image_url="$1"
  local image_digest="$2"

  local output_file=$( json-data-file cosign attestation $image_url $( shorten-sha $image_digest ))

  env COSIGN_EXPERIMENTAL=1 \
    cosign verify-attestation --key $(chains-public-key) "$image_url:$image_digest" |
      jq > "$output_file"
}
