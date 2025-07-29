Xin Chào người tiếp quản dụ án KulBlock tiếp theo, tôi là Kha tts đợt 3/3 - 8/8 2025

Thì khi bạn chạy app sẽ bị lỗi một số thư viện phụ thuộc gồm:
+lỗi không đồng bộ phiên bản sdk grade
    Cách fix vào trong thanh bên trái vs code ctrl shift e (explorer) rồi nhấn vào mục dependencies/direct dependencies 
    rồi tìm thư viện phụ thuộc bị lỗi mún sửa, tìm android/build.grade và android/app/build.grade sửa lại phiên bản 
    lưu ý (targetSdkVersion,compileSdkVersion,buildToolsVersion) pb lớn hơn 31 và phiên bản là tùy thuộc máy bạn đã tải phiên bản bao nhiêu
            (minSdkVersion) cũng do máy bạn đã tải phiên bảo bao nhiêu mà ghi vào
            (gradle) bạn có thể nâng cấp phiên bản hơn 8.2.1 nhưng hiện vào năm 2025 vẫn chạy rất ngon

file build.grade ở folder android
android {
    compileSdkVersion 35
    ndkVersion = "27.0.12077973"
    ...
    defaultConfig {
        minSdkVersion 23
        //targetSdkVersion flutter.targetSdkVersion
        targetSdkVersion 35
        ...
    }
    ...
    buildToolsVersion '35.0.0'
}
file build.grade ở folder android/app
buildscript {
    ext.kotlin_version = '1.8.22'

    ext {
        compileSdkVersion = 33
        targetSdkVersion = 33
    }


    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
+Lỗi chưa có name cho thư viện
   cái này chỉ cần thêm name cho nó ở AndroidManifest.xml thôi hoặc ở android/build.grade cho từng thư viện chưa có tên
+Lỗi Thư viện flutter_barcode_scanner 
    thì thư viện này khá cũ nên nó bị lỗi phiên bản grade và các phiên bản khác chỉ cần đồng bộ lại và lỗi register bạn phải sửa lại
    toàn bộ file FlutterBarcodeScannerPlugin.java trong thư viện phụ thuộc flutter_barcode_scanner/android/app/src/java/com/amolg/flutterbarcodescanner/FlutterBarcodeScannerPlugin.java
    chỉ cần copy toàn bộ nội dung file FlutterBarcodeScannerPlugin.txt tôi để trong folder ReadMe này và dán vào FlutterBarcodeScannerPlugin.java rồi clean pub get là được