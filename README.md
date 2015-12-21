# vital2mackerel

Post fitbit's vital data to mackerel.io.

You can monitor your heart breat rate.

You need your fitbit application and mackerel's API key.

```
% bundle install
% RESTCLIENT_LOG=stdout FITBIT_CLIENT_ID=*** FITBIT_CLIENT_SECRET=*** MACKEREL_API_KEY=*** bundle exec -- rerun -- thin start --port=9292 -R config.ru
% open http://localhost:9003/
```
