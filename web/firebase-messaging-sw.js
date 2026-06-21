importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyAGM_g-zvOus0DkW8Xf9JZlzssz2pSydfY",
    authDomain: "craft-discount-liquors.firebaseapp.com",
    projectId: "craft-discount-liquors",
    storageBucket: "craft-discount-liquors.firebasestorage.app",
    messagingSenderId: "45695190400",
    appId: "1:45695190400:web:d01a9b4b21120e2fe82d65",
    measurementId: "G-WJ1MDQD4LP"
});


const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});