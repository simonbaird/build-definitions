
k8s-save-data() {
  local kind=$1
  local name=$2
  local namespace=${3:-}

  local namespace_opt=
  [[ -n $namespace ]] && namespace_opt="-n$namespace"

  local file=$( json-data-file cluster $kind $name )

  echo "Saving $kind $name $namespace_opt"
  oc get $namespace_opt $kind $name -o json > $file
}

# Placeholder. In future it will likely come from
# an EnterpriseContractPolicy crd, see HACBS-244
save-policy-config() {
  echo '{"non_blocking_checks":["not_useful"]}' | jq > $( json-data-file config policy )
}
