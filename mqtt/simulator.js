const mqtt = require("mqtt");
const crypto = require("crypto");

const deviceId = "15b23a76-a26f-413d-b3af-87bf0fe6bc5c";
const baseLat = 5;
const baseLng = 5;

const client = mqtt.connect("mqtt://localhost:1883");

client.on("connect", () => {
  console.log(
    `Connected to local MQTT broker as simulator device: ${deviceId}`,
  );

  setInterval(() => {
    const dLat = Math.random() * 0.09 - 0.045;
    const dLng = Math.random() * 0.09 - 0.045;

    const payload = {
      device_id: deviceId,
      lat: baseLat + dLat,
      lng: baseLng + dLng,
      timestamp: new Date().toISOString(),
    };

    client.publish("tracker/devices/location", JSON.stringify(payload));
  }, 5000);
});

client.on("error", (err) => {
  console.error("MQTT error:", err);
});
