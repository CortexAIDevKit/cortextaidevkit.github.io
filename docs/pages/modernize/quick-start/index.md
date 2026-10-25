# Quick Start

<h4>From zero to your first modernization run in four steps.</h4>

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
    | `python3` | Writes the reports, scores tests and edits `pom.xml` (determine, test and code phases) |
    | `bash` | Runs the pipeline's scripts |
    | `grype` *(optional)* | Vulnerability scan. Skipped without it |
    | `pom.xml` and `.git` | The project is Maven, in its own git repository |

    `--install` uses Homebrew on macOS, or `apt` / `dnf` on Linux. It installs JDK 21 if no JDK is
    found. To pick another, end the command with `| JDK_VERSION=25 bash -s -- --install`.

    You need **two JDKs** installed: the one your project builds on today and the one you upgrade to.
    They can be the same. The script prints the Java version your `pom.xml` declares. Once the
    pipeline is added, re-run the script to check both JDKs.

## Add the agent to your project

```bash
curl -fsSL https://github.com/CortexAIDevKit/java-springboot-modernize-claude-agent/archive/main.tar.gz \
  | tar -xz --strip-components=2 \
      java-springboot-modernize-claude-agent-main/final/CLAUDE.md \
      java-springboot-modernize-claude-agent-main/final/.claude
```

This adds `CLAUDE.md` and `.claude/` to your project.

!!! warning "Already have a `CLAUDE.md` or `.claude/`?"
    They will be overwritten. Back them up first, then merge your settings back into
    `.claude/settings.json`.

## Set your two JDKs

The pipeline builds your current code on the **current** JDK, and the upgraded code on the
**target** JDK. It switches between them itself. Set both in the `env` block of
`.claude/settings.json`. The shipped paths are placeholders, so the pipeline stops until you set them.

```json
"MODERNIZATION_CURRENT_JAVA_VERSION": "17",
"MODERNIZATION_CURRENT_JAVA_HOME": "/Users/you/.sdkman/candidates/java/17.0.19-tem",
"MODERNIZATION_TARGET_JAVA_VERSION": "25",
"MODERNIZATION_TARGET_JAVA_HOME": "/Users/you/.sdkman/candidates/java/25.0.3-tem"
```

Use the folder that contains `bin/java`. On macOS, `/usr/libexec/java_home -v 17` prints it. Each
version must match the JDK at its path, or the pipeline stops and names the mismatch. To keep
machine-specific paths out of git, put these four keys in `.claude/settings.local.json` instead.

Re-run the prerequisite script. It checks both JDKs.

??? note "Optional: change the defaults"
    Edit the `env` block in `.claude/settings.json` **before** you start:

    - `MODERNIZATION_TESTABILITY_THRESHOLD` (default `80`): below this score, the test phase runs.
    - `MODERNIZATION_TARGET_JAVA_VERSION` (default `25`) and `MODERNIZATION_TARGET_SPRING_BOOT_VERSION`
      (default `4.1`): the targets offered to you. Supported: Java `17`, `21`, `25`; Spring Boot `3.5`, `4.1`.

## Start the pipeline

```bash
claude
```

If Claude Code asks whether you trust this folder, accept. Otherwise it ignores
`.claude/settings.json` and every pipeline script stops to ask for approval.

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
