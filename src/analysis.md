# Design Analysis

This chapter collects frameworks and results for analyzing the safety and security of the Crosslink design.

- [Penalty for Failure to Defend](./analysis/penalty-for-failure-to-defend.md) introduces our primary framework for _quantitative_ comparison of Crosslink's security properties against other consensus protocols.
- [Design Analysis History](./analysis/history.md) documents third-party reviews of the design, their scopes, and their results.

## Security Analysis of Crosslink 2

The abstract [Crosslink 2](https://daira.github.io/tfl-book/design/crosslink.html) construction which this design adapts (defined in [The Crosslink 2 Construction](https://daira.github.io/tfl-book/design/crosslink/construction.html)) has its own liveness and safety analysis in the TFL Book: [Security Analysis of Crosslink 2](https://daira.github.io/tfl-book/design/crosslink/security-analysis.html).

That analysis applies to the abstract construction, and the extensions and changes described in our [Design Overview](./overview/design.md) may violate some of its assumptions. Identifying where our design diverges from those assumptions is ongoing work.
