//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! Creates a web request on menu / select events
class HKORadarDelegate extends WatchUi.BehaviorDelegate {
  private var _notify as (Method(data as String?) as Void);
  private var _data as
  (Method(data as BitmapResource or BitmapReference or Null) as Void);
  private var _timestamps as (Method(data as Array<String>) as Void);
  private var _interact as (Method(togglePause as Boolean) as Void);

  private var imageUrlList as Array<String>;
  private var imageRequestProgress as Number;

  //! Set up the callback to the view
  //! @param handler Callback method for when data is received
  public function initialize(
    progressHandler as (Method(data as String?) as Void),
    bitmapHandler as
      (Method(data as BitmapResource or BitmapReference or Null) as Void),
    timestampsHandler as (Method(data as Array<String>) as Void),
    interactHandler as (Method(togglePause as Boolean) as Void)
  ) {
    WatchUi.BehaviorDelegate.initialize();
    _notify = progressHandler;
    _data = bitmapHandler;
    _timestamps = timestampsHandler;
    _interact = interactHandler;

    imageUrlList = [];
    imageRequestProgress = 0;
    getImageList();
  }

  //! On a menu event, make a web request
  //! @return true if handled, false otherwise
  public function onMenu() as Boolean {
    // makeRequests();
    return true;
  }

  //! On a select event, make a web request
  //! @return true if handled, false otherwise
  public function onSelect() as Boolean {
    _interact.invoke(true);
    return true;
  }

  private function getImageList() as Void {
    _notify.invoke("Downloading\nImage List...");

    Communications.makeWebRequest(
      "https://www.hko.gov.hk/wxinfo/radars/iradar_img.json",
      {},
      {
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      },
      method(:onGetImageList)
    );
  }

  //! Make the web request
  private function makeRequests() as Void {
    _notify.invoke("Downloading\nImages...");

    requestImage(0);
  }

  private function requestImage(num as Number) as Void {
    var options = {
      :dithering => Communications.IMAGE_DITHERING_FLOYD_STEINBERG,
      :maxWidth => 750,
      :maxHeight => 520,
    };

    Communications.makeImageRequest(
      imageUrlList[num],
      {},
      options,
      method(:onStatusMessage)
    );
  }

  public function onGetImageList(
    responseCode as Number,
    data as Dictionary or String or Null
  ) as Void {
    if (data instanceof Dictionary) {
      var length = data["radar"]["range2"]["image"].size();

      var timestamps = [];

      for (var i = 1; i <= 12; i++) {
        var image = data["radar"]["range2"]["image"][length - i];
        var eqPos = image.find("=");
        image = image.substring(eqPos + 2, -2);

        // System.println(image);

        var dotPos = image.find(".");

        timestamps.add(image.substring(dotPos - 4, dotPos));

        imageUrlList.add(
          Lang.format("https://www.hko.gov.hk/wxinfo/radars/$1$", [image])
        );
      }

      _timestamps.invoke(timestamps);

      imageRequestProgress = 0;
      makeRequests();
    }
  }

  //! Receive the data from the web request
  //! @param responseCode The server response code
  //! @param data Content from a successful request
  public function onStatusMessage(
    responseCode as Number,
    data as BitmapResource or BitmapReference or Null
  ) as Void {
    if (responseCode == 200) {
      _data.invoke(data);

      imageRequestProgress++;
      if (imageRequestProgress < imageUrlList.size()) {
        requestImage(imageRequestProgress);
      }
    } else {
      _notify.invoke("Failed to load\nError: " + responseCode.toString());
    }
  }
}
