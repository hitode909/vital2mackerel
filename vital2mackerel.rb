class Vital2MackerelApp < Sinatra::Base
  configure do
    use OmniAuth::Builder do
      provider :fitbit_oauth2, ENV['FITBIT_CLIENT_ID'], ENV['FITBIT_CLIENT_SECRET'],
               :scope => 'profile heartrate',
               :expires_in => '2592000'
    end
  end

  helpers do
    def measure(date)
      warn "measure #{date}"

      res = JSON.parse RestClient.get "https://api.fitbit.com/1/user/-/activities/heart/date/#{date.strftime("%Y-%m-%d")}/1d.json", :Authorization => "Bearer #{session[:access_token]}"

      metrics = res["activities-heart-intraday"]['dataset'].map{|data|
        epoch = Time.parse("#{date.strftime("%Y-%m-%d")} #{data['time']}").to_i
        {
          name:  'heartbeat',
          value: data['value'],
          time:  epoch,
        }
      }

      warn "posting #{metrics.length} items"

      return false unless metrics.length > 0

      RestClient.post "https://mackerel.io/api/v0/services/vital/tsdb", metrics.to_json, 'Content-Type' => 'application/json', 'X-Api-Key' => ENV['MACKEREL_API_KEY']

      <<HTML
<html>
<meta http-equiv="refresh" content="60;URL=/">
<body><h1>Hi, #{ session[:user_name] }</h1><p>#{ Time.now }</p><p>monitored <code>#{ res["activities-heart-intraday"]['dataset'].last.to_json }</code></p>
HTML
    rescue => e
      warn e
      redirect to '/auth/fitbit_oauth2'
    end
  end

  get '/' do
    if session[:access_token]
      measure(Time.now)
    else
      redirect to '/auth/fitbit_oauth2'
    end
  end

  get '/collect' do
    date = Time.now
    loop do
      last unless measure(date)
      date -= 3600*24
      warn 'sleep'
      sleep 60
    end

    'collect done'
  end

  get '/auth/fitbit_oauth2/callback' do
    session[:user_name] = env['omniauth.auth']['info']['display_name']
    session[:access_token] = env['omniauth.auth']['credentials'].token

    redirect to '/'
  end

  get '/logout' do
    session.clear
    redirect to('/')
  end
end
