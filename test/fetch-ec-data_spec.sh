#!/usr/bin/env bash

eval "$(shellspec -)"

# Avoid running real tkn command in fetch.sh
tkn() {
  echo "dummy-tkn-response"
}

Include ./appstudio-utils/util-scripts/lib/fetch.sh

Describe 'json-data-file'
  local root_dir=$( git rev-parse --show-toplevel )
  local data_dir="/tmp/ecwork/data"

  It 'produces expected json file paths'
    When call json-data-file some dir 123 foo 456
    The output should eq "$data_dir/some/dir/123/foo/456/data.json"
  End
End

Describe 'rekor-log-entry'
  rekor-cli() {
    echo "rekor-cli $*"
  }

  It 'calls rekor-cli as expected'
    When call rekor-log-entry 1234 rekor.example.com
    The output should eq "rekor-cli get --log-index 1234 --rekor_server https://rekor.example.com --format json"
  End
End

# We're not testing the data itself, but I think it's okay
#
Describe 'rekor-log-entry-save'
  json-data-file() {
    echo "/dev/null"
  }

  # Mock some fake rekor data
  rekor-log-entry() {
    if [[ $1 == 1235 ]]; then
      # With an attestation
      echo '{"foo":"bar","Attestation":"'$( echo '{"hey":"now"}' | base64 )'"}'
    else
      # Without an attestation
      echo '{"foo":"bar","Attestation":""}'
    fi
  }

  It 'saves rekor data without an attestation'
    When call rekor-log-entry-save 1234 rekor.example.com
    The output should eq "Saving log index 1234 from rekor.example.com"
  End

  It 'saves rekor data with an attestation'
    When call rekor-log-entry-save 1235 rekor.example.com
    The line 1 should eq "Saving log index 1235 from rekor.example.com"
    The line 2 should eq "Saving attestation extracted from rekor data"
  End


  # Put data in a file so we can look at it
  local tmp_file=$(mktemp)
  json-data-file() {
    echo $tmp_file
  }

  It 'saves log entry data'
    rekor-log-entry-save 1234 rekor.example.com > /dev/null
    When run cat $tmp_file
    The line 1 should eq '{'
    The line 2 should eq '  "foo": "bar",'
    The line 3 should eq '  "Attestation": ""'
    The line 4 should eq '}'
  End

  It 'saves attestation data'
    rekor-log-entry-save 1235 rekor.example.com > /dev/null
    When run cat $tmp_file
    The line 1 should eq '{'
    The line 2 should eq '  "hey": "now"'
    The line 3 should eq '}'
  End

End

Describe 'git-fetch-policies'
  git() {
    echo "git $*"
  }

  local repo=hacbs-contract
  local ref=main

  It 'does a git fetch'
    When call git-fetch-policies
    The line 1 should eq "Fetching policies from $ref at https://github.com/$repo/ec-policies.git"
    The line 2 should eq "git init -q ."
    The line 3 should eq "git fetch -q --depth 1 --no-tags https://github.com/$repo/ec-policies.git $ref"
    The line 4 should eq "git checkout -q FETCH_HEAD"
  End


End

# Todo: Coverage for lib/fetch/cluster

# Todo: Coverage for liblib/fetch/tekon
