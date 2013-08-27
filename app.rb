require 'rubygems'
require 'bitcoin'
require 'sinatra'
require 'haml'

set :bind, '0.0.0.0'

def client
  options = { 
    #   :ssl => false,
    :host => 'localhost',
    :port => '8332',
    :user => 'bitcoinrpc', 
    :pass => '61Min6KjXruL9t6qQbHadLY3srftn8qjEQ39veqTfMuf' 
  }
  Bitcoin::API.new(options)
end

PREFIX = %W(TiB GiB MiB KiB B).freeze
def as_size( s )
  s = s.to_f
  i = PREFIX.length - 1
  while s > 512 && i > 0
    i -= 1
    s /= 1024
  end
  ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + PREFIX[i]
end

def page_range(page)
  limit = 20
  finish = page * limit
  start = finish - limit
  return [start, finish]
end 

def from_unixtime(unixtime)
  Time.at(unixtime).to_datetime
end

def get_blocks(n = 5)
  blocks = []
  bc = client.request 'getblockcount'
  p bc
  s = bc - 5
  (s...bc).each do |bn|7
    p bn
    hs = client.request 'getblockhash', bn
    block = client.request 'getblock', hs
    block['datetime'] = from_unixtime(block['time'])
    blocks << block 
  end
  blocks.reverse
end

def get_block(height)
  hs = client.request 'getblockhash', height
  client.request 'getblock', hs
end

def get_txes(block, page)
  start,finish = page_range(page)

  txes = []
  block['tx'][start..finish].each do |tx|
    p tx
    t = client.request 'getrawtransaction', tx, 1 
    t['datetime'] = from_unixtime(t['time'])
    txes << t
  end
  txes
end


get '/' do
  @blocks = get_blocks
  haml :index
end

get '/blocks/:height' do
  p params[:page]
  page = params[:page] || 1
  @block = get_block(params[:height].to_i)
  @txes = get_txes(@block, page.to_i)
  haml :block
end
  
