Underblock
==========

Underblock is a simple blockchain explorer for bitcoin, inspired by the python equivalent [Overblock](https://github.com/realazthat/overblock).

Features
* Search by transaction id or block height/hash.
* Display mempool (unconfirmed) transactions.
* Display peerinfo.

Requirements
* Ruby
* Bundler Gem
* a bitcoind node with the txindex=1 config option specified.

To run it...

  `bundle intall`

  `ruby app.rb`

You need a bitcoind node for Underblock to retrieve blockchain data from, if the config doesn't exist Underblock will ask you for the info.

Why?
----

Mostly just for fun, I am fascinated by bitcoin and this has helped me learn more about it.

One reason why a private blockchain explorer might be useful is because at the moment most people use [blockchain.info](https://blockchain.info) to look up the balance of addresses they own, meaning .info could semi reliably link ip addresses to bitcoin addresses.

Other "full fat" block explorers unpack the blockchain and create indexes that aren't in the normal blockchain, this takes up a lot more disk space. 

At the moment Underblock doesn't do address lookups, bitcoind doesn't contain an address index for addresses outside the users wallet.  I plan to investigate this further, see how much space an address index will take up and see if there is anything that can be done to mitigate the space required.
