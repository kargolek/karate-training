function fn() {    
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
	baseUrl: 'https://api.trello.com/1/'
  }
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 5000);
  karate.configure('logPrettyRequest', true)
  karate.configure('logPrettyResponse', true)
  return config;
}