package com.sleed.valentin.sharebox;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.NetworkInfo;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends Activity {
    public final static String EXTRA_URL = "message";
    public static String LOGIN = "error";

    WifiManager mainWifi;
    WifiReceiver receiverWifi;

    StringBuilder sb = new StringBuilder();

    private Handler handler = new Handler();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView connected_as = (TextView) findViewById(R.id.connected_as);
        Button buttonDisconnect = (Button) findViewById(R.id.buttonDisconnect);
        Button buttonConnect = (Button) findViewById(R.id.buttonConnect);

        mainWifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);
        receiverWifi = new WifiReceiver();
        registerReceiver(receiverWifi, new IntentFilter(
        WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));

        Intent intent = getIntent();
        try {
            LOGIN = intent.getStringExtra(LoginActivity.EXTRA_LOGIN);
        } catch (Exception ex) {}

        if(LOGIN != null) {
            int beginLogin = LOGIN.indexOf("&&") + 2;
            int endLogin = LOGIN.lastIndexOf("&&");
            LOGIN = LOGIN.substring(beginLogin, endLogin);
            connected_as.setText(getString(R.string.connect_as) + LOGIN);
            if(LOGIN.equals("admin")) {
                buttonConnect.setText(getString(R.string.control_panel));
            } else {
                buttonConnect.setText(getString(R.string.connected));
            }
        } else {
            connected_as.setText(getString(R.string.dont_connected));
        }

        String SSID = mainWifi.getConnectionInfo().getSSID();
        if(SSID.contains("ShareBox")) {
            buttonDisconnect.setText(getString(R.string.connect_to) + SSID);
        } else buttonDisconnect.setText(getString(R.string.disconnected));
        doInback();
    }

    public void doInback() {
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                mainWifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);

                receiverWifi = new WifiReceiver();
                registerReceiver(receiverWifi, new IntentFilter(
                        WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
                mainWifi.startScan();
                doInback();
            }
        }, 1000);
    }

    public void wifiConnect(View v) {
        Button wifiButton = (Button) findViewById(v.getId());
        String wifiSSID = wifiButton.getText().toString();
        String wifiPass = getString(R.string.wifi_pass);
        if(wifiSSID.equals(getString(R.string.no_sharebox))) return;
        if (mainWifi.isWifiEnabled() == false) {
            mainWifi.setWifiEnabled(true);
        }

        WifiConfiguration conf = new WifiConfiguration();
        conf.SSID = "\"" + wifiSSID + "\"";
        conf.preSharedKey = "\""+ wifiPass +"\"";
        WifiManager wifiManager = (WifiManager)getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        wifiManager.addNetwork(conf);
        List<WifiConfiguration> list = wifiManager.getConfiguredNetworks();
        for( WifiConfiguration i : list ) {
            if(i.SSID != null && i.SSID.equals("\"" + wifiSSID + "\"")) {
                wifiManager.disconnect();
                wifiManager.enableNetwork(i.networkId, true);
                wifiManager.reconnect();
                Button buttonDisconnect = (Button) findViewById(R.id.buttonDisconnect);
                buttonDisconnect.setText(getString(R.string.connect_to) + i.SSID);
                break;
            }
        }
        SystemClock.sleep(3000);

        if(isIdentified()) {
            Intent intent = new Intent(this, WebViewerActivity.class);
            intent.putExtra(EXTRA_URL, "http://192.168.42.1/");
            startActivity(intent);
        } else {
            toastMaker(getString(R.string.must_connect));
        }
    }

    public void wifiDisconnect(View view) {
        Button buttonDisconnect = (Button) findViewById(R.id.buttonDisconnect);
        if (!buttonDisconnect.getText().equals(getString(R.string.connect))) {
            WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
            wifiManager.disconnect();
            buttonDisconnect.setText(getString(R.string.disconnected));
        } else {
            toastMaker(getString(R.string.dont_connected));
        }
    }

    public void upload(View view) {
        if(onSharebox() && isIdentified()) {
            Intent intent = new Intent(this, SFTPsender.class);
            startActivity(intent);
        } else {
            toastMaker(getString(R.string.no_connect_sharebox));
        }
    }

    public void toastMaker(String text) {
        Toast toast = new Toast(this);
        toast.makeText(getApplicationContext(), text, Toast.LENGTH_SHORT).show();
    }

    public void wifiDisabled(View view) {

        if (mainWifi.isWifiEnabled() == false) {
            mainWifi.setWifiEnabled(true);
            toastMaker(getString(R.string.wifi_enable));
        }
        else {
            mainWifi.setWifiEnabled(false);
            toastMaker(getString(R.string.wifi_disable));
            Button buttonDisconnect = (Button) findViewById(R.id.buttonDisconnect);
            buttonDisconnect.setText(getString(R.string.connect));
        }
    }

    public void launchWebviewer(View view) {
        if(onSharebox() && isIdentified()) {
            Intent intent = new Intent(this, WebViewerActivity.class);
            intent.putExtra(EXTRA_URL, "http://192.168.42.1/");
            startActivity(intent);
        } else {
            toastMaker(getString(R.string.no_connect_sharebox));
        }
    }

    public void userConnect(View view) {
        if (onSharebox()) {
            Button button = (Button) view.findViewById(view.getId());
            if(button.getText().toString().contains(getString(R.string.control_panel))) {
                Intent intent = new Intent(this, UMHomeActivity.class);
                startActivity(intent);
            } else if(!button.getText().toString().contains(getString(R.string.connected))){
                Intent intent = new Intent(this, LoginActivity.class);
                startActivity(intent);
            } else {
                button.setText(getString(R.string.connect));
            }
        } else {
            toastMaker(getString(R.string.no_connect_sharebox));
        }
    }

    public boolean onSharebox() {
        android.net.wifi.WifiManager m = (WifiManager) getSystemService(WIFI_SERVICE);
        android.net.wifi.SupplicantState s = m.getConnectionInfo().getSupplicantState();
        NetworkInfo.DetailedState state = WifiInfo.getDetailedStateOf(s);
        if (state != NetworkInfo.DetailedState.CONNECTED && !mainWifi.getConnectionInfo().getSSID().contains("ShareBox")) {
            return false;
        } else return true;
    }

    public boolean isIdentified() {
        TextView textView = (TextView) findViewById(R.id.connected_as);
        if(textView.getText().toString().contains(getString(R.string.connect_as))) {
            return true;
        } else return false;
    }

    @Override
    protected void onPause() {
        unregisterReceiver(receiverWifi);
        super.onPause();
    }

    @Override
    protected void onResume() {
        registerReceiver(receiverWifi, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
        super.onResume();
    }

    class WifiReceiver extends BroadcastReceiver {
        public void onReceive(Context c, Intent intent) {

            ArrayList<String> connections = new ArrayList<String>();

            sb = new StringBuilder();
            List<ScanResult> wifiList;
            String wifiPrefix = getString(R.string.wifi_prefix);
            wifiList = mainWifi.getScanResults();
            int wifi = 0;
            for (int i = 0; i < wifiList.size(); i++) {
                connections.add(wifiList.get(i).SSID);
                if(wifiList.get(i).SSID.contains(wifiPrefix) == true && wifi == 0) {
                    Button wifi1 = (Button) findViewById(R.id.wifi1);
                    wifi1.setText(wifiList.get(i).SSID);
                    wifi++;
                } else if (wifiList.get(i).SSID.contains(wifiPrefix) == true && wifi == 1) {
                    Button wifi2 = (Button) findViewById(R.id.wifi2);
                    wifi2.setText(wifiList.get(i).SSID);
                    wifi++;
                } else if (wifiList.get(i).SSID.contains(wifiPrefix) == true && wifi == 2) {
                    Button wifi3 = (Button) findViewById(R.id.wifi3);
                    wifi3.setText(wifiList.get(i).SSID);
                    wifi++;
                }
            }
        }
    }
}