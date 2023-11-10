# braintree_paypal

A new Flutter project.

## Requirements

#### iOS:

Minimum target iOS 14

#### Android:

Minimum SDK 21

## Setup

#### iOS Integration Steps:

No further step.

#### Android Integration Steps:

To use this plugin in your Android app, you need to update your AndroidManifest.xml. Add the following snippet inside the <application> tag:

    <activity android:name="dev.jonmlk.braintree_paypal.BraintreePaypalActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="${applicationId}.braintree" />
        </intent-filter>
    </activity>

This configuration ensures that the Braintree integration works correctly with your app. Remember, ${applicationId} will be automatically replaced with your app's application ID during the build process.

#### Web Integration Steps:

> TO DOCUMENT
