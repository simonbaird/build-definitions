#!/usr/bin/bash
#
# Rough hacking guide:
#
#  * Commit your changes as required. (No need to push to github.)
#
#  * Push a new base image and new task bundles like this:
#      env MY_QUAY_USER=$USER BUILD_TAG=$(git rev-parse HEAD) ./build-and-push.sh
#
#    (Assumes you have the required repos created in quay.io, you're signed in there with podman,
#    and your quay.io username matches $USER)
#
#  * Make sure you have at least one pipeline run in your cluster.
#
#  * Run this script:
#      ./start-ec-tash.sh
#
#    To run it against a different pipeline run:
#      ./start-ec-tash.sh <pipeline-run-name>
#

PR_NAME=${1:-$( tkn pr describe --last -o name )}
PR_NAME=$( echo $PR_NAME | sed 's#.*/##' )
GIT_SHA=$( git rev-parse HEAD )

#
# Actually these only need to be created once...
#
echo "
apiVersion: v1
kind: ServiceAccount
metadata:
  name: enterprise-contract-sa
---
# TODO: Reduce these permissions
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: enterprise-contract
rules:
- apiGroups:
  - 'tekton.dev'
  resources:
  - '*'
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: enterprise-contract
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: enterprise-contract
subjects:
- kind: ServiceAccount
  name: enterprise-contract
  namespace: tekton-chains
" | oc apply -f -

#
# Create the taskrun
#
echo "apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: enterprise-contract-
spec:
  taskRef:
    name: enterprise-contract
    bundle: quay.io/$USER/appstudio-tasks:$GIT_SHA-1
  params:
    - name: PIPELINE_RUN_NAME
      value: $PR_NAME
  # Todo: Not sure if we need this...
  workspaces:
    - name: sslcertdir
      secret:
        secretName: chains-ca-cert
" | oc create -f -

#
# Watch the taskrun that was created
#
tkn tr logs -f $( tkn tr describe --last -o name | sed 's|.*/||' )
