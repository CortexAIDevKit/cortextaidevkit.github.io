# CortexAIDevKit

Source for [cortexaidevkit.org](https://cortexaidevkit.org), built with [Zensical](https://zensical.org/) and managed with [uv](https://docs.astral.sh/uv/).

## Develop

```sh
uv sync          # install dependencies
./serve.sh       # live preview at http://localhost:8000
```

## Layout

| Path                      | What                                           |
| ------------------------- | ---------------------------------------------- |
| `zensical.toml`           | Site config and navigation                     |
| `docs/index.md`           | Home page, rendered by `overrides/home.html`   |
| `docs/pages/<kit>/`       | One folder per kit, e.g. `pages/modernize/`    |
| `overrides/`              | Theme template overrides                       |
| `docs/stylesheets/`       | Dark theme palette, typography and components  |

## Publish

`.github/workflows/pages.yml` builds the site on every push and pull request:

- **Push to `main`** replaces the site on the `gh-pages` branch.
- **Pull requests** publish a preview to `https://cortexaidevkit.org/pr-<number>/` and comment the link; it is removed when the PR closes.
