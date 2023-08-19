import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

//! Shows the web request result
class HKORadarLoadingView extends WatchUi.View {
  private var _message as String;

  private var _screenCenterPoint as Array<Number>;
  private var systemSettings as DeviceSettings;

  private var spinnerState as Float;
  private var loading as Boolean;

  //! Constructor
  public function initialize() {
    WatchUi.View.initialize();

    _message = Application.loadResource($.Rez.Strings.Initializing);

    systemSettings = System.getDeviceSettings();
    _screenCenterPoint =
      [systemSettings.screenWidth / 2, systemSettings.screenHeight / 2] as
      Array<Number>;

    spinnerState = 0.0;
    loading = true;
  }

  //! Load your resources here
  //! @param dc Device context
  public function onLayout(dc as Dc) as Void {
    // startLoading();
  }

  //! Restore the state of the app and prepare the view to be shown
  public function onShow() as Void {}

  //! Update the view
  //! @param dc Device Context
  public function onUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    // Draw Status Text
    dc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() / 2,
      Graphics.FONT_SMALL,
      _message,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    if (loading) {
      drawSpinner(dc);
    }
  }

  private function drawSpinner(dc as Dc) as Void {
    dc.setAntiAlias(true);
    dc.setPenWidth(systemSettings.screenWidth / 32);
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
        systemSettings.screenWidth / 2 - 10,
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
  public function setDisplayString(displayString as String) as Void {
    _message = displayString;

    WatchUi.requestUpdate();
  }
}
