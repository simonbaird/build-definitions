
git-fetch-policies() {
  local repo=${1:-$POLICIES_REPO}
  local sha=${2:-$POLICIES_REF}
  local directory="${3:-$POLICIES_DIR}"

  echo "Fetching policies from $sha at $repo"
  mkdir -p $directory
  cd $directory

  # Git clone would be ok, but this avoids downloading the
  # entire repo history
  git init -q .
  git fetch -q --depth 1 --no-tags $repo $sha
  git checkout -q FETCH_HEAD

  # Clean up files we don't need including .git
  rm -rf .git .github .gitignore README.md Makefile scripts
}
