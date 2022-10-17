import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late CleverTapPlugin _clevertapPlugin;
  var inboxInitialized = false;
  var optOut = false;
  var offLine = false;
  var enableDeviceNetworkingInfo = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    activateCleverTapFlutterPluginHandlers();
    CleverTapPlugin.setDebugLevel(3);
    CleverTapPlugin.createNotificationChannel(
        "fluttertest", "Flutter Test", "Flutter Test", 5, true);
    CleverTapPlugin.initializeInbox();
    CleverTapPlugin.registerForPush(); //only for iOS
    //var initialUrl = CleverTapPlugin.getInitialUrl();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  void activateCleverTapFlutterPluginHandlers() {
    _clevertapPlugin = CleverTapPlugin();
    _clevertapPlugin
        .setCleverTapPushAmpPayloadReceivedHandler(pushAmpPayloadReceived);
    _clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(
        pushClickedPayloadReceived);
    _clevertapPlugin.setCleverTapInAppNotificationDismissedHandler(
        inAppNotificationDismissed);
    _clevertapPlugin
        .setCleverTapProfileDidInitializeHandler(profileDidInitialize);
    _clevertapPlugin.setCleverTapProfileSyncHandler(profileDidUpdate);
    _clevertapPlugin.setCleverTapInboxDidInitializeHandler(inboxDidInitialize);
    _clevertapPlugin
        .setCleverTapInboxMessagesDidUpdateHandler(inboxMessagesDidUpdate);
    _clevertapPlugin
        .setCleverTapDisplayUnitsLoadedHandler(onDisplayUnitsLoaded);
    _clevertapPlugin.setCleverTapInAppNotificationButtonClickedHandler(
        inAppNotificationButtonClicked);
    _clevertapPlugin.setCleverTapInboxNotificationButtonClickedHandler(
        inboxNotificationButtonClicked);
    _clevertapPlugin.setCleverTapFeatureFlagUpdatedHandler(featureFlagsUpdated);
    _clevertapPlugin
        .setCleverTapProductConfigInitializedHandler(productConfigInitialized);
    _clevertapPlugin
        .setCleverTapProductConfigFetchedHandler(productConfigFetched);
    _clevertapPlugin
        .setCleverTapProductConfigActivatedHandler(productConfigActivated);
  }

  void inAppNotificationDismissed(Map<String, dynamic> map) {
    setState(() {
      print("inAppNotificationDismissed called");
    });
  }

  void inAppNotificationButtonClicked(Map<String, dynamic>? map) {
    setState(() {
      print("inAppNotificationButtonClicked called = ${map.toString()}");
    });
  }

  void inboxNotificationButtonClicked(Map<String, dynamic>? map) {
    setState(() {
      print("inboxNotificationButtonClicked called = ${map.toString()}");
    });
  }

  void profileDidInitialize() {
    setState(() {
      print("profileDidInitialize called");
    });
  }

  void profileDidUpdate(Map<String, dynamic>? map) {
    setState(() {
      print("profileDidUpdate called");
    });
  }

  void inboxDidInitialize() {
    setState(() {
      print("inboxDidInitialize called");
      inboxInitialized = true;
    });
  }

  void inboxMessagesDidUpdate() {
    setState(() async {
      print("inboxMessagesDidUpdate called");
      int? unread = await CleverTapPlugin.getInboxMessageUnreadCount();
      int? total = await CleverTapPlugin.getInboxMessageCount();
      print("Unread count = " + unread.toString());
      print("Total count = " + total.toString());
    });
  }

  void onDisplayUnitsLoaded(List<dynamic>? displayUnits) {
    setState(() async {
      List? displayUnits = await CleverTapPlugin.getAllDisplayUnits();
      print("Display Units = " + displayUnits.toString());
    });
  }

  void featureFlagsUpdated() {
    print("Feature Flags Updated");
    setState(() async {
      bool? booleanVar = await CleverTapPlugin.getFeatureFlag("BoolKey", false);
      print("Feature flag = " + booleanVar.toString());
    });
  }

  void productConfigInitialized() {
    print("Product Config Initialized");
    this.setState(() async {
      await CleverTapPlugin.fetch();
    });
  }

  void productConfigFetched() {
    print("Product Config Fetched");
    this.setState(() async {
      await CleverTapPlugin.activate();
    });
  }

  void productConfigActivated() {
    print("Product Config Activated");
    setState(() async {
      String? stringvar =
      await CleverTapPlugin.getProductConfigString("StringKey");
      print("PC String = " + stringvar.toString());
      int? intvar = await CleverTapPlugin.getProductConfigLong("IntKey");
      print("PC int = " + intvar.toString());
      double? doublevar =
      await CleverTapPlugin.getProductConfigDouble("DoubleKey");
      print("PC double = " + doublevar.toString());
    });
  }

  void pushAmpPayloadReceived(Map<String, dynamic> map) {
    print("pushAmpPayloadReceived called");
    setState(() async {
      var data = jsonEncode(map);
      print("Push Amp Payload = " + data.toString());
      CleverTapPlugin.createNotification(data);
    });
  }

  void pushClickedPayloadReceived(Map<String, dynamic> map) {
    print("pushClickedPayloadReceived called");
    setState(() async {
      var data = jsonEncode(map);
      print("on Push Click Payload = " + data.toString());
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            color: Colors.orange,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                dense: true,
                trailing: Icon(Icons.warning),
                title: Text(
                    "NOTE : All CleverTap functions are listed below"),
                subtitle: Text(
                    "Please check console logs for more info after tapping below"),
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("User Profiles"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Push User"),
                subtitle: Text("Pushes/Records a user"),
                onTap: recordUser,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Set Profile Multi Values"),
                subtitle: Text("Sets a multi valued user property"),
                onTap: setProfileMultiValue,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Remove Profile Value For Key"),
                subtitle: Text("Removes user property of given key"),
                onTap: removeProfileValue,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Add Profile Multi Value"),
                subtitle: Text("Add user property"),
                onTap: addMultiValue,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Profile increment value"),
                subtitle: Text("Increment value by 15"),
                onTap: incrementValue,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Profile decrement value"),
                subtitle: Text("Decrement value by 10"),
                onTap: decrementValue,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Add Profile Multi values"),
                subtitle: Text("Add a multi valued user property"),
                onTap: addMultiValues,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Remove Multi Value"),
                subtitle: Text("Remove user property"),
                onTap: removeMultiValue,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Remove Multi Values"),
                subtitle: Text("Remove a multi valued user property"),
                onTap: removeMultiValues,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("Identity Management"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Performs onUserLogin"),
                subtitle: Text("Used to identify multiple profiles"),
                onTap: onUserLogin,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get CleverTap ID"),
                subtitle: Text("Returns Clevertap ID"),
                onTap: getCleverTapId,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("Location"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Set Location"),
                subtitle: Text("Use to set Location of a user"),
                onTap: setLocation,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("User Events"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Push Event"),
                subtitle: Text("Pushes/Records an event"),
                onTap: recordEvent,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Push Charged Event"),
                subtitle: Text("Pushes/Records a Charged event"),
                onTap: recordChargedEvent,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Event Detail"),
                subtitle: Text("Get details of an event"),
                onTap: getEventDetail,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Event History"),
                subtitle: Text("Get history of an event"),
                onTap: recordEvent,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("App Inbox"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Show Inbox"),
                subtitle: Text("Opens sample App Inbox"),
                onTap: showInbox,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get All Inbox Messages"),
                subtitle: Text("Returns all inbox messages"),
                onTap: getAllInboxMessages,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Unread Inbox Messages"),
                subtitle: Text("Returns unread inbox messages"),
                onTap: getUnreadInboxMessages,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Inbox Message for given ID"),
                subtitle: Text("Returns inbox message for given ID"),
                onTap: getInboxMessageForId,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Delete Inbox Message for given ID"),
                subtitle: Text("Deletes inbox message for given ID"),
                onTap: deleteInboxMessageForId,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Mark Read Inbox Message for given ID"),
                subtitle: Text("Mark read inbox message for given ID"),
                onTap: markReadInboxMessageForId,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Push Inbox Message Clicked"),
                subtitle:
                Text("Pushes/Records inbox message clicked event"),
                onTap: pushInboxNotificationClickedEventForId,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Push Inbox Message Viewed"),
                subtitle:
                Text("Pushes/Records inbox message viewed event"),
                onTap: pushInboxNotificationViewedEventForId,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("Enable Debugging"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Set Debug Level"),
                subtitle: Text(
                    "Sets the debug level in Android/iOS to show console logs"),
                onTap: () {
                  CleverTapPlugin.setDebugLevel(3);
                },
                trailing: Icon(Icons.info),
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("In-App messaging controls"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Suspend InApp notifications"),
                subtitle:
                Text("Suspends display of InApp Notifications."),
                onTap: suspendInAppNotifications,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Discard InApp notifications"),
                subtitle: Text(
                    "Suspends the display of InApp Notifications "
                        "and discards any new InApp Notifications to be shown"
                        " after this method is called."),
                onTap: discardInAppNotifications,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Resume InApp notifications"),
                subtitle: Text("Resumes display of InApp Notifications."),
                onTap: resumeInAppNotifications,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("Product Config"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Event First Time"),
                subtitle: Text("Gets first epoch of an event"),
                onTap: eventGetFirstTime,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Event Occurrences"),
                subtitle: Text("Get number of occurences of an event"),
                onTap: eventGetOccurrences,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Event Last Time"),
                subtitle: Text("Returns last epoch value for an event"),
                onTap: eventGetLastTime,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Fetch"),
                subtitle: Text("Fetches Product Config values"),
                onTap: fetch,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Activate"),
                subtitle: Text("Activates Product Config values"),
                onTap: activate,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Fetch and Activate"),
                subtitle: Text("Fetches and Activates Config values"),
                onTap: fetchAndActivate,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Session Time Elapsed"),
                subtitle: Text("Returns session time elapsed"),
                onTap: getTimeElapsed,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Session Total Visits"),
                subtitle: Text("Returns session total visits"),
                onTap: getTotalVisits,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Session Screen Count"),
                subtitle: Text("Returns session screen count"),
                onTap: getScreenCount,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Session Previous Visit Time"),
                subtitle: Text("Returns session previous visit time"),
                onTap: getPreviousVisitTime,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Session UTM Details"),
                subtitle: Text("Returns session UTM details"),
                onTap: getUTMDetails,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Ad Units"),
                subtitle: Text("Returns all Display Units set"),
                onTap: getAdUnits,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("Attribution"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Get Attribution ID"),
                subtitle: Text(
                    "Returns Attribution ID to send to attribution partners"),
                onTap: getCTAttributionId,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("GDPR"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Set Opt Out"),
                subtitle:
                Text("Used to opt out of sending data to CleverTap"),
                onTap: setOptOut,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Device Networking Info"),
                subtitle: Text(
                    "Enables/Disable device networking info as per GDPR"),
                onTap: setEnableDeviceNetworkingInfo,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("Multi-Instance"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Enable Personalization"),
                subtitle: Text("Enables Personalization"),
                onTap: enablePersonalization,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Disables Personalization"),
                subtitle: Text("Disables Personalization"),
                onTap: disablePersonalization,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Set Offline"),
                subtitle: Text("Switches CleverTap to offline mode"),
                onTap: setOffline,
              ),
            ),
          ),
          Card(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListTile(
                title: Text("Push Templates"),
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Basic Push"),
                onTap: sendBasicPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Carousel Push"),
                onTap: sendAutoCarouselPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Manual Carousel Push"),
                onTap: sendManualCarouselPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("FilmStrip Carousel Push"),
                onTap: sendFilmStripCarouselPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Rating Push"),
                onTap: sendRatingCarouselPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Product Display"),
                onTap: sendProductDisplayPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Linear Product Display"),
                onTap: sendLinearProductDisplayPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Five CTA"),
                onTap: sendCTAPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Zero Bezel"),
                onTap: sendZeroBezelPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Zero Bezel Text Only"),
                onTap: sendZeroBezelTextOnlyPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Timer Push"),
                onTap: sendTimerPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text(
                    "Input Box - CTA + reminder Push Campaign - DOC true"),
                onTap: sendInputBoxPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Input Box - Reply with Event"),
                onTap: sendInputBoxReplyEventPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Input Box - Reply with Intent"),
                onTap: sendInputBoxReplyAutoOpenPush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text(
                    "Input Box - CTA + reminder Push Campaign - DOC false"),
                onTap: sendInputBoxRemindDOCFalsePush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Input Box - CTA - DOC true"),
                onTap: sendInputBoxCTADOCTruePush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Input Box - CTA - DOC false"),
                onTap: sendInputBoxCTADOCFalsePush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Input Box - reminder - DOC true"),
                onTap: sendInputBoxReminderDOCTruePush,
              ),
            ),
          ),
          Card(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Input Box - reminder - DOC false"),
                onTap: sendInputBoxReminderDOCFalsePush,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendBasicPush() {
    var eventData = {
      // Key:    Value
      'first': 'partridge',
      'second': 'turtledoves'
    };
    CleverTapPlugin.recordEvent("Send Basic Push", eventData);
  }

  void sendAutoCarouselPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Carousel Push", eventData);
  }

  void sendManualCarouselPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Manual Carousel Push", eventData);
  }

  void sendFilmStripCarouselPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Filmstrip Carousel Push", eventData);
  }

  void sendRatingCarouselPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Rating Push", eventData);
  }

  void sendProductDisplayPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Product Display Notification", eventData);
  }

  void sendLinearProductDisplayPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Linear Product Display Push", eventData);
  }

  void sendCTAPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send CTA Notification", eventData);
  }

  void sendZeroBezelPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Zero Bezel Notification", eventData);
  }

  void sendZeroBezelTextOnlyPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent(
        "Send Zero Bezel Text Only Notification", eventData);
  }

  void sendTimerPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Timer Notification", eventData);
  }

  void sendInputBoxPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box Notification", eventData);
  }

  void sendInputBoxReplyEventPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent(
        "Send Input Box Reply with Event Notification", eventData);
  }

  void sendInputBoxReplyAutoOpenPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent(
        "Send Input Box Reply with Auto Open Notification", eventData);
  }

  void sendInputBoxRemindDOCFalsePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent(
        "Send Input Box Remind Notification DOC FALSE", eventData);
  }

  void sendInputBoxCTADOCTruePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box CTA DOC true", eventData);
  }

  void sendInputBoxCTADOCFalsePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box CTA DOC false", eventData);
  }

  void sendInputBoxReminderDOCTruePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box Reminder DOC true", eventData);
  }

  void sendInputBoxReminderDOCFalsePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box Reminder DOC false", eventData);
  }

  void recordEvent() {
    var now = new DateTime.now();
    var eventData = {
      // Key:    Value
      'first': 'partridge',
      'second': 'turtledoves',
      'date': CleverTapPlugin.getCleverTapDate(now),
      'number': 1
    };
    CleverTapPlugin.recordEvent("Flutter Event", eventData);
    print("Raised event - Flutter Event");
  }

  void recordNotificationClickedEvent() {
    var eventData = {
      /// Key:    Value
      'nm': 'Notification message',
      'nt': 'Notification title',
      'wzrk_id': '0_0',
      'wzrk_cid': 'Notification Channel ID'

      ///other CleverTap Push Payload Key Values found in Step 3 of
      ///https://developer.clevertap.com/docs/android#section-custom-android-push-notifications-handling
    };
    CleverTapPlugin.pushNotificationClickedEvent(eventData);
    print("Raised event - Notification Clicked");
  }

  void recordNotificationViewedEvent() {
    var eventData = {
      /// Key:    Value
      'nm': 'Notification message',
      'nt': 'Notification title',
      'wzrk_id': '0_0',
      'wzrk_cid': 'Notification Channel ID'

      ///other CleverTap Push Payload Key Values found in Step 3 of
      ///https://developer.clevertap.com/docs/android#section-custom-android-push-notifications-handling
    };
    CleverTapPlugin.pushNotificationViewedEvent(eventData);
    print("Raised event - Notification Viewed");
  }

  void recordChargedEvent() {
    var item1 = {
      // Key:    Value
      'name': 'thing1',
      'amount': '100'
    };
    var item2 = {
      // Key:    Value
      'name': 'thing2',
      'amount': '100'
    };
    var items = [item1, item2];
    var chargeDetails = {
      // Key:    Value
      'total': '200',
      'payment': 'cash'
    };
    CleverTapPlugin.recordChargedEvent(chargeDetails, items);
    print("Raised event - Charged");
  }

  void recordUser() {
    var stuff = ["bags", "shoes"];
    var profile = {
      'Name': 'sarvesh',
      'Identity': '100',
      'DOB': '22-04-2000',

      ///Key always has to be "DOB" and format should always be dd-MM-yyyy
      'Email': 'sarveshgk10@gmail.com',
      'Phone': '14155551234',
      'props': 'property1',
      'stuff': stuff
    };
    CleverTapPlugin.profileSet(profile);
    print("Pushed profile " + profile.toString());
  }

  void showInbox() {
    if (inboxInitialized) {
      print("Opening App Inbox");
      //, onDismiss: () {
      var styleConfig = {
        'noMessageTextColor': '#ff6600',
        'noMessageText': 'No message(s) to show.',
        'navBarTitle': 'App Inbox',
        'navBarTitleColor': '#101727',
        'navBarColor': '#EF4444',
        'tabs': ["Offers"]
      };
      CleverTapPlugin.showInbox(styleConfig);
      //});
    }
  }

  void getAllInboxMessages() async {
    List? messages = await CleverTapPlugin.getAllInboxMessages();
    print("See all inbox messages in console");
    print("Inbox Messages = " + messages.toString());
  }

  void getUnreadInboxMessages() async {
    List? messages = await CleverTapPlugin.getUnreadInboxMessages();
    print("See unread inbox messages in console");
    print("Unread Inbox Messages = " + messages.toString());
  }

  void getInboxMessageForId() async {
    var messageId = await getFirstInboxMessageId();

    if (messageId == null) {
      setState((() {
        print("Inbox Message id is null");
        print("Inbox Message id is null");
      }));
      return;
    }

    var messageForId = await CleverTapPlugin.getInboxMessageForId(messageId);
    setState((() {
      print("Inbox Message for id =  ${messageForId.toString()}");
      print("Inbox Message for id =  ${messageForId.toString()}");
    }));
  }

  void deleteInboxMessageForId() async {
    var messageId = await getFirstInboxMessageId();

    if (messageId == null) {
      setState((() {
        print("Inbox Message id is null");
        print("Inbox Message id is null");
      }));
      return;
    }

    await CleverTapPlugin.deleteInboxMessageForId(messageId);

    setState((() {
      print("Deleted Inbox Message with id =  $messageId");
      print("Deleted Inbox Message with id =  $messageId");
    }));
  }

  void markReadInboxMessageForId() async {
    var messageList = await CleverTapPlugin.getUnreadInboxMessages();

    if (messageList == null || messageList.length == 0) return;
    Map<dynamic, dynamic> itemFirst = messageList[0];

    if (Platform.isAndroid) {
      await CleverTapPlugin.markReadInboxMessageForId(itemFirst["id"]);
      setState((() {
        print("Marked Inbox Message as read with id =  ${itemFirst["id"]}");
        print("Marked Inbox Message as read with id =  ${itemFirst["id"]}");
      }));
    } else if (Platform.isIOS) {
      await CleverTapPlugin.markReadInboxMessageForId(itemFirst["_id"]);
      setState((() {
        print(
            "Marked Inbox Message as read with id =  ${itemFirst["_id"]}");
        print("Marked Inbox Message as read with id =  ${itemFirst["_id"]}");
      }));
    }
  }

  void pushInboxNotificationClickedEventForId() async {
    var messageId = await getFirstInboxMessageId();

    if (messageId == null) {
      setState((() {
        print("Inbox Message id is null");
        print("Inbox Message id is null");
      }));
      return;
    }

    await CleverTapPlugin.pushInboxNotificationClickedEventForId(messageId);

    setState((() {
      print(
          "Pushed NotificationClickedEvent for Inbox Message with id =  $messageId");
      print(
          "Pushed NotificationClickedEvent for Inbox Message with id =  $messageId");
    }));
  }

  void pushInboxNotificationViewedEventForId() async {
    var messageId = await getFirstInboxMessageId();

    if (messageId == null) {
      setState((() {
        print("Inbox Message id is null");
        print("Inbox Message id is null");
      }));
      return;
    }

    await CleverTapPlugin.pushInboxNotificationViewedEventForId(messageId);

    setState((() {
      print(
          "Pushed NotificationViewedEvent for Inbox Message with id =  $messageId");
      print(
          "Pushed NotificationViewedEvent for Inbox Message with id =  $messageId");
    }));
  }

  Future<String>? getFirstInboxMessageId() async {
    var messageList = await CleverTapPlugin.getAllInboxMessages();
    print("inside getFirstInboxMessageId");
    Map<dynamic, dynamic> itemFirst = messageList?[0];
    print(itemFirst.toString());

    if (Platform.isAndroid) {
      return itemFirst["id"];
    } else if (Platform.isIOS) {
      return itemFirst["_id"];
    }
    return "";
  }

  void setOptOut() {
    if (optOut) {
      CleverTapPlugin.setOptOut(false);
      optOut = false;
      print("You have opted in");
    } else {
      CleverTapPlugin.setOptOut(true);
      optOut = true;
      print("You have opted out");
    }
  }

  void setOffline() {
    if (offLine) {
      CleverTapPlugin.setOffline(false);
      offLine = false;
      print("You are online");
    } else {
      CleverTapPlugin.setOffline(true);
      offLine = true;
      print("You are offline");
    }
  }

  void setEnableDeviceNetworkingInfo() {
    if (enableDeviceNetworkingInfo) {
      CleverTapPlugin.enableDeviceNetworkInfoReporting(false);
      enableDeviceNetworkingInfo = false;
      print("You have disabled device networking info");
    } else {
      CleverTapPlugin.enableDeviceNetworkInfoReporting(true);
      enableDeviceNetworkingInfo = true;
      print("You have enabled device networking info");
    }
  }

  void recordScreenView() {
    var screenName = "Home Screen";
    CleverTapPlugin.recordScreenView(screenName);
  }

  void eventGetFirstTime() {
    var eventName = "Flutter Event";
    CleverTapPlugin.eventGetFirstTime(eventName).then((eventFirstTime) {
      if (eventFirstTime == null) return;
      setState((() {
        print("Event First time CleverTap = " + eventFirstTime.toString());
        print("Event First time CleverTap = " + eventFirstTime.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void eventGetLastTime() {
    var eventName = "Flutter Event";
    CleverTapPlugin.eventGetLastTime(eventName).then((eventLastTime) {
      if (eventLastTime == null) return;
      setState((() {
        print("Event Last time CleverTap = " + eventLastTime.toString());
        print("Event Last time CleverTap = " + eventLastTime.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void eventGetOccurrences() {
    var eventName = "Flutter Event";
    CleverTapPlugin.eventGetOccurrences(eventName).then((eventOccurrences) {
      if (eventOccurrences == null) return;
      setState((() {
        print(
            "Event detail from CleverTap = " + eventOccurrences.toString());
        print("Event detail from CleverTap = " + eventOccurrences.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getEventDetail() {
    var eventName = "Flutter Event";
    CleverTapPlugin.eventGetDetail(eventName).then((eventDetailMap) {
      if (eventDetailMap == null) return;
      setState((() {
        print("Event detail from CleverTap = " + eventDetailMap.toString());
        print("Event detail from CleverTap = " + eventDetailMap.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getEventHistory() {
    var eventName = "Flutter Event";
    CleverTapPlugin.getEventHistory(eventName).then((eventDetailMap) {
      if (eventDetailMap == null) return;
      setState((() {
        print(
            "Event History from CleverTap = " + eventDetailMap.toString());
        print("Event History from CleverTap = " + eventDetailMap.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void setLocation() {
    var lat = 19.07;
    var long = 72.87;
    CleverTapPlugin.setLocation(lat, long);
    print("Location is set");
  }

  void getCTAttributionId() {
    CleverTapPlugin.profileGetCleverTapAttributionIdentifier()
        .then((attributionId) {
      if (attributionId == null) return;
      setState((() {
        print("Attribution Id = " + "$attributionId");
        print("Attribution Id = " + "$attributionId");
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getCleverTapId() {
    CleverTapPlugin.getCleverTapID().then((clevertapId) {
      if (clevertapId == null) return;
      setState((() {
        print("$clevertapId");
        print("$clevertapId");
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void onUserLogin() {
    var stuff = ["bags", "shoes"];
    var profile = {
      'Name': 'Captain America',
      'Identity': '100',
      'Email': 'captain@america.com',
      'Phone': '+14155551234',
      'stuff': stuff
    };
    CleverTapPlugin.onUserLogin(profile);
    print("onUserLogin called, check console for details");
  }

  void removeProfileValue() {
    CleverTapPlugin.profileRemoveValueForKey("props");
    print("check console for details");
  }

  void setProfileMultiValue() {
    var values = ["value1", "value2"];
    CleverTapPlugin.profileSetMultiValues("props", values);
    print("check console for details");
  }

  void addMultiValue() {
    var value = "value1";
    CleverTapPlugin.profileAddMultiValue("props", value);
    print("check console for details");
  }

  void incrementValue() {
    var value = 15;
    CleverTapPlugin.profileIncrementValue("score", value);
    print("check console for details");
  }

  void decrementValue() {
    var value = 10;
    CleverTapPlugin.profileDecrementValue("score", value);
    print("check console for details");
  }

  void addMultiValues() {
    var values = ["value1", "value2"];
    CleverTapPlugin.profileAddMultiValues("props", values);
    print("check console for details");
  }

  void removeMultiValue() {
    var value = "value1";
    CleverTapPlugin.profileRemoveMultiValue("props", value);
    print("check console for details");
  }

  void removeMultiValues() {
    var values = ["value1", "value2"];
    CleverTapPlugin.profileRemoveMultiValues("props", values);
    print("check console for details");
  }

  void getTimeElapsed() {
    CleverTapPlugin.sessionGetTimeElapsed().then((timeElapsed) {
      if (timeElapsed == null) return;
      setState((() {
        print("Session Time Elapsed = " + timeElapsed.toString());
        print("Session Time Elapsed = " + timeElapsed.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getTotalVisits() {
    CleverTapPlugin.sessionGetTotalVisits().then((totalVisits) {
      if (totalVisits == null) return;
      setState((() {
        print("Session Total Visits = " + totalVisits.toString());
        print("Session Total Visits = " + totalVisits.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getScreenCount() {
    CleverTapPlugin.sessionGetScreenCount().then((screenCount) {
      if (screenCount == null) return;
      setState((() {
        print("Session Screen Count = " + screenCount.toString());
        print("Session Screen Count = " + screenCount.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getPreviousVisitTime() {
    CleverTapPlugin.sessionGetPreviousVisitTime().then((previousTime) {
      if (previousTime == null) return;
      setState((() {
        print("Session Previous Visit Time = " + previousTime.toString());
        print("Session Previous Visit Time = " + previousTime.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getUTMDetails() {
    CleverTapPlugin.sessionGetUTMDetails().then((utmDetails) {
      if (utmDetails == null) return;
      setState((() {
        print("Session UTM Details = " + utmDetails.toString());
        print("Session UTM Details = " + utmDetails.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void suspendInAppNotifications() {
    CleverTapPlugin.suspendInAppNotifications();
    print("InApp notification is suspended");
  }

  void discardInAppNotifications() {
    CleverTapPlugin.discardInAppNotifications();
    print("InApp notification is discarded");
  }

  void resumeInAppNotifications() {
    CleverTapPlugin.resumeInAppNotifications();
    print("InApp notification is resumed");
  }

  void enablePersonalization() {
    CleverTapPlugin.enablePersonalization();
    print("Personalization enabled");
    print("Personalization enabled");
  }

  void disablePersonalization() {
    CleverTapPlugin.disablePersonalization();
    print("Personalization disabled");
    print("Personalization disabled");
  }

  void getAdUnits() async {
    List? displayUnits = await CleverTapPlugin.getAllDisplayUnits();
    print("check console for logs");
    print("Display Units = " + displayUnits.toString());
  }

  void fetch() {
    CleverTapPlugin.fetch();
    print("check console for logs");

    ///CleverTapPlugin.fetchWithMinimumIntervalInSeconds(0);
  }

  void activate() {
    CleverTapPlugin.activate();
    print("check console for logs");
  }

  void fetchAndActivate() {
    CleverTapPlugin.fetchAndActivate();
    print("check console for logs");
  }
}