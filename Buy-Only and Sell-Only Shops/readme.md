# Buy-Only and Sell-Only Shops

## Introduction
This script lets you call shops that only allow buying or selling. The default shop type is a normal shop that allows both buying and selling.

## Instructions
To get a shop that only allows buying or selling, you need to directly change the value of the variable $game_temp.shop_type using the "Script" event command. Valid values are 0 for a normal shop, 1 for a buy-only shop, and 2 for a sell-only shop. $game_temp.shop_type will automatically be changed back to 0 once the shop is cancelled.