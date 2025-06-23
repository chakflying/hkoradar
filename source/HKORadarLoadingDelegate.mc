import Toybox.Communications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Handle loading images from Web and sending them to the view
class HKORadarLoadingDelegate extends WatchUi.BehaviorDelegate {
  private var _addBitmap as
  (Method(data as BitmapResource or BitmapReference or Null) as Void);
  private var _setTimestamps as (Method(data as Array<String>) as Void);
  private var _setDisplayString as (Method(displayString as String) as Void);

  private var imageUrlList as Array<String>;
  private var imageRequestProgress as Number;

  private var systemSettings as DeviceSettings;

  private var urlTemplate =
    "https://hko-radar-img.fly.dev/unsafe/75x75:325x325/$1$x$2$/filters:format(png):palette():bitdepth(4):compression(8)/www.hko.gov.hk/wxinfo/radars/$3$";

  //! Set up the callback to the view
  //! @param handler Callback method for when data is received
  public function initialize(
    loadBitmap as
      (Method(data as BitmapResource or BitmapReference or Null) as Void),
    setTimestamps as (Method(data as Array<String>) as Void),
    setDisplayString as (Method(displayString as String) as Void)
  ) {
    WatchUi.BehaviorDelegate.initialize();

    _addBitmap = loadBitmap;
    _setTimestamps = setTimestamps;
    _setDisplayString = setDisplayString;

    imageUrlList = [];
    imageRequestProgress = 0;
    systemSettings = System.getDeviceSettings();

    getImageList();
  }

  //! On a menu event, make a web request
  //! @return true if handled, false otherwise
  public function onMenu() as Boolean {
    return true;
  }

  //! On a select event, make a web request
  //! @return true if handled, false otherwise
  public function onSelect() as Boolean {
    return true;
  }

  private function getImageList() as Void {
    _setDisplayString.invoke(
      Application.loadResource($.Rez.Strings.DownloadingImageList)
    );

    Communications.makeWebRequest(
      "https://www.hko.gov.hk/wxinfo/radars/iradar_img.json",
      {},
      {
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      },
      method(:onGetImageList)
    );
  }

  private function makeRequests() as Void {
    _setDisplayString.invoke(
      Application.loadResource($.Rez.Strings.DownloadingImages)
    );

    requestImage(0);
  }

  //! Make the web request
  private function requestImage(num as Number) as Void {
    var options = {
      :dithering => Communications.IMAGE_DITHERING_FLOYD_STEINBERG,
      :maxWidth => systemSettings.screenWidth,
      :maxHeight => systemSettings.screenHeight,
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
    if (responseCode == 200) {
      if (data instanceof Dictionary) {
        var length = data["radar"]["range3"]["image"].size();

        var timestamps = [];

        for (var i = 1; i <= 10; i++) {
          var image = data["radar"]["range3"]["image"][length - i];
          var eqPos = image.find("=");
          image = image.substring(eqPos + 2, -2);

          var dotPos = image.find(".");

          timestamps.add(image.substring(dotPos - 4, dotPos));

          imageUrlList.add(
            Lang.format(urlTemplate, [
              systemSettings.screenWidth.toString(),
              systemSettings.screenHeight.toString(),
              image,
            ])
          );
        }

        _setTimestamps.invoke(timestamps);

        imageRequestProgress = 0;
        makeRequests();
      }
    } else {
      _setDisplayString.invoke(
        Application.loadResource($.Rez.Strings.FailedToLoad) +
          "\nError: " +
          responseCode.toString()
      );
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
      _addBitmap.invoke(data);

      imageRequestProgress++;
      if (imageRequestProgress < imageUrlList.size()) {
        requestImage(imageRequestProgress);
      }
    } else {
      _setDisplayString.invoke(
        Application.loadResource($.Rez.Strings.FailedToLoad) +
          "\nError: " +
          responseCode.toString()
      );
    }
  }
}
