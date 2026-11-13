# Ledger State

The _Ledger State_ is a conceptual and practical data structure which can be computed by fully verifying nodes solely from the sequence of blocks starting from the genesis block.[^lazy-ledger-state] To this Ledger State, Crosslink introduces the _roster_, which contains all of the information about all ZEC staked to _finalizers_.

[^lazy-ledger-state]: Theoretically all of the Ledger State could be purely computed on demand from prior blocks, so literal Ledger State representations in memory can be thought of as chain indices or optimizing caches for verifying consensus rules. In some cases components of the Ledger State must be committed to within the blockchain state itself (for example, commitment anchors) which constrains how lazy a theoretical implementation can be. Real implementations trade off caching vs lazy-computation in a fine-grained way to achieve practical goals.

## The Roster

Crosslink's addition to Ledger State is embodied in the _PoS roster_, aka the _roster_ for short, which tracks [_delegation bonds_](../crosslink-design-overview-20260914.md#section-12) created by stakers and targeting specific finalizers. A finalizer's voting power is the sum of all bonds targeting it, and the top `N` finalizers by voting power form the _active roster_ (see [Finalizers and Rosters](../crosslink-design-overview-20260914.md#section-11)).

A finalizer is identified on-chain solely by its key and its published consent capability[^multi-key-finalizers]. People may mean a specific person, organization, entity, computer server, etc... when they say "finalizer", but in this book we use the term _finalizer_ as a shorthand for "whichever entity controls the keys for a given on-chain finalizer identity".

[^multi-key-finalizers]: Any particular entity may produce any number of finalizer identities of course, although for economic or social reasons, we expect many finalizers to be motivated to hang their reputation on one or just a few well-known identities.

Each bond is controlled by its own key, which enables retargeting, unbonding, and withdrawing that bond (a good wallet should manage these keys on behalf of users without their need to directly know or care about them for safe operation). These keys are unique to the bond itself and are not linked on-chain to a user's other bonds or other activity.

## Ledger State Invariants

We adopt a design invariant around the Ledger State changes Crosslink makes against mainnet Zcash:

> **General Ledger State Design Invariant:**
>
> All changes to Ledger State can be computed _entirely_ from (PoW) blocks, transactions, and data transitively referred to by such. This includes all existing Ledger State in mainnet Zcash today, the PoS roster state, and the _BFT finality status_ of blocks and transactions.

This matches the Design Overview's principle that all ledger state lives on the PoW chain, and every economic effect is computed from what the PoW chain can see through the fat pointer. Two nuances apply:

- A node's _local finality_ (`fin`) is deliberately _not_ Ledger State. It is node-local, monotone memory which depends on the history of that node's views, so consensus rules must never read it. See [Kinds of Finality](../crosslink-design-overview-20260914.md#section-10).
- A [social slashing](../crosslink-design-overview-20260914.md#section-16) configuration alters how the roster is computed. Every slash event is a hard fork, so this does not violate the invariant: within any given set of consensus rules, the roster remains a pure function of finalized PoW state.

All current mainnet Zcash Ledger State and almost all Crosslink Ledger State is _height-immediate Ledger State_: the value for height $H$ can be computed from height $H$ itself (and implicitly all prior heights and contents). Some examples of height-immediate values are the total ZEC issued, the UTXOs spendable by the same P2PKH t-addr, the block's zero-knowledge commitment anchor values, and so on. In Crosslink, examples include the bonds and their targets, and finalizer voting power.

### Height-Eventual Ledger State

Crosslink introduces a novel category of Ledger State not present in Zcash mainnet, which is _height-eventual Ledger State_. This is a property or value about height $H$ which is only computable at a later larger height (of which the implicit block at $H$ must be an ancestor). The sole example of this is _BFT finality status_.

The _BFT finality status_ of a block at height $H$ (and by extension any transactions it contains and all previous block contents) is a property which guarantees[^guarantees] to the verifying node that this block (and all txns and previous content) is _final_. Furthermore, the presence of this property also provides a guarantee that a supermajority of finalizers already agreed on the finality status of this block and also that *all verifying nodes* which see a sufficient number of subsequent blocks will also agree on the finality status.

[^guarantees]: In this book, whenever we say a protocol "guarantees" some condition, we mean that *so long as the security assumptions truly hold* verifying nodes can and should safely rely on that condition.

The _BFT finality status_ of a block at height $H$ (which we'll call a _finality-candidate block_ here for precision) is computable from a block at a later height $>H$ (which we'll call the _attesting block_), whose fat pointer refers to a BFT certificate finalizing the candidate. All verifying nodes who have observed *that* attesting block will agree on the finality of the candidate block _even though_ they may observe the attesting block roll back. In the event of such a rollback, the protocol guarantees that an alternative block will eventually attest to the finality status of the same candidate block.

## Finality, Transaction Semantics, Ledger State, and the Roster

It bears pointing out a nuance: the Ledger State, including the roster and the active roster, are all determined by valid transactions within PoW blocks. Every PoW block height thus has a specific unambiguous Ledger State. This comes into play when we consider _finality_, which is a property of a given block height which is only verifiable at a later block height, and when determining which Ledger State a given consumer should use. For example, the roster for a given BFT height is taken from the snapshot of the previously decided certificate rather than the PoW tip. See [Which Ledger State is Current](../crosslink-design-overview-20260914.md#section-10).
