## Solidity-Dev-Task - Omer Lerner

I have written notes for myself and whoever is reviewing this assignment to better understand the reasoning for
implementing the functions/interfaces in the solution.

## Interfaces ##

# Wormhole Anchor #

When Anchor was deployed on AVAX, when I first used it I noticed that after depositing UST, one of the TXs was to bridge UST
over to AVAX via the Wormhole Bridge to Terra. Therefor, implementing the Anchor strategy on AVAX requires us to bridge UST
to Terra.

For this reason, I have overridden _triggerDepositAction, _triggerWithdrawAction and _pullRewards to use the relevant functions
from this interface.

# Chainlink Aggregator #

In order to get the current price & conversation ratio for aUST/UST, using Chainlink's aggregator helps us do that easily.

For this reason, I have overridden receiptPerUnderlying, underlyingPerReceipt and totalHoldings so the functions in aUSTVault
utelize the aggregator in order to calculate the amount of UST currently in the vault, to see how much aUST I can get for 1 UST
and vice versa.

All three of these functions use the getCurrentPrice function, which uses the aggregator to get the current price of aUST in UST.

