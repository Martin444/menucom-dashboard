importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

const firebaseConfig = {
    apiKey: "AIzaSyAEWpBCNon00zwt1eWfqSDiYMhH0xxLMwk",
    authDomain: "menucom-ff087.firebaseapp.com",
    projectId: "menucom-ff087",
    storageBucket: "menucom-ff087.firebasestorage.app",
    messagingSenderId: "1053737382833",
    appId: "1:1053737382833:web:d4173f40d6b88a52900390",
    measurementId: "G-D5ZC2VB6GR"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/logomenucom.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
