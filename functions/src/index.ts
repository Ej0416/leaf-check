/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable max-len */
/* eslint-disable require-jsdoc */
/* eslint-disable object-curly-spacing */
import { firestore } from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import * as functions from "firebase-functions";
import firebaseAccountCredentials from "./serviceAccountKey.json";
import admin = require("firebase-admin");

const serviceAccount = firebaseAccountCredentials as admin.ServiceAccount;

const firebaseConfig = {
  apiKey: "AIzaSyDC7YhEinqmRCrvUtZJOQfi1jp93EP-C9U",
  authDomain: "leaf-check-storage.firebaseapp.com",
  projectId: "leaf-check-storage",
  storageBucket: "leaf-check-storage.appspot.com",
  messagingSenderId: "30747254339",
  appId: "1:30747254339:web:788d6275215025178b7ef6",
};

admin.initializeApp({
  ...firebaseConfig,
  credential: admin.credential.cert(serviceAccount),
});

// console.log(serviceAccount);

const fs = firestore();

exports.saveCurrentWeatherCF = functions.pubsub
  .schedule("0 * * * *")
  .timeZone("Asia/Manila")
  .onRun(async () => {
    try {
      saveCurrentWeatherBased();
    } catch (error) {
      console.error("Error in scheduled function:", error);
    }

    return null;
  });


async function saveCurrentWeatherBased() {
  const response = await fetch( "https://api.openweathermap.org/data/2.5/weather?q=panabo&appid=3ccbe80410b1da653384fb1b8b4b2172&units=metric");
  const data = await response.json();

  const rain = data["rain"] && data["rain"]["1h"] ? data["rain"]["1h"] : 0;

  await fs.collection("daily_weather").add({
    date: FieldValue.serverTimestamp(),
    temp: data["main"]["temp"],
    temp_min: data["main"]["temp_min"],
    temp_max: data["main"]["temp_max"],
    pressure: data["main"]["pressure"],
    humidity: data["main"]["humidity"],
    wind_speed: data["wind"]["speed"],
    clouds_all: data["clouds"]["all"],
    rain: rain,
  });

  // await fs.collection("daily_weather_per_hour").add({
  //   // data,
  //   date: FieldValue.serverTimestamp(),
  //   temp: data["main"]["temp"],
  //   temp_min: data["main"]["temp_min"],
  //   temp_max: data["main"]["temp_max"],
  //   pressure: data["main"]["pressure"],
  //   humidity: data["main"]["humidity"],
  //   wind_speed: data["wind"]["speed"],
  //   clouds_all: data["clouds"]["all"],
  //   rain: rain,
  // });
}

