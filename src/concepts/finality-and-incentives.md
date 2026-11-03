# Finality & Incentives

The incentivization design of Crosslink follows this general principle:

> Anything involving Proof-of-Stake, such as calculating amount of rewards, changing the roster used in BFT, or withdrawing funds requires a finality update to take effect.

## PoS Action Validity Restricitons

The [Bond Actions and States](spec/bond-actions-and-states.md) chapter includes transaction validity restrictions aimed at supporting this general principle.

## Future Work

We need a way to compare trade-offs around incentive design, because it seems like there are always many possible hard-to-predict scenarios and impacts.

Address this concern:

- if rewards are only based on finalized roster state, then finalizers who can halt finality can use that to prevent others' pending deposits from taking effect which would dillute the rewards of those halting finalizers.

- if deposits can occur at any time regardless of finality, but withdrawals require finality updates, what concerns or drawbacks should we analyze about this?
