const mqtt = require('mqtt');
const client = mqtt.connect('ws://127.0.0.1:9001');

client.on('connect', function () {
  console.log('Connected via WS!');
  client.end();
});

client.on('error', function (err) {
  console.error('WS Error:', err);
  client.end();
});
