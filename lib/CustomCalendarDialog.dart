import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'CommonUtils.dart';

class CustomCalendarDialog extends StatefulWidget {
  final CalendarDatePicker2Config config;

  const CustomCalendarDialog({Key? key, required this.config}) : super(key: key);

  @override
  _CustomCalendarDialogState createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  List<DateTime?> _selectedDates = [null, null]; // Assuming range picker

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.white,
      child: IntrinsicHeight(

        // width: 325,
        // height: 400,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: CalendarDatePicker2(
                  config: widget.config,
                  value: _selectedDates,
                  onValueChanged: (dates) {
                    setState(() {
                      _selectedDates = dates;
                    });
                  },
                ),
              ),
            ),
            // const SizedBox(height: 20),
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child:Row(

              mainAxisAlignment: MainAxisAlignment.end,


              children: [
                Container(
                  child: ElevatedButton(
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
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: CommonUtils.primaryTextColor,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Add spacing between buttons
                Container(
                  child: ElevatedButton(
                    onPressed: _selectedDates.length > 1 && _selectedDates[1] != null
                        ? () {
                      Navigator.of(context).pop(_selectedDates);
                    }
                        : null,
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
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: () {
                //     Navigator.of(context).pop(null);
                //   },
                //   child: const Text('Cancel'),
                // ),
                // ElevatedButton(
                //   onPressed: _selectedDates.length > 1 && _selectedDates[1] != null
                //       ? () {
                //     Navigator.of(context).pop(_selectedDates);
                //   }
                //       : null,
                //   child: const Text('OK'),
                // ),
              ],
            ),
            )],
        ),
      ),
    );
  }
}

Future<List<DateTime?>?> showCustomCalendarDialog(
    BuildContext context, CalendarDatePicker2Config config) {
  return showDialog<List<DateTime?>?>(
    context: context,
    builder: (context) => CustomCalendarDialog(config: config),
  );
}
