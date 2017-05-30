package com.sleed.valentin.sharebox;

import android.app.Activity;
import com.chilkatsoft.*;

import android.content.Context;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

public class SFTPsender extends Activity {

    private static final String TAG = "Chilkat";

    // Called when the activity is first created.
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sftpsender);

        Button buttonDisconnect = (Button) findViewById(R.id.buttonDisconnect);
        WifiManager mainWifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);
        String SSID = mainWifi.getConnectionInfo().getSSID();
        if(SSID.contains("ShareBox")) {
            buttonDisconnect.setText(getString(R.string.connect_to) + SSID);
        } else buttonDisconnect.setText(getString(R.string.disconnected));
    }

    public void onConfirm(View view) {
        EditText editText = (EditText) findViewById(R.id.pathText);
        String filePath = editText.getText().toString();
        int beginFileName = filePath.lastIndexOf("/") + 1;
        int endFileName = filePath.length();
        String fileName = filePath.substring(beginFileName, endFileName);
        upload(filePath, fileName);
    }

    public void upload(String filePath, String fileName) {
        //  Important: It is helpful to send the contents of the
        //  sftp.LastErrorText property when requesting support.

        CkSFtp sftp = new CkSFtp();

        //  Any string automatically begins a fully-functional 30-day trial.
        boolean success = sftp.UnlockComponent("Anything for 30-day trial");
        if (success != true) {
            Log.i(TAG, sftp.lastErrorText());
            return;
        }

        //  Set some timeouts, in milliseconds:
        sftp.put_ConnectTimeoutMs(5000);
        sftp.put_IdleTimeoutMs(10000);

        //  Connect to the SSH server.
        //  The standard SSH port = 22
        //  The hostname may be a hostname or IP address.
        int port;
        String hostname;
        hostname = "192.168.42.1";
        port = 22;
        success = sftp.Connect(hostname,port);
        if (success != true) {
            Log.i(TAG, sftp.lastErrorText());
            return;
        }

        //  Authenticate with the SSH server.  Chilkat SFTP supports
        //  both password-based authenication as well as public-key
        //  authentication.  This example uses password authenication.
        success = sftp.AuthenticatePw("uploader","uploadpassword");
        if (success != true) {
            Log.i(TAG, sftp.lastErrorText());
            return;
        }

        //  After authenticating, the SFTP subsystem must be initialized:
        success = sftp.InitializeSftp();
        if (success != true) {
            Log.i(TAG, sftp.lastErrorText());
            return;
        }

        //  Open a file for writing on the SSH server.
        //  If the file already exists, it is overwritten.
        //  (Specify "createNew" instead of "createTruncate" to
        //  prevent overwriting existing files.)
        String handle;
        handle = sftp.openFile(fileName,"writeOnly","createTruncate");
        if (handle == null ) {
            Log.i(TAG, sftp.lastErrorText());
            return;
        }

        //  Upload from the local file to the SSH server.
        success = sftp.UploadFile(handle, filePath);
        if (success != true) {
            Log.i(TAG, sftp.lastErrorText());
            return;
        }

        //  Close the file.
        success = sftp.CloseHandle(handle);
        if (success != true) {
            Log.i(TAG, sftp.lastErrorText());
            return;
        }

        Log.i(TAG, "Success.");

    }

    static {
        // Important: Make sure the name passed to loadLibrary matches the shared library
        // found in your project's libs/armeabi directory.
        //  for "libchilkat.so", pass "chilkat" to loadLibrary
        //  for "libchilkatemail.so", pass "chilkatemail" to loadLibrary
        //  etc.
        //
        System.loadLibrary("chilkat");

        // Note: If the incorrect library name is passed to System.loadLibrary,
        // then you will see the following error message at application startup:
        //"The application <your-application-name> has stopped unexpectedly. Please try again."
    }
}