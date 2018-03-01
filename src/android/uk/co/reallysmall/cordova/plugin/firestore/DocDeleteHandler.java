package uk.co.reallysmall.cordova.plugin.firestore;


import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;

import org.apache.cordova.CallbackContext;
import org.json.JSONArray;
import org.json.JSONException;

import static uk.co.reallysmall.cordova.plugin.firestore.PluginResultHelper.createPluginResult;

public class DocDeleteHandler implements ActionHandler {

    private FirestorePlugin firestorePlugin;

    public DocDeleteHandler(FirestorePlugin firestorePlugin) {
        this.firestorePlugin = firestorePlugin;
    }

    @Override
    public boolean handle(JSONArray args, final CallbackContext callbackContext) {
        try {
            final String collectionPath = args.getString(0);
            final String doc = args.getString(1);


            Log.d(FirestorePlugin.TAG, "Deleting document");

            try {
                DocumentReference documentRef = firestorePlugin.getDatabase().collection(collectionPath).document(doc);
                Log.d(FirestorePlugin.TAG, "Get for document " + collectionPath + "/" + doc);

                documentRef.delete().addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        callbackContext.success(0);
                        Log.d(FirestorePlugin.TAG, "Successfully deleted document");
                    }
                }).addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.w(FirestorePlugin.TAG, "Error deleting document", e);
                        callbackContext.error(e.getMessage());
                    }
                });
            } catch (Exception ex) {
                Log.e(FirestorePlugin.TAG, "Error processing document delete in thread", ex);
            }

        } catch (JSONException e) {
            Log.e(FirestorePlugin.TAG, "Error processing document delete", e);
        }

        return true;
    }
}