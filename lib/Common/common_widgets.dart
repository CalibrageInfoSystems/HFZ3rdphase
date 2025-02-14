import 'package:flutter/material.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/Consultation.dart';

class CommonWidgets {
  static void customCancelDialog(
    BuildContext context, {
    required String? message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 130,
                child: Image.asset('assets/check.png'),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                // Center the text
                child: Text(
                  '$message',
                  style: CommonUtils.txSty_18b_fb,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  color: CommonUtils.primaryTextColor,
                ),
                side: const BorderSide(
                  color: CommonUtils.primaryTextColor,
                ),
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 16,
                  color: CommonUtils.primaryTextColor,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // cancelConsultation(consultation);
                onConfirm();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  color: CommonUtils.primaryTextColor,
                ),
                side: const BorderSide(
                  color: CommonUtils.primaryTextColor,
                ),
                backgroundColor: CommonUtils.primaryTextColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
