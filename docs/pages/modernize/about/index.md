<div class="hero" markdown>

<span class="hero__eyebrow">:material-language-java: Java · Spring Boot · Claude agents</span>

# Keep every Java service current. **Without the heroics.**

<p class="hero__lead">An orchestrated pipeline of Claude agents that upgrades Java and Spring Boot services consistently, safely and repeatably, with a human approving every step.</p>

<div class="hero__actions" markdown>

[:material-rocket-launch: Quickstart](../quick-start/index.md){ .md-button .md-button--primary }
[See how it works :material-arrow-down:](#how-it-works){ .md-button }

</div>

<div class="motto motto--overview" markdown>

:material-sitemap-outline: **Orchestrator** <span>Coordinates</span>

- :material-magnify: **Discover** <span>Collects</span>
- :material-scale-balance: **Determine** <span>Plans</span>
- :material-test-tube: **Test** <span>Strengthens</span>
- :material-code-braces: **Code** <span>Upgrades</span>

</div>

</div>

<span class="eyebrow">01 · The problem</span>

## Every enterprise has that one service nobody wants to upgrade { #the-problem }

<div class="symptoms" markdown>

- :material-coffee-outline: Still on **Java 8**
- :material-package-variant-closed-remove: Half its dependencies are **past end-of-life**
- :material-account-off-outline: The person who understood the build **left two years ago**
- :material-cake-variant-outline: The upgrade ticket is old enough to **have an anniversary**

</div>

<p class="kicker">Now multiply that by <strong>hundreds of repositories</strong>.</p>

### Why it never gets prioritized

<div class="versus" markdown>

<div markdown>

<span class="versus__label">:material-briefcase-outline: The business sees</span>

- No new feature
- No visible change for customers
- "Fixes some vulnerabilities"

</div>

<div markdown>

<span class="versus__label">:material-wrench-outline: Engineering sees</span>

- Weeks of careful work
- A risky, poorly tested build
- A growing pile of CVEs

</div>

</div>

It sounds like a chore, so it **loses to the roadmap every time**.

### What changed

Frontier models like Claude Mythos made finding vulnerabilities fast and cheap. In Anthropic's **Project Glasswing**, partners found:

<div class="stat" markdown>
<span class="stat__value">10,000+</span>
<span class="stat__label">high and critical issues, in a single month</span>
</div>

The bottleneck was not detection. It was **verifying and shipping the patches**.

!!! note "The new reality"

    **Finding the holes is fast now. Fixing them is the slow part.**

If defenders find flaws at that pace, attackers will too. When a patch lands, how fast you can apply it depends on **how current your stack is**:

```mermaid
flowchart LR
    CVE([🚨 Vulnerability disclosed]) --> PATCH[📦 Patched library released]
    PATCH --> Q{Is your stack current?}
    Q -- Yes --> FAST[Bump version<br/>run tests<br/>ship]
    Q -- "No, 3 majors behind" --> SLOW[Forced migration<br/>you postponed for years]
    FAST --> SAFE([✅ Patched in days])
    SLOW --> RISK([⚠️ Exposed for weeks or months])

    classDef good fill:#1f6f43,stroke:#2ea043,color:#fff
    classDef bad fill:#7a1f1f,stroke:#f85149,color:#fff
    class FAST,SAFE good
    class SLOW,RISK bad
```

<p class="kicker">Staying current isn't hygiene anymore. <strong>It's how fast you can respond when it matters.</strong></p>

Upgrading *one* app isn't hard. Doing it **consistently, safely and repeatedly across a portfolio** is, and it eats senior engineering time.

<span class="eyebrow">02 · How it works</span>

## A controlled workflow, not one giant prompt { #how-it-works }

Not a single prompt that says *"upgrade my app"*. Each agent has **one job**, and **a human approves every phase** before the next one starts.

<div class="grid cards phases" markdown>

-   <span class="card-title">:material-magnify: [Discover](../discover/index.md)</span>

    ---

    **Collects** a factual inventory of dependencies, versions, vulnerabilities and test coverage. Changes nothing.

-   <span class="card-title">:material-scale-balance: [Determine](../determine/index.md)</span>

    ---

    **Plans** the upgrade from that evidence, and scores whether your tests are strong enough to trust it.

-   <span class="card-title">:material-test-tube: [Test](../test/index.md)</span>

    ---

    **Strengthens** weak tests, round by round on its own branch, before anything is upgraded.

-   <span class="card-title">:material-code-braces: [Code](../code/index.md)</span>

    ---

    **Upgrades** Java, Spring Boot and dependencies, one verified commit at a time.

</div>

The [Orchestrator](../orchestrator/index.md) ties the phases together, persists state between them and pauses for your approval. Nothing is merged or pushed: the result is a branch for your team to review.

<span class="eyebrow">03 · Why this approach</span>

## Tools do the work. The model does the thinking. { #why-this-approach }

Most of the pipeline is **deterministic**. Anything with a known right answer is handled by proven tools, not worked out by the model each time. The LLM reasons only where there is a real need.

<div class="engines" markdown>

<div markdown>

<span class="engines__tag">Deterministic</span>

### :material-auto-fix: OpenRewrite

Recipes rewrite the Java code for the target Java and Spring Boot versions. The same migration, applied the same way, every time.

</div>

<div markdown>

<span class="engines__tag">Deterministic</span>

### :material-console: Bash and Python scripts

Run the Maven scans, reconcile dependencies and plugins, compute the testability score, track state and verify every build.

</div>

<div markdown>

<span class="engines__tag engines__tag--judgment">Judgment</span>

### :material-brain: Claude

Writes the plan from the reports, writes tests that assert real behaviour, and summarises each report for you to approve.

</div>

</div>

<div class="benefits" markdown>

- :material-cash-minus:

    **Fewer tokens, lower cost**

    Reasoning is spent on judgment, not on work a tool already does reliably.

- :material-repeat:

    **Reproducible**

    Same input, same output. Scans, scores and rewrites don't vary between runs.

- :material-source-commit:

    **Reviewable**

    Plans are approved before code changes. Changes land as small, verified commits.

- :material-lightning-bolt-outline:

    **Fast**

    Scans run in parallel and the analysis scripts finish in seconds.

</div>

<p class="kicker">The model thinks only where there is a real need. <strong>Fewer tokens, lower cost, and results you can reproduce.</strong></p>

### What it unlocks

<div class="before-after" markdown>

| Before | | After |
| ------ |:-:| ----- |
| Every upgrade done differently | :material-arrow-right: | **Same playbook** every time |
| Long gap between *patch released* and *patch deployed* | :material-arrow-right: | **Shorter** exposure window |
| Surprises discovered in the diff | :material-arrow-right: | Plans reviewed **before** code changes |
| Test gaps found in production | :material-arrow-right: | Test gaps found **up front** |
| "Why did we change this?" | :material-arrow-right: | **Audit trail** of what changed and why |
| Seniors hand-editing `pom.xml` | :material-arrow-right: | Seniors **reviewing** changes |
| An LLM reasoning through every step | :material-arrow-right: | Tokens spent **only on judgment** |

</div>

!!! warning "What it is not"

    **Not** a magic *"modernize everything"* button. Humans still **approve the plan** and **review the PRs**. The goal is to take the repetitive, error-prone work off people's plates, **not the judgment**.

<div class="cta" markdown>

## Try it on your project

From zero to your first modernization run in three steps.

[:material-rocket-launch: Quick start](../quick-start/index.md){ .md-button .md-button--primary }
[:material-sitemap-outline: Meet the orchestrator](../orchestrator/index.md){ .md-button }

</div>
