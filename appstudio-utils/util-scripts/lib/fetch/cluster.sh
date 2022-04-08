
k8s-save-data() {
  local kind=$1
  local name=$2
  local name_space=${3:-}

  local name_space_opt=
  [[ -n $name_space ]] && name_space_opt="-n$name_space"

  local file=$( json-data-file cluster $kind $name )

  echo "Saving $kind $name $name_space_opt"
  oc get $name_space_opt $kind $name -o json > $file
}

# Placeholder. In future it will likely come from
# an EnterpriseContractPolicy crd, see HACBS-244
save-policy-config() {
  echo '{"non_blocking_checks":["not_useful"]}' | jq > $( json-data-file config policy )
}
