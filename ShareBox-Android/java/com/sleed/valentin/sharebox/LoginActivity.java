package com.sleed.valentin.sharebox;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.chilkatsoft.CkSsh;


public class LoginActivity extends Activity {

    private static final String TAG = "ChilkatSSH";
    public static final String EXTRA_LOGIN = "Erreur";
    EditText ETidentifiant;
    EditText ETpassword;
    TextView TVinfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        Button buttonDisconnect = (Button) findViewById(R.id.buttonDisconnect);
        WifiManager mainWifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);
        String SSID = mainWifi.getConnectionInfo().getSSID();
        if(SSID.contains("ShareBox")) {
            buttonDisconnect.setText(getString(R.string.connect_to) + SSID);
        } else buttonDisconnect.setText(getString(R.string.disconnected));
    }

    public void onLogin(View view) {
        TVinfo = (TextView) findViewById(R.id.TVinfo);
        ETpassword = (EditText) findViewById(R.id.password);
        ETidentifiant = (EditText) findViewById(R.id.identifiant);

        String EnterIdentifiant = ETidentifiant.getText().toString();
        String EnterPassword = ETpassword.getText().toString();

        if (EnterIdentifiant.isEmpty() || EnterPassword.isEmpty()) {
            TVinfo.setText(getString(R.string.id_pass_empty));
            TVinfo.setVisibility(View.VISIBLE);
            return;
        }

        String cmd = "cat /home/android/password/." + EnterIdentifiant + ".txt";
        String password = command(cmd);

        if(password.equals(EnterPassword)) {
            TVinfo.setText(getString(R.string.pass_correct));
            TVinfo.setTextColor(Color.GREEN);
            Intent intent = new Intent(this, MainActivity.class);
            intent.putExtra(EXTRA_LOGIN, "LoginApp : &&" + EnterIdentifiant + "&&");
            startActivity(intent);
        }
        else if(password.contains("error")) {
            TVinfo.setText(getString(R.string.id_pass_wrong));
        }
        else {
            TVinfo.setText(getString(R.string.pass_wrong));
        }
        TVinfo.setVisibility(View.VISIBLE);
    }

    public String command(String command) {

        //  Important: It is helpful to send the contents of the
        //  ssh.LastErrorText property when requesting support.

        CkSsh ssh = new CkSsh();

        //  Any string automatically begins a fully-functional 30-day trial.
        boolean success = ssh.UnlockComponent("30-day trial");
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Connect to an SSH server:
        String hostname;
        int port;

        //  Hostname may be an IP address or hostname:
        hostname = "192.168.42.1";
        port = 22;

        success = ssh.Connect(hostname,port);
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Wait a max of 5 seconds when reading responses..
        ssh.put_IdleTimeoutMs(5000);

        //  Authenticate using login/password:
        success = ssh.AuthenticatePw("android", "42");
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Open a session channel.  (It is possible to have multiple
        //  session channels open simultaneously.)
        int channelNum;
        channelNum = ssh.OpenSessionChannel();
        if (channelNum < 0) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Some SSH servers require a pseudo-terminal
        //  If so, include the call to SendReqPty.  If not, then
        //  comment out the call to SendReqPty.
        //  Note: The 2nd argument of SendReqPty is the terminal type,
        //  which should be something like "xterm", "vt100", "dumb", etc.
        //  A "dumb" terminal is one that cannot process escape sequences.
        //  Smart terminals, such as "xterm", "vt100", etc. process
        //  escape sequences.  If you select a type of smart terminal,
        //  your application will receive these escape sequences
        //  included in the command's output.  Use "dumb" if you do not
        //  want to receive escape sequences.  (Assuming your SSH
        //  server recognizes "dumb" as a standard dumb terminal.)
        String termType = "dumb";
        int widthInChars = 120;
        int heightInChars = 40;
        //  Use 0 for pixWidth and pixHeight when the dimensions
        //  are set in number-of-chars.
        int pixWidth = 0;
        int pixHeight = 0;
        success = ssh.SendReqPty(channelNum,termType,widthInChars,heightInChars,pixWidth,pixHeight);
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Start a shell on the channel:
        success = ssh.SendReqShell(channelNum);
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Start a command in the remote shell.  This example
        //  will send a "ls" command to retrieve the directory listing.
        success = ssh.ChannelSendString(channelNum, command + "\n","ansi");
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Send an EOF.  This tells the server that no more data will
        //  be sent on this channel.  The channel remains open, and
        //  the SSH client may still receive output on this channel.
        success = ssh.ChannelSendEof(channelNum);
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Read whatever output may already be available on the
        //  SSH connection.  ChannelReadAndPoll returns the number of bytes
        //  that are available in the channel's internal buffer that
        //  are ready to be "picked up" by calling GetReceivedText
        //  or GetReceivedData.
        //  A return value of -1 indicates failure.
        //  A return value of -2 indicates a failure via timeout.

        //  The ChannelReadAndPoll method waits
        //  for data to arrive on the connection usingi the IdleTimeoutMs
        //  property setting.  Once the first data arrives, it continues
        //  reading but instead uses the pollTimeoutMs passed in the 2nd argument:
        //  A return value of -2 indicates a timeout where no data is received.
        int n;
        int pollTimeoutMs = 3000;
        n = ssh.ChannelReadAndPoll(channelNum,pollTimeoutMs);
        if (n < 0) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Close the channel:
        success = ssh.ChannelSendClose(channelNum);
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Perhaps we did not receive all of the commands output.
        //  To make sure,  call ChannelReceiveToClose to accumulate any remaining
        //  output until the server's corresponding "channel close" is received.
        success = ssh.ChannelReceiveToClose(channelNum);
        if (success != true) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Let's pickup the accumulated output of the command:
        String cmdOutput;
        cmdOutput = ssh.getReceivedText(channelNum,"ansi");
        if (cmdOutput == null ) {
            Log.i(TAG, ssh.lastErrorText());
            return command;
        }

        //  Disconnect
        ssh.Disconnect();

        //  Display the remote shell's command  output:
        Log.i(TAG, cmdOutput);

        if(cmdOutput.contains("&&")) {
            int endCMD = cmdOutput.lastIndexOf("&&");
            int beginCMD = cmdOutput.indexOf("&&") + 2;
            cmdOutput = cmdOutput.substring(beginCMD, endCMD);
        } else {
            return "error";
        }

        return cmdOutput;
    }

    static {
        System.loadLibrary("chilkat");
    }
}

