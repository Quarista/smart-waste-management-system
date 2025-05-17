import { collection, doc, setDoc } from "firebase/firestore";
import { altDb } from "@/backend/logging/configSuite";

export const saveConsoleMessageToFirestore = async (type: string, message: string) => {
  try {
    const timestamp = new Date().toISOString();
    const docId = `log-${new Date().toLocaleString().replace(/[/,: ]/g, "-")}`; 
    const docRef = doc(collection(altDb, "consoleLogs"), docId);
    await setDoc(docRef, {
      timestamp,
      type,
      message,
    });
  } catch (error) {
    console.error("Error saving console message: ", error);
  }
};

export const saveProtocolMonitorMessageToFirestore = async (message: string) => {
  try {
    const timestamp = new Date().toISOString();
    const docId = `network-log-${new Date().toLocaleString().replace(/[/,: ]/g, "-")}`;
    const docRef = doc(collection(altDb, "protocolMonitorLogs"), docId);
    await setDoc(docRef, {
      timestamp,
      message,
    });
  } catch (error) {
    console.error("Error saving protocol monitor message: ", error);
  }
};