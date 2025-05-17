import * as functions from 'firebase-functions';
import { db } from '../../src/backend/firebase';
import { altDb } from '../../src/backend/logging/configSuite';
import { collection, addDoc } from 'firebase/firestore';

// Example: Cloud function to monitor bin status and create alerts
export const monitorBinLevels = functions.firestore
  .document('Dustbins/{binId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();
    const binId = context.params.binId;

    // Check if fill level has crossed a threshold (e.g., 90%)
    if (newData.fillLevel >= 90 && previousData.fillLevel < 90) {
      try {
        await addDoc(collection(db, 'Alerts'), {
          binId: binId,
          message: `Bin ${binId} is almost full (${newData.fillLevel}%)`,
          timestamp: new Date().toISOString(),
          status: 'pending',
          fillLevel: newData.fillLevel
        });

        // Log the event
        await addDoc(collection(altDb, 'systemLogs'), {
        
          type: 'binAlert',
          message: `Alert created for bin ${binId} at ${newData.fillLevel}% capacity`,
          timestamp: new Date().toISOString()
        });

        return { success: true };
      } catch (error) {
        console.error('Error creating alert:', error);
        return { success: false, error };
      }
    }
    
    return null;
  });