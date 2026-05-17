const mqtt = require("mqtt");

// Читаємо аргументи командного рядка
const env = process.argv[2] || "local";
const deviceId = process.argv[3] || "57e42626-fe35-48a9-b8a1-4f2ef8f0d1cc";

const baseLat = 5;
const baseLng = 5;

const brokerUrl =
  env === "hivemq" ? "mqtt://broker.hivemq.com:1883" : "mqtt://localhost:1883";

const client = mqtt.connect(brokerUrl);

client.on("connect", () => {
  console.log(`Connected to ${env} MQTT broker.`);
  console.log(`Simulating device: ${deviceId}`);

  setInterval(() => {
    const dLat = Math.random() * 0.09 - 0.045;
    const dLng = Math.random() * 0.09 - 0.045;

    const payload = {
      device_id: deviceId,
      lat: baseLat + dLat,
      lng: baseLng + dLng,
      timestamp: new Date().toISOString(),
    };

    client.publish("tracker/cojlogkuu_lab/location", JSON.stringify(payload));
    console.log(
      `[${new Date().toLocaleTimeString()}] Published data for: ${deviceId}`,
    );
  }, 5000);
});

client.on("error", (err) => {
  console.error("MQTT error:", err);
});
