# docker-octodns

Custom [OctoDNS](https://github.com/octodns/octodns) container image that
extends the stock `octodns/octodns` image with the provider plugins our k3s
DNS deployment needs. The stock image ships the OctoDNS core but not every
provider, so this image layers the required providers on top with pinned
versions.

The image is **core + providers only** — no deployment configuration
(`config.yaml`, `subzone_source.py`, etc.) is baked in. Those are mounted at
runtime by the Kubernetes deployment via a ConfigMap.

## What's inside

Base image: [`octodns/octodns:2026.07`](https://hub.docker.com/r/octodns/octodns/tags)

Pinned Python packages (installed via `pip install --no-cache-dir`):

| Package              | Version  |
|----------------------|----------|
| `octodns`            | 1.21.0   |
| `octodns-bind`       | 1.1.0    |
| `octodns-cloudflare` | 1.2.0    |

> Note: the base `octodns/octodns:2026.07` image already ships these exact
> versions. We re-pin them explicitly so the build stays reproducible even if
> the floating base tag is updated upstream.

## Image reference (GHCR)

```
ghcr.io/alexmkx/docker-octodns:latest
```

Every build is also tagged with the full git SHA
(`ghcr.io/alexmkx/docker-octodns:sha-<40-char-sha>`), and tagged builds
additionally get semver tags (`:X.Y.Z` and `:X.Y`).

Pull by immutable digest in production:

```
ghcr.io/alexmkx/docker-octodns@sha256:<digest>
```

The digest is printed in the GitHub Actions run summary for each build, and can
also be found on the package page under *Packages*.

## CI/CD

`.github/workflows/build.yml` builds and pushes to GHCR on:

- push to `main` → `:latest` + `:sha-<sha>`
- push of a `v*` tag → `:X.Y.Z`, `:X.Y`, `:sha-<sha>`
- manual `workflow_dispatch`

Authentication uses the built-in `GITHUB_TOKEN` with `packages: write`
permission — no extra secrets required.

## Bumping versions

1. Check the latest releases on PyPI:
   - <https://pypi.org/project/octodns/>
   - <https://pypi.org/project/octodns-bind/>
   - <https://pypi.org/project/octodns-cloudflare/>
2. Optionally bump the base image tag (`FROM octodns/octodns:<tag>`) — see the
   [available tags](https://hub.docker.com/r/octodns/octodns/tags).
3. Edit the pinned versions in the `Dockerfile` and the table above.
4. Commit to `main` (CI publishes `:latest` + `:sha-<sha>`), or push a
   `vX.Y.Z` tag to cut a semver-tagged release.
5. Update the consuming k3s deployment to the new image digest.

## Cluster consumption / visibility

For the k3s cluster to pull this image without credentials, the GHCR package
must be set to **public** (Package settings → *Change visibility* → Public).
If the package is kept private, the cluster needs an `imagePullSecret` with a
token that has `read:packages` scope.
