# Quick Start

<h4>From zero to your first modernization run in three steps.</h4>

---

## Before you start

<div class="grid cards" markdown>

-   <span class="card-title">:material-language-java: A Maven project</span>

    ---

    `pom.xml` at the root. Single- or multi-module.

-   <span class="card-title">:material-git: Its own git repo</span>

    ---

    `.git` next to `pom.xml`. If not, run `git init`.

-   <span class="card-title">:material-check-circle-outline: A passing build</span>

    ---

    `./mvnw clean install` succeeds today.

</div>

Run every command below from your **project root**.

---

<div class="steps" markdown>

## Check prerequisites

=== ":material-magnify: Check"

    ```bash
    curl -fsSL https://cortexaidevkit.org/pages/modernize/quick-start/check-prereqs.sh | bash
    ```

=== ":material-download: Install missing"

    ```bash
    curl -fsSL https://cortexaidevkit.org/pages/modernize/quick-start/check-prereqs.sh | bash -s -- --install
    ```

You're set when it prints **Ready.**

??? info "What the script checks"

    | Item | Why |
    | ---- | --- |
    | `claude` | Runs the pipeline |
    | `git` | Isolates builds and changes in worktrees |
    | `java` and `mvn` (or `./mvnw`) | Builds your project |
    | `jq` | Reads the pipeline's state files |
    | `python3` | Writes the determine-phase reports |
    | `bash` | Runs the pipeline's scripts |
    | `grype` *(optional)* | Vulnerability scan. Skipped without it |
    | `pom.xml` and `.git` | The project is Maven, in its own git repository |

    `--install` uses Homebrew on macOS, or `apt` / `dnf` on Linux. It installs JDK 21 if no JDK is
    found. To pick another, end the command with `| JDK_VERSION=25 bash -s -- --install`.

    Maven's JDK must be at least the Java version you upgrade to. The script prints it.

## Add the agent to your project

```bash
curl -fsSL https://github.com/paul58914080/java-springboot-modernization-claude-agent/archive/main.tar.gz \
  | tar -xz --strip-components=2 \
      java-springboot-modernization-claude-agent-main/final/CLAUDE.md \
      java-springboot-modernization-claude-agent-main/final/.claude
```

This adds `CLAUDE.md` and `.claude/` to your project.

!!! warning "Already have a `CLAUDE.md` or `.claude/`?"
    They will be overwritten. Back them up first, then merge your settings back into
    `.claude/settings.json`.

??? note "Optional: change the defaults"
    Edit the `env` block in `.claude/settings.json` **before** you start:

    - `MODERNIZATION_TESTABILITY_THRESHOLD` (default `80`): below this score, the test phase runs.
    - `MODERNIZATION_TARGET_JAVA_VERSION` and `MODERNIZATION_TARGET_SPRING_BOOT_VERSION`: the targets
      offered to you.

## Start the pipeline

```bash
claude
```

Then type:

```text
Start the modernization pipeline
```

</div>

---

!!! tip "What happens next"
    The pipeline pauses for your approval after each phase and asks which Java and Spring Boot
    versions to target. Nothing is committed to your branch. The upgrade lands on its own
    `modernization/*` branch for you to review and merge. See [About](../about/index.md) for how it works.
