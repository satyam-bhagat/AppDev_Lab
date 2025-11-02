
// src/config/firebase.js
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "AIzaSyCXaWLkvv78sUPKmAGSYqwPhzNY7nMHRGM",
  authDomain: "expo-auth-app-25d62.firebaseapp.com",
  projectId: "expo-auth-app-25d62",
  storageBucket: "expo-auth-app-25d62.firebasestorage.app",
  messagingSenderId: "15205713327",
  appId: "1:15205713327:web:c02ed2be2f6ae1066d5b5a"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export default app;
