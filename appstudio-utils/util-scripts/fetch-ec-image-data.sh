#!/usr/bin/bash
set -euo pipefail

#
# Fetch data about a particular container image
# using cosign and rekor
#
source $(dirname $0)/lib/fetch.sh

IMAGE_URL="${1}"
IMAGE_DIGEST="${2}"
REKOR_HOST=${3:-rekor.sigstore.dev}

[[ -z $IMAGE_URL ]] && "Image url required!" && exit 1
[[ -z $IMAGE_DIGEST ]] && "Image digest required!" && exit 1

# Ensure there's no stale data
clear-data

title "Fetching policy config"
save-policy-config

title "Verifying and saving signature and attestation using cosign"
cosign-signature $IMAGE_URL $IMAGE_DIGEST
cosign-attestation $IMAGE_URL $IMAGE_DIGEST

# Todo:
# - Maybe we can extract the value of REKOR_HOST from the cosign attestation
# - Maybe we can skip this entirely since cosign already verified it and
#   I'm not sure the rekor data adds anything we don't have already.
#
title "Looking up digest $IMAGE_DIGEST on $REKOR_HOST"
rekor-digest-save $IMAGE_DIGEST https://$REKOR_HOST

title "Data files"
show-data
