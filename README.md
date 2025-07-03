# conforma/build-definitions

This repo is used by a workflow in
[conforma/infra-deployments-ci][ci] to create [automated PRs][prs] in
the [redhat-appstudio/build-definitions][upstream] repo[^1].

[ci]: https://github.com/conforma/infra-deployments-ci
[prs]: https://github.com/konflux-ci/build-definitions/pulls?q=is%3Apr+author%3Aapp%2Fec-automation
[upstream]: https://github.com/konflux-ci/build-definitions

[^1]: The build-definitions PRs are no longer being triggered regularly
    since the digest bumps are now handled by Renovate, however it can
    still be triggered manually if required.
