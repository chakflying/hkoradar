//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

//! Shows the web request result
class HKORadarView extends WatchUi.View {
  private var _message as String = "Press menu or\nselect button";

  private var bitmaps as Array<BitmapResource or Graphics.BitmapReference>?;
  private var timestamps as Array<String>?;

  private var displayTimer as Timer.Timer?;
  private var currentDisplayPos as Number;
  private var playAnimation as Boolean;

  private var _screenCenterPoint as Array<Number>;
  private var systemSettings as DeviceSettings;

  private var spinnerState as Float;
  private var loading as Boolean;

  //! Constructor
  public function initialize() {
    WatchUi.View.initialize();

    bitmaps = null;
    timestamps = null;
    currentDisplayPos = 0;
    displayTimer = new Timer.Timer();
    systemSettings = System.getDeviceSettings();
    _screenCenterPoint =
      [systemSettings.screenWidth / 2, systemSettings.screenHeight / 2] as
      Array<Number>;

    spinnerState = 0.0;
    loading = true;
    playAnimation = true;
  }

  //! Load your resources here
  //! @param dc Device context
  public function onLayout(dc as Dc) as Void {}

  //! Restore the state of the app and prepare the view to be shown
  public function onShow() as Void {
    displayTimer.start(method(:onAnimateTimer), 250, true);
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
      dc.drawBitmap2(0, 0, bitmaps[currentDisplayPos], {
        // :transform => transform,
        :filterMode => Graphics.FILTER_MODE_POINT,
        // :tintColor => 0xcccccc,
      });

      if (currentDisplayPos < timestamps.size()) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
          dc.getWidth() / 2,
          dc.getHeight() / 2 + 80,
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
    }

    if (loading) {
      drawSpinner(dc);
    }
  }

  private function drawProgress(dc as Dc, currentDisplayPos as Number) as Void {
    dc.setAntiAlias(true);
    dc.setPenWidth(6);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    var arcPos = currentDisplayPos + 1;
    if (arcPos == 10) {
      arcPos = 0;
    }

    dc.drawArc(
      _screenCenterPoint[0],
      _screenCenterPoint[1],
      120,
      Graphics.ARC_COUNTER_CLOCKWISE,
      360,
      (360 / 10) * arcPos
    );
  }

  private function drawSpinner(dc as Dc) as Void {
    dc.setAntiAlias(true);
    dc.setPenWidth(8);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    for (var i = 0; i < 72; i++) {
      var widthFactor = Math.sin(
        ((spinnerState * 2.0 - i.toFloat()) / 18.0) * Math.PI
      );

      var width = 7.0 * widthFactor;

      if (width < 1.0) {
        width = 1.0;
      }

      dc.drawArc(
        _screenCenterPoint[0],
        _screenCenterPoint[1],
        120,
        Graphics.ARC_CLOCKWISE,
        i * 5 + spinnerState,
        i * 5 + spinnerState - width
      );
    }

    spinnerState += 0.1;
    if (spinnerState >= 360.0) {
      spinnerState = 0.0;
    }

    WatchUi.requestUpdate();
  }

  //! Called when this View is removed from the screen. Save the
  //! state of your app here.
  public function onHide() as Void {}

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
    loading = false;
    if (data != null) {
      if (bitmaps == null) {
        bitmaps = [data];
      } else {
        bitmaps.add(data);
      }
    }
  }

  public function onTimestamps(data as Array<String>) as Void {
    timestamps = data;
  }

  public function onInteract(togglePause as Boolean) as Void {
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
