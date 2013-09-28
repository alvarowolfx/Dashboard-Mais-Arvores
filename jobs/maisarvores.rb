require 'json'
require 'httparty'

current_qtde_arvores = 0
current_qtde_carbono = 0
# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
class MaisArvores
  include HTTParty
  base_uri 'http://www.maisarvores.com.br/api'

  def initialize()
    @content = self.class.get('/terrain.json').parsed_response
  end

  def qtde_arvores()
    qtde = 0
    @content.each do |regis|
        qtde = qtde + regis['total_trees'] #if regis['total_trees'] < 1000
    end
    qtde
  end
  
  def ranking()
    h = {};
    @content.each do |regis|
        name = regis['user_name'] +' ' + regis['last_name']
        #next if regis['total_trees'] > 1000
        if(h[name] == nil) then
            h[name] = { label: name, value: regis['total_trees'] }
        else
            v = h[name][:value] +  regis['total_trees'] 
            h[name] = { label: name, value: v}  
        end
    end
    arr = h.values.sort { |a,b| b[:value] <=> a[:value] } 
    arr.slice(0..4)
  end
  
  def top_plantador()
    top = @content.first
    @content.each do |regis|
        
        #next if regis['total_trees'] > 1000
        if( top['total_trees'] < regis['total_trees'] ) then
            top = regis 
        end
    end
    [{ name: top['user_name'], body: top['total_trees'], avatar: top['user_image'] }]
  end

end
SCHEDULER.every '30s', :first_in => 0 do |job|
    client = MaisArvores.new
    last_qtde_arvores = current_qtde_arvores
    last_qtde_carbono = current_qtde_carbono
    current_qtde_arvores = client.qtde_arvores
    current_qtde_carbono = current_qtde_arvores * 150
    send_event('qtde_arvores', { current: current_qtde_arvores  , last: last_qtde_arvores })
    send_event('qtde_carbono', { current: current_qtde_carbono  , last: last_qtde_carbono })
    send_event('ranking', { items: client.ranking })
    send_event('top_plant', {comments: client.top_plantador })
end