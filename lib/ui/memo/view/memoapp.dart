import 'package:background_task/background_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:memoplace/ui/login/view_model/loginuser.dart';
import 'package:memoplace/ui/memo/view/memolist.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:memoplace/widgets/custom_buttom.dart';

class MemoApp extends HookConsumerWidget {
  const MemoApp({super.key});
  static String get routeName => 'memolist';
  static String get routeLocation => '/$routeName';

  Future<void> pushMessage(text, context) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'asia-northeast1')
            .httpsCallable('pushTalk');
    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    final resp = await callable.call({
      'title': AppLocalizations.of(context)!.supermarket,
      'body': '$text',
      'token': token
    });
    final data = resp.data;
    print("result: $data");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color baseColor = Colors.orange.shade100;
    useEffect(() {
      _checkLocationPermission(context, ref);
      return null;
    });
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    print(w);
    print(h);
    return Scaffold(
      body: const Column(
        children: [
          Expanded(child: MemoList()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
              width: w * 0.15,
              height: h * 0.06,
              color: baseColor,
              onPressd: () async {
                context.push('/addpage');
              }),
          SizedBox(
            height: h * 0.02,
          )
        ],
      ),
    );
  }

  Future<void> _checkLocationPermission(
      BuildContext context, WidgetRef ref) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Andorid構成
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // フォアグラウンドで通知が表示されるオプションの設定
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: false,
      sound: true,
    );

    // push通知のパーミションの設定
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    // 通知バナーをタップ時の処理
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      context.push('/memolist');
    });

    // 位置情報サービスが有効かチェック
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (serviceEnabled) {
      final permission = await Geolocator.checkPermission();
      final position = await _determinePosition();
      if (permission == LocationPermission.denied && position.latitude != 0.0 ||
          position.longitude != 0.0) {
        // トピック作成
        FirebaseMessaging.instance.subscribeToTopic('locationsMemo');

        List<double> latitude = [];
        List<double> longiLang = [];
        List<String> text = [];
        final userId = ref.watch(loginUserProvider);

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('post')
            .doc(userId)
            .collection('documents')
            .get();

        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          dynamic checkLatitudes = documentSnapshot['latitude'];
          dynamic checkLongitudes = documentSnapshot['longitude'];
          dynamic checkText = documentSnapshot['text'];
          dynamic checkAlert = documentSnapshot['alert'];

          if (checkLatitudes != null && checkAlert == true) {
            for (int i = 0; i < checkLatitudes.length; i++) {
              latitude.add(double.parse(checkLatitudes[i].toString()));
              longiLang.add(double.parse(checkLongitudes[i].toString()));
              text.add(checkText);
            }
          }
        }

        //  位置情報が検知されると発火する
        BackgroundTask.instance.stream.listen((event) async {
          for (int i = 0; i < latitude.length; i++) {
            double distanceInMeters = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                double.parse(latitude[i].toString()),
                double.parse(longiLang[i].toString()));
            if (distanceInMeters < 100) {
              await pushMessage(text[i], context);
            }
          }
        });

        // // バックグラウンドで位置情報の使用を開始
        await BackgroundTask.instance.start();

        // フォアグラウンドでのメッセージを受信した際の処理
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification!.android;

          if (notification != null && android != null) {
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notification.body,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    icon: android.smallIcon,
                    // sound: ,
                  ),
                  iOS: const DarwinNotificationDetails(
                    presentAlert: true,
                    presentSound: true,
                    presentBanner: true,
                    // sound:, // 音声ファイル今後設定する！
                  ),
                ));
          }
        });
      }
    }
  }

  // 現在位置を取得するメソッド
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // isLocationServiceEnabledはロケーションサービスが有効かどうかを確認
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('ロケーションサービスが無効です。');
    }

    // ユーザーがデバイスの場所を取得するための許可をすでに付与しているかどうかを確認
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // デバイスの場所へのアクセス許可をリクエストする
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('デバイスの場所を取得するための許可がされていません。');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // return Future.error('デバイスの場所を取得するための許可してください');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    }

    // デバイスの現在の場所を返す。
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }
}
