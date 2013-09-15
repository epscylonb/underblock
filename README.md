Underblock
==========

Underblock is a simple blockchain explorer for bitcoin, inspired by the python equivalent [Overblock](https://github.com/realazthat/overblock).

Features
* Search by transaction id or block hash.
* Display mempool (unconfirmed) transaction.
* Display peerinfo

To run it...

  `bundle intall`
  `ruby app.rb`

You also need a bitcoind node for Underblock to retrieve blockchain data from, if the config doesn't exist Underblock will ask you for it.

Why?
----

Mostly just for fun, I am fascinated by bitcoin and this has helped me learn more about it.

One reason why a private blockchain explorer might be useful is because at the moment most people use [blockchain.info](https://blockchain.info) to look up the balance of addresses they own, meaning .info could semi reliably link ip addresses to bitcoin addresses.

Of course at the moment Underblock doesn't do address lookups, bitcoind doesn't contain an address index for addresses outside the users wallet (with good reason, it would increase the size of the blockchain).  I plan to investigate this further, see how much space an address index will take up and if there is anything that can be done to mitigate the space required.
