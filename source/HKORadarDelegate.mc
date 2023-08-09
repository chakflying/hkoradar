import Toybox.Communications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Handle button / touch press in the view
class HKORadarDelegate extends WatchUi.BehaviorDelegate {
  private var _onInteract as (Method(togglePause as Boolean) as Void);

  public function initialize(
    onInteract as (Method(togglePause as Boolean) as Void)
  ) {
    WatchUi.BehaviorDelegate.initialize();
    _onInteract = onInteract;
  }

  //! On a menu event, make a web request
  //! @return true if handled, false otherwise
  public function onMenu() as Boolean {
    return true;
  }

  //! On a select event, make a web request
  //! @return true if handled, false otherwise
  public function onSelect() as Boolean {
    _onInteract.invoke(true);
    return true;
  }
}
