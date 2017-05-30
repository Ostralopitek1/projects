package com.sleed.valentin.sharebox;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebViewClient;


public class WebViewerActivity extends Activity {

    public final static String EXTRA_MESSAGE = "com.sleed.valentin.testwifi.MESSAGE";
    public static String URL = "url";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_viewer);

        WebView wv = (WebView) findViewById(R.id.webView);
        final Intent intent = getIntent();
        String url = intent.getStringExtra(MainActivity.EXTRA_URL);
        wv.loadUrl(url);
        if(url.contains("avi") || url.contains("mkv") || url.contains("jpg") || url.contains("png") || url.contains("jpeg") || url.contains("mp4") ||
           url.contains("AVI") || url.contains("MKV") || url.contains("JPG") || url.contains("PNG") || url.contains("JPEG") || url.contains("MP4")) finish();
        else {
            wv.setWebViewClient(new WebViewClient() {
                @Override
                public boolean shouldOverrideUrlLoading(WebView view, String url) {
                    if (isURLMatching(url)) {
                        openNextActivity();
                        return true;
                    }
                    return super.shouldOverrideUrlLoading(view, url);
                }
            });
        }
    }

    protected boolean isURLMatching(String url) {
        URL = url;
        if (url.contains("avi") || url.contains("mkv") || url.contains("jpg") || url.contains("png") || url.contains("jpeg") || url.contains("mp4") ||
          url.contains("AVI") || url.contains("MKV") || url.contains("JPG") || url.contains("PNG") || url.contains("JPEG") || url.contains("MP4")) {
            WebView webView = new WebView(this);
            WebView curwebView = (WebView) findViewById(R.id.webView);
            String newURL = curwebView.getUrl();
            webView.loadUrl(newURL);
            setContentView(webView);
            return false;
        }
        else return true;
    }

    protected void openNextActivity() {
        Intent intent = new Intent(this, WebViewerActivity.class);
        intent.putExtra(EXTRA_MESSAGE, URL);
        startActivity(intent);
    }
}
