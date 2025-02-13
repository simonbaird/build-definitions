#!/bin/bash
#
# Verifies the given attestation passes the given rego policy
# usage:
#   verify-attestation-with-policy.sh <attestation file> <output file> <passed file>
# where:
#   <in-toto file> file containing the in-toto attestation to be verified
#   <output file>  where to store the result in JSON format
#   <passed file>  where to store the overall passing result
set -euo pipefail

in_toto="$1"
output="$2"
passed="$3"

# An in-toto attestation is authenticated metadata about one or more software
# artifacts, as per the SLSA Attestation Model:
# https://github.com/slsa-framework/slsa/blob/main/controls/attestations.md
# It is assumed at this point that the in-toto attestation has been fetched
# securely and all signature checks have passed, e.g. via cosign. Therefore,
# a policy is only applied to the embedded SLSA attestation.
#
# NOTE: By using "-s", jq will wrap the object in an array. If there is more
# than one attestation, each will be a distinct object in the array. This is
# convenient because "cosign verify-attestation" may output a stream containing
# multiple objects - not wrapped in an array.
attestations=$(jq -s '[.[].payload | @base64d | fromjson]' ${in_toto})

cd $(dirname $0)
source lib/fetch.sh

# TODO: If git clone fails, the task does not fail - fix that!
./fetch-ec-policies.sh

save-policy-config

title Attestations
# Show a shortened version of the attestations to avoid excessive logging
echo -n "$attestations" | jq -r '.[].predicate = "..."'
# Save the attestations for opa processing
echo -n "${attestations}" > $(json-data-file attestations)

title Violations
./check-ec-policy.sh | tee "${output}"

title "Passed?"
./ec-pass-fail.sh "${output}" | tee "${passed}"
