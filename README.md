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
