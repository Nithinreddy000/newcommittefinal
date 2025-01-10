package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.graphics.Bitmap;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlutterLocalNotificationsPlugin implements FlutterPlugin, MethodCallHandler {
	private MethodChannel channel;

	@Override
	public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
		channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_local_notifications");
		channel.setMethodCallHandler(this);
	}

	@Override
	public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
		channel.setMethodCallHandler(null);
		channel = null;
	}

	@Override
	public void onMethodCall(MethodCall call, Result result) {
		// Handle method calls
	}

	private void setNotificationBigPicture(Notification.Builder builder) {
		Notification.BigPictureStyle bigPictureStyle = new Notification.BigPictureStyle();
		bigPictureStyle.bigLargeIcon((Bitmap) null);
		builder.setStyle(bigPictureStyle);
	}
}
