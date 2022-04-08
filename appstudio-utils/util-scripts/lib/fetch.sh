
# Determine useful directories
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # For hacking/testing
  ROOT_DIR=$(git rev-parse --show-toplevel)
else
  # For inside the container
  ROOT_DIR=
fi

SCRIPTS_DIR="$ROOT_DIR/appstudio-utils/util-scripts"
LIB_DIR="$SCRIPTS_DIR/lib"

# For these you can set the env vars to use non-default values
DEFAULT_EC_WORK_DIR=/tmp/ecwork
EC_WORK_DIR=${EC_WORK_DIR:-$DEFAULT_EC_WORK_DIR}

DEFAULT_POLICIES_REPO=https://github.com/hacbs-contract/ec-policies.git
POLICIES_REPO=${POLICIES_REPO:-$DEFAULT_POLICIES_REPO}

DEFAULT_POLICIES_REF=main
POLICIES_REF=${POLICIES_REF:-$DEFAULT_POLICIES_REF}

DEFAULT_DATA_DIR="$EC_WORK_DIR/data"
DATA_DIR=${DATA_DIR:-$DEFAULT_DATA_DIR}

DEFAULT_POLICIES_DIR="$EC_WORK_DIR/policies"
POLICIES_DIR=${POLICIES_DIR:-$DEFAULT_POLICIES_DIR}

# Pipeline run name
DEFAULT_PR_NAME=$( tkn pr describe --last -o name )
PR_NAME=${1:-$DEFAULT_PR_NAME}
PR_NAME=$( echo $PR_NAME | sed 's|.*/||' )

# Helper functions for fetching stuff
source $LIB_DIR/title.sh
source $LIB_DIR/fetch/data.sh
source $LIB_DIR/fetch/git.sh
source $LIB_DIR/fetch/rekor.sh
source $LIB_DIR/fetch/cluster.sh
source $LIB_DIR/fetch/tekton.sh
