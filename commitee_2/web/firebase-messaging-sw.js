importScripts("https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBAopioxqBbDbD3FmvZAB7Har-AL3AE7QA",
  authDomain: "commitee-app.firebaseapp.com",
  projectId: "commitee-app",
  storageBucket: "commitee-app.appspot.com",
  messagingSenderId: "138509251676",
  appId: "1:138509251676:web:a6c86e873580b0d590a299",
  measurementId: "G-3TSC478GQJ"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
}); 