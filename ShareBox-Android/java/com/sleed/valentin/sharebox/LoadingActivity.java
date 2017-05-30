package com.sleed.valentin.sharebox;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.widget.Toast;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;


public class LoadingActivity extends Activity {

    public static final String EXTRA_LOGIN = "Error";
    WifiManager mainWifi;
    private static final ScheduledExecutorService worker = Executors.newSingleThreadScheduledExecutor();

    @Override
    protected void onCreate(Bundle savedInstanceState) { //Evenement appelé au démarrage de l'activité
        super.onCreate(savedInstanceState);
        //Affichage de l'interface définie en XML
        setContentView(R.layout.activity_loading);

        mainWifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);

        //Activation du Wifi s'il ne l'est pas déjà
        if (mainWifi.isWifiEnabled() == false) {
            mainWifi.setWifiEnabled(true);
            toastMaker("Activation du wifi...");
        }

        //Vérification VLC/MX Player
        if(!isPackageInstalled("org.videolan", this) && !isPackageInstalled("com.mxtech.videoplayer.ad", this)){
            toastMaker(getString(R.string.vlc_needed));
        }
        //Sinon l'application se lance au bout de 5 secondes
        else {
            Runnable task = new Runnable() {
                public void run() {
                    //Démarrage de l'activité principale au bout de 5 secondes
                    Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                    intent.putExtra(EXTRA_LOGIN, "loading");
                    startActivity(intent);
                    finish();
                }
            };
            worker.schedule(task, 5, TimeUnit.SECONDS);
        }
    }

    public void toastMaker(String text) {
        Toast toast = new Toast(this);
        toast.makeText(getApplicationContext(), text, Toast.LENGTH_SHORT).show();
    }

    private boolean isPackageInstalled(String packagename, Context context) {
        PackageManager pm = context.getPackageManager();
        try {
            pm.getPackageInfo(packagename, PackageManager.GET_ACTIVITIES);
            return true;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }
}
