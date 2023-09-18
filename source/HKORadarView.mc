import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

//! Shows the web request result
class HKORadarView extends WatchUi.View {
  private var _message as String;

  private var initialStart as Boolean;

  private var bitmaps as Array<BitmapResource or Graphics.BitmapReference>?;
  private var timestamps as Array<String>?;

  private var displayTimer as Timer.Timer?;
  private var currentDisplayPos as Number;
  private var playAnimation as Boolean;

  private var exitTimer as Timer.Timer?;

  private var _screenCenterPoint as Array<Number>;
  private var systemSettings as DeviceSettings;

  //! Constructor
  public function initialize() {
    WatchUi.View.initialize();

    _message = Application.loadResource($.Rez.Strings.Initializing);
    initialStart = true;

    bitmaps = null;
    timestamps = null;
    currentDisplayPos = 0;
    displayTimer = new Timer.Timer();
    systemSettings = System.getDeviceSettings();
    _screenCenterPoint =
      [systemSettings.screenWidth / 2, systemSettings.screenHeight / 2] as
      Array<Number>;

    playAnimation = true;
    exitTimer = new Timer.Timer();
  }

  //! Load your resources here
  //! @param dc Device context
  public function onLayout(dc as Dc) as Void {}

  //! Restore the state of the app and prepare the view to be shown
  public function onShow() as Void {
    if (bitmaps == null && initialStart) {
      startLoading();
      initialStart = false;
      _message = Application.loadResource($.Rez.Strings.BeginDownload);
    } else {
      displayTimer.start(method(:onAnimateTimer), 250, true);
    }
  }

  public function onAnimateTimer() as Void {
    if (bitmaps != null) {
      currentDisplayPos = currentDisplayPos - 1;
      if (currentDisplayPos == -1) {
        currentDisplayPos = bitmaps.size() - 1;
      }
      WatchUi.requestUpdate();
    }
  }

  //! Update the view
  //! @param dc Device Context
  public function onUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    if (bitmaps != null) {
      dc.drawBitmap(0, 0, bitmaps[currentDisplayPos]);

      if (currentDisplayPos < timestamps.size()) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
          dc.getWidth() / 2,
          (dc.getHeight() / 2) * 1.65,
          Graphics.FONT_XTINY,
          Lang.format("$1$ : $2$", [
            timestamps[currentDisplayPos].substring(0, 2),
            timestamps[currentDisplayPos].substring(2, 4),
          ]),
          Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
      }

      drawProgress(dc, currentDisplayPos);
    } else {
      // Draw Status Text
      dc.drawText(
        dc.getWidth() / 2,
        dc.getHeight() / 2,
        Graphics.FONT_SMALL,
        _message,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );

      if (initialStart == false) {
        // Draw Start Button indicator
        dc.setPenWidth(systemSettings.screenWidth / 36);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawArc(
          _screenCenterPoint[0],
          _screenCenterPoint[1],
          systemSettings.screenWidth / 2 - 5,
          Graphics.ARC_COUNTER_CLOCKWISE,
          17,
          42
        );
      }
    }
  }

  private function drawProgress(dc as Dc, currentDisplayPos as Number) as Void {
    dc.setAntiAlias(true);
    dc.setPenWidth(systemSettings.screenWidth / 42);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    var arcPos = currentDisplayPos + 1;
    if (arcPos == 10) {
      arcPos = 0;
    }

    dc.drawArc(
      _screenCenterPoint[0],
      _screenCenterPoint[1],
      systemSettings.screenWidth / 2 - 10,
      Graphics.ARC_COUNTER_CLOCKWISE,
      360,
      (360 / 10) * arcPos
    );
  }

  //! Called when this View is removed from the screen. Save the
  //! state of your app here.
  public function onHide() as Void {
    displayTimer.stop();
  }

  //! Show the result or status of the web request
  //! @param args Data from the web request, or error message
  public function onStatusMessage(data as String?) as Void {
    if (data instanceof String) {
      _message = data;
      // System.println(data);
    }

    WatchUi.requestUpdate();
  }

  public function onBitmapData(
    data as BitmapResource or Graphics.BitmapReference or Null
  ) as Void {
    if (data != null) {
      if (bitmaps == null) {
        bitmaps = [data];
        WatchUi.popView(WatchUi.SLIDE_BLINK);
      } else {
        bitmaps.add(data);
      }

      // Refresh timeout to exit
      exitTimer.start(method(:exit), 180000, false);
    }
  }

  public function onTimestamps(data as Array<String>) as Void {
    timestamps = data;
  }

  public function onInteract(togglePause as Boolean) as Void {
    if (bitmaps == null) {
      startLoading();
    } else {
      if (togglePause) {
        playAnimation = !playAnimation;

        if (!playAnimation) {
          displayTimer.stop();
        } else {
          displayTimer.start(method(:onAnimateTimer), 250, true);
        }
      }
    }
  }

  public function startLoading() as Void {
    var loadingView = new $.HKORadarLoadingView();

    var loadingDelegate = new $.HKORadarLoadingDelegate(
      method(:onBitmapData),
      method(:onTimestamps),
      loadingView.method(:setDisplayString)
    );

    WatchUi.pushView(loadingView, loadingDelegate, WatchUi.SLIDE_IMMEDIATE);
  }

  public function exit() as Void {
    System.exit();
  }
}
