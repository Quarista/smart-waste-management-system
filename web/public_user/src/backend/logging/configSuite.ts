import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";
import { getFunctions } from "firebase/functions";
import { getAnalytics } from "firebase/analytics";

const altFirebaseConfig = {
    apiKey: import.meta.env.VITE_LOG_FIREBASE_API_KEY,
    authDomain: import.meta.env.VITE_LOG_FIREBASE_AUTH_DOMAIN,
    projectId: import.meta.env.VITE_LOG_FIREBASE_PROJECT_ID,
    storageBucket: import.meta.env.VITE_LOG_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: import.meta.env.VITE_LOG_FIREBASE_MESSAGING_SENDER_ID,
    appId: import.meta.env.VITE_LOG_FIREBASE_APP_ID,
    measurementId: import.meta.env.VITE_LOG_FIREBASE_MEASUREMENT_ID
};


const altApp = initializeApp(altFirebaseConfig, "altApp");
const altDb = getFirestore(altApp);
const altAuth = getAuth(altApp);
const altAnalytics = getAnalytics(altApp);
const altStorage = getStorage(altApp);
const altFunctions = getFunctions(altApp);

export { 
  altApp, 
  altDb, 
  altAuth, 
  altStorage, 
  altFunctions, 
  altFirebaseConfig, 
  altAnalytics 
};