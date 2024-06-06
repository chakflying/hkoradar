import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class HKORadarApp extends Application.AppBase {
  //! Constructor
  public function initialize() {
    AppBase.initialize();
  }

  //! Handle app startup
  //! @param state Startup arguments
  public function onStart(state as Dictionary?) as Void {}

  //! Handle app shutdown
  //! @param state Shutdown arguments
  public function onStop(state as Dictionary?) as Void {}

  //! Return the initial view for the app
  //! @return Array Pair [View, Delegate]
  public function getInitialView() as [WatchUi.Views] or
    [WatchUi.Views, WatchUi.InputDelegates] {
    var view = new $.HKORadarView();
    var delegate = new $.HKORadarDelegate(view.method(:onInteract));

    return [view, delegate];
  }
}
