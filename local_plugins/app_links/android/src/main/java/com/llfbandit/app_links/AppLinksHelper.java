package com.llfbandit.app_links;

import android.content.Intent;

public class AppLinksHelper {

  public static String getUrl(Intent intent) {
    String action = intent.getAction();

    if (Intent.ACTION_SEND.equals(action) ||
        Intent.ACTION_SEND_MULTIPLE.equals(action) ||
        Intent.ACTION_SENDTO.equals(action)) {
      return null;
    }

    String dataString = intent.getDataString();

    return dataString;
  }

}