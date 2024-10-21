# Introduction

In this milestone, we'll build a pool contract that can receive liquidity from users and make swaps within a price range.  To keep it as simple as possible, we'll provide liquidity only in one price range and we'll allow to make swaps only in one direction. Also, we'll calculate all the required math manually to get better intuition before starting to use mathematical libs in Solidity.

Let's model the situation we'll build:
1. There will be an ETH/USDC pool contract. ETH will be the \\(x\\) reserve, and USDC will be the \\(y\\) reserve.
1. We'll set the current price to 5000 USDC per 1 ETH.
1. The range we'll provide liquidity into is 4545-5500 USDC per 1 ETH.
1. We'll buy some ETH from the pool. At this point, since we have only one price range, we want the price of the trade
to stay within the price range.

Visually, this model looks like this:

![Buy ETH for USDC visualization](images/buy_eth_model.png)

Before getting to the code, let's figure out the math and calculate all the parameters of the model. To keep things simple, I'll do math calculations in Python before implementing them in Solidity. This will allow us to focus on the math without diving into the nuances of math in Solidity. This also means that, in smart contracts, we'll hardcode all the amounts. This will allow us to start with a simple minimal viable product.

For your convenience, I put all the Python calculations in [unimath.py](https://github.com/Jeiwan/uniswapv3-code/blob/main/unimath.py).

> You'll find the complete code of this milestone in [this Github branch](https://github.com/Jeiwan/uniswapv3-code/tree/milestone_1).

> If you have any questions, feel free to ask them in [the GitHub Discussion of this milestone](https://github.com/Jeiwan/uniswapv3-book/discussions/categories/milestone-1-first-swap)!