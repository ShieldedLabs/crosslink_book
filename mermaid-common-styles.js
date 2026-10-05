// Common Mermaid style definitions for reuse across diagrams
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// PoW blockchain styles
const POW_STYLES = `
    %% Define PoW block style with dark blue border and oval shape
    classDef pow fill:#fff,stroke:#01579b,stroke-width:3px,color:#000
    %% Define alternative PoW block style with orange fill for caution
    classDef powAlt fill:#ffcc80,stroke:#01579b,stroke-width:3px,color:#000
`;

// Crosslink finality styles, used together with the PoW styles above
const FINALITY_STYLES = `
    %% Define PoS / BFT block style with dark red border
    classDef bft fill:#fff,stroke:#b71c1c,stroke-width:3px,color:#000
    %% Define style for the BFT block that a PoW block's context_bft makes final, LF(H)
    classDef lf fill:#ffcdd2,stroke:#b71c1c,stroke-width:3px,color:#000
    %% Define style for a BFT proposal that the validity rules reject
    classDef rejected fill:#fff,stroke:#b71c1c,stroke-width:2px,stroke-dasharray:5 4,color:#000
    %% Define style for the PoW block that is candidate(H), with yellow fill
    classDef candidate fill:#ffeb3b,stroke:#01579b,stroke-width:3px,color:#000
    %% Define fin last, so that its border wins over the block style.
    classDef fin stroke:#8e24aa,stroke-width:7px
`;

// General node type styles
const NODE_STYLES = `
    classDef input fill:#e1f5ff,stroke:#01579b,stroke-width:3px,color:#000
    classDef compute fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000
    classDef aggregate fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000
    classDef output fill:#e8f5e9,stroke:#1b5e20,stroke-width:3px,color:#000
    classDef storage fill:#fce4ec,stroke:#880e4f,stroke-width:2px,color:#000
`;

// Export for use in other modules if needed
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        POW_STYLES,
        FINALITY_STYLES,
        NODE_STYLES
    };
}
