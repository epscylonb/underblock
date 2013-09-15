require 'rubygems'
require 'yaml'
require 'bitcoin'
require 'sinatra'
require 'haml'
require 'sinatra/partial'

CONFIG_FILE = './config.yml'

set :bind, '0.0.0.0'

def get_config
  conf = YAML.load_file(CONFIG_FILE)
  conf2 = conf[:bitcoin]
  conf2 = conf2.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  conf2
end

def client
  #  options = { 
  #    #   :ssl => false,
  #    :host => 'localhost',
  #    :port => '8332',
  #    :user => 'bitcoinrpc', 
  #    :pass => '61Min6KjXruL9t6qQbHadLY3srftn8qjEQ39veqTfMuf' 
  #  }
  options = get_config
  p options
  p options[:host]
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
  Time.at(unixtime)
end

def get_blocks(n = 5)
  blocks = []
  bc = client.request 'getblockcount'
  s = bc - 5
  (s..bc).each do |bn|
    p bn
    hs = client.request 'getblockhash', bn
    block = client.request 'getblock', hs
    block['datetime'] = from_unixtime(block['time'])
    blocks << block 
  end
  blocks.reverse
end

def get_block_by_hash(block_hash)
  block = client.request 'getblock', block_hash
  block['datetime'] = from_unixtime(block['time'])
  block
end

def get_block(height)
  hs = client.request 'getblockhash', height
  get_block_by_hash(hs)
end

def get_txes(block, page)
  start,finish = page_range(page)

  txes = []
  block['tx'][start..finish].each do |tx|
    txes << get_tx(tx)
  end
  txes
end

def get_mempool_txes(mempool, page)
  start,finish = page_range(page)

  txes = []
  mempool[start..finish].each do |tx|
    txes << get_tx(tx)
  end
  txes
end

def get_tx(txid)
  t = client.request 'getrawtransaction', txid, 1
  t['datetime'] = from_unixtime(t['time']) if t['time']
  t
end

def can_get_blockcount?
  begin
    bc = client.request 'getblockcount'
  rescue
    return false
  end
  true
end

before do
  unless request.path == '/configure'
    redirect '/configure' unless File.exists?(CONFIG_FILE)
  end
end

get '/' do
  @blocks = get_blocks
  haml :index
end

get '/blocks/:height' do
  p params[:page]
  @page = (params[:page] || 1).to_i
  @block = get_block(params[:height].to_i) 
  @txes = get_txes(@block, @page.to_i)
  @max_pages = (@block['tx'].size / 20).to_i + 1
  p @max_pages
  haml :block
end

get '/blockhash/:hash' do
  @block = get_block_by_hash(params[:hash])
  redirect "/blocks/#{@block['height']}"
end

get '/transaction/:txid' do
  @tx = get_tx(params[:txid])
  @block = get_block_by_hash(@tx['blockhash']) 
  haml :transaction
end

get '/peers' do 
  @peers = client.request 'getpeerinfo'
  haml :peers
end

get '/mempool' do
  p params[:page]
  @page = (params[:page] || 1).to_i
  @mempool = client.request 'getrawmempool'
  @txes = get_mempool_txes(@mempool,@page)
  @max_pages = (@mempool.size / 20).to_i + 1
  haml :mempool
end

get '/configure' do 
  haml :configure
end

post '/configure' do 
  @errors = []
  File.write(CONFIG_FILE, {:bitcoin => params}.to_yaml)
  if !can_get_blockcount?
    @errors << "Could not fetch the blockcount with the given details"
    return haml :configure
  end
  redirect '/'
end

post '/search' do
 redirect "/transaction/#{params[:txid]}" if params[:txid] != ''
 redirect "/blocks/#{params[:blockheight]}" if params[:blockheight] != ''
 redirect "/blockhash/#{params[:blockhash]}" if params[:blockhash] != ''

 haml :index
end
