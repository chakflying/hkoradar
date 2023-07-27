//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! This app demonstrates how to make web requests through GCM.
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
  public function getInitialView() as Array<Views or InputDelegates>? {
    var view = new $.HKORadarView();
    var delegate = new $.HKORadarDelegate(
      view.method(:onStatusMessage),
      view.method(:onBitmapData),
      view.method(:onTimestamps),
      view.method(:onInteract)
    );
    return [view, delegate] as Array<Views or InputDelegates>;
  }
}