// Import the functions you need from the SDKs you need
import { getAnalytics } from "firebase/analytics";
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCrIusq0ei7JRoRgxchbxIIb-MY-aXCmII",
  authDomain: "todoapp-36c33.firebaseapp.com",
  projectId: "todoapp-36c33",
  storageBucket: "todoapp-36c33.firebasestorage.app",
  messagingSenderId: "338216270747",
  appId: "1:338216270747:web:9935ef03d1de8070c33f3e",
  measurementId: "G-DX70H1E2KQ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

// Initialize Firestore
export const db = getFirestore(app);