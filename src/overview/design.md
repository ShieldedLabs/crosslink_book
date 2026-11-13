# Crosslink Design

The `zebra-crosslink` design fleshes out and adapts the abstract [Crosslink 2](https://daira.github.io/tfl-book/design/crosslink.html) into a working implementation. This includes extending and adapting that construction to include a fully functional BFT protocol, and including staking mechanics, accounting, and associated security reasoning and arguments. Additionally, we explicitly alter some trade-offs, or terminology compared to the abstract construction.

This Design chapter focuses specifically on differences from pure PoW Zcash (using [`zebra`](https://zebra.zfnd.org/) as a reference implementation) and the Crosslink 2 construction. We assume basic familiarity with both. Also, please see our [Terminology](../concepts/terminology.md) for terms specific to this project.

## _WARNINGS_

- These extensions and changes from the [Crosslink 2](https://daira.github.io/tfl-book/design/crosslink.html) construction may violate some of the assumptions in the security proofs. This still needs to be reviewed after this design is more complete.
- We are using a custom-fit in-house BFT protocol for prototyping. It's own security properties need to be more thoroughly verified.
- All trade-off decisions need to be thoroughly vetted for market fit, while ensuring we maintain a minimum high bar for safety befitting Zcash's pedigree. Part of our implementation approach is to do rapid prototyping to explore the market fit more directly while modifying trade-offs in the design.

It is especially important that we identify deviations from Zcash PoW consensus, the [Crosslink 2](https://daira.github.io/tfl-book/design/crosslink.html) construction, and the upstream [`zebra`](https://zebra.zfnd.org/) implementation. In particular, it is important for us to clarify our rationale for deviation, which may fit one of these general categories:

- We _intentionally_ prefer a different trade-off to the original design; in which case we should have very explicit rationale documentation about the difference (in an ADR). One example (**TODO**: we may not use ADR format specifically, but the spirit of this needs to be fulfilled) is our ADR-0001 selects a different approach to on-chain signatures than (**TODO**: link to TFL section).
- Something about the more abstract design makes assumptions we cannot uphold in practice with all of the other implementation constraints. In this case, we need to determine if the upstream design needs to be improved, or we need to alter our implementation constraints.
- As an expedient, we found it quicker and easier to do something different to get the prototype working, even though we believe the upstream makes better trade-offs. These are prime candidates for improvement during productionization to match the design, or else require persuasive rationale that a "short cut" is worth the trade-offs and risks.
