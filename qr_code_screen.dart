import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_menu/constants/colors/app_colors.dart';
import 'package:smart_menu/presentation/widget/common/common_text/big_text.dart';
import '../widget/common/buttons/app_rount_mini_btn.dart';
import '../widget/snack_bar.dart';

class QRCodeTableStand extends StatelessWidget {
  final ScreenshotController screenshotController = ScreenshotController();

  QRCodeTableStand({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText(text: 'QR Code', color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 30.h),
            Screenshot(
              controller: screenshotController,
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      QrImageView(
                        data: 'This is a simple QR code',
                        version: QrVersions.auto,
                        size: 320,
                        gapless: false,
                      ),
                      10.verticalSpace,
                      const Text(
                        'SCAN FOR MENU',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppRoundMiniBtn(
                    text: 'Download',
                    onTap: () async {
                      await captureAndSaveQrCode(context);
                    },
                    color: AppColors.mainColor),
                SizedBox(width: 15.w),
                AppRoundMiniBtn(
                    text: 'Share QR',
                    onTap: () async {
                      await shareQrCode();
                    },
                    color: AppColors.mainColor),
              ],
            ),
            10.verticalSpace,
            const Text(
              'Please print the QR Code & Put in  Your Table\n'
                  'Then Customers can Scan & Find The Menu\n'
                  'Enjoy this . It\'s quick and easy!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                height: 1.5,
                color: Colors.black38
              ),
            )

          ],
        ),
      ),
    );
  }

  shareQrCode() async {
    try {
      await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((image) async {
        if (image != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = await File('${directory.path}/image.png').create();
          await imagePath.writeAsBytes(image);
          final xFileImage = XFile(imagePath.path);
          await Share.shareXFiles([xFileImage]);
        }
      });
    } catch (e) {
      AppSnackBar.errorSnackBar('Error', e.toString());
      return;
    }
  }

  Future<void> captureAndSaveQrCode(BuildContext context) async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        // Save the image to the gallery
        final result = await ImageGallerySaver.saveImage(imageBytes, quality: 60, name: "qr_code");
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR Code saved to gallery')));
          AppSnackBar.successSnackBar('Success', 'QR Code saved to gallery');
        } else {
          AppSnackBar.errorSnackBar('Error', 'Failed to save image');
        }
      }
    } catch (e) {
      AppSnackBar.errorSnackBar('Error', e.toString());
    }
  }
}
