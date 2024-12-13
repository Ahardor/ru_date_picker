library ru_date_picker;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const List<String> months = [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь'
];

const List<String> weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
final List<int> monthsDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

bool isLeapYear(int year) {
  if (year % 4 == 0) {
    if (year % 100 == 0) {
      return year % 400 == 0;
    } else {
      return true;
    }
  } else {
    return false;
  }
}

int getPrevMonth(int month) {
  return month == 1 ? 12 : month - 1;
}

int getNextMonth(int month) {
  return month == 12 ? 1 : month + 1;
}

int getPrevYear(int year, int month) {
  return getPrevMonth(month) == 12 ? year - 1 : year;
}

int getNextYear(int year, int month) {
  return getNextMonth(month) == 1 ? year + 1 : year;
}

class ArmDatePicker extends StatefulWidget {
  const ArmDatePicker({
    super.key,
    Color? background,
    this.from,
    this.to,
    required this.on,
    this.initial,
  }) : background = background ?? Colors.white;

  final Color background;
  final DateTime? from;
  final DateTime? to;
  final DateTime? initial;

  final void Function(DateTime? date) on;

  @override
  State<ArmDatePicker> createState() => _ArmDatePickerState();
}

class _ArmDatePickerState extends State<ArmDatePicker> {
  TextEditingController dateController = TextEditingController();

  late int currentMonth;
  late int currentYear;
  late int currentDay;

  DateTime? selectedDate;

  List<int> fromPrevMonth = [];
  List<int> toNextMonth = [];

  var dateRegExp =
      r'^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.(19|20)[0-9]{2}$';

  var pointRegExp = [
    r'^(0[1-9]|[12][0-9]|3[01])$',
    r'^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])$'
  ];

  var zeroRegExpD = [
    r'^([4-9])$',
    r'^([1-3])\.$',
  ];

  var zeroRegExpM = [
    r'^(0[1-9]|[12][0-9]|3[01])\.([2-9])$',
    r'^(0[1-9]|[12][0-9]|3[01])\.1\.$',
  ];

  bool matching = true;
  int oldLen = 0;
  DateTime? oldDate;

  DateTime? from, to;

  @override
  void initState() {
    if (widget.initial != null) {
      currentYear = widget.initial!.year;
      currentMonth = widget.initial!.month;
      currentDay = widget.initial!.day;

      setDate(
          year: widget.initial!.year,
          month: widget.initial!.month,
          day: widget.initial!.day);
    } else {
      currentYear = DateTime.now().year;
      currentMonth = DateTime.now().month;
      currentDay = DateTime.now().day;
    }

    from = widget.from?.copyWith(
        hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);
    to = widget.to?.copyWith(
        hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);

    var text = "";

    dateController.addListener(() {
      if (dateController.text == text) {
        return;
      }
      text = dateController.text;

      setState(() {
        matching = RegExp(dateRegExp).hasMatch(text) || text == "";
      });

      if (text == "") {
        setState(() {
          selectedDate = null;
        });
        return;
      }

      if (!matching) {
        setState(() {
          selectedDate = null;
        });

        if (oldLen > text.length) {
          setState(() {
            oldDate = selectedDate;
            oldLen = dateController.text.length;
          });
          return;
        }

        if (zeroRegExpD.any(
          (e) => RegExp(e).hasMatch(
            text,
          ),
        )) {
          print(text);
          text = '0$text';
          print(text);
        }

        if (zeroRegExpM.any(
          (e) => RegExp(e).hasMatch(
            text,
          ),
        )) {
          print(text);

          text =
              '${text.substring(0, text.indexOf('.') + 1)}0${text.substring(text.indexOf('.') + 1)}';

          print(text);
        }

        if (pointRegExp.any(
          (e) => RegExp(e).hasMatch(
            text,
          ),
        )) {
          text += '.';
        }

        if (dateController.text != text) {
          setState(() {
            dateController.text = text;
            dateController.selection =
                TextSelection.collapsed(offset: text.length);

            oldDate = selectedDate;
            oldLen = dateController.text.length;
          });
        }

        return;
      }

      var selection = text.split('.').map((e) => int.parse(e)).toList();

      setState(() {
        selectedDate = DateTime(selection[2], selection[1], selection[0]);
      });

      if (from != null && selectedDate!.compareTo(from!) < 0) {
        setDate(year: from!.year, month: from!.month, day: from!.day);
        return;
      }

      if (to != null && selectedDate!.compareTo(to!) > 0) {
        setDate(year: to!.year, month: to!.month, day: to!.day);
        return;
      }

      setState(() {
        currentYear = selectedDate!.year;
        currentMonth = selectedDate!.month;
        currentDay = selectedDate!.day;
      });

      if (oldDate?.compareTo(selectedDate!) != 0) {
        dateController.selection =
            TextSelection.collapsed(offset: dateController.text.length);
      }

      print(selectedDate);
    });

    init();

    super.initState();
  }

  void setDate({
    required int year,
    required int month,
    required int day,
  }) {
    if (widget.initial != null) {
      selectedDate = widget.initial;
    }

    setState(() {
      dateController.text =
          '${day < 10 ? '0$day' : day}.${month < 10 ? '0$month' : month}.$year';
      dateController.selection =
          TextSelection.collapsed(offset: dateController.text.length);
    });

    init();
  }

  void init() {
    fromPrevMonth.clear();
    toNextMonth.clear();

    monthsDays[1] = isLeapYear(currentYear) ? 29 : 28;
    for (var i = monthsDays[getPrevMonth(currentMonth) - 1];
        DateTime(getPrevYear(currentYear, currentMonth),
                    getPrevMonth(currentMonth), i)
                .weekday !=
            7;
        i--) {
      fromPrevMonth.add(i);
    }
    fromPrevMonth = fromPrevMonth.reversed.toList();

    for (var i = 1;
        DateTime(getNextYear(currentYear, currentMonth),
                    getNextMonth(currentMonth), i)
                .weekday !=
            1;
        i++) {
      toNextMonth.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("REBUILD");
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: widget.background,
          border: Border.all(
            width: 1,
            color: const Color(0xFFD1D5DB),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(
                    r'[0-9.]',
                  ),
                ),
              ],
              decoration: InputDecoration(
                errorText: matching ? null : "Введите корректную дату",
                hintText: "ДД.ММ.ГГГГ ",
                hintStyle:
                    Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB),
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentMonth = getPrevMonth(currentMonth);

                        if (currentMonth == 12) {
                          currentYear -= 1;
                        }

                        init();
                      });
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    months[currentMonth - 1],
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: const Color(0xFF495057)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$currentYear',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: const Color(0xFF495057)),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentMonth = getNextMonth(currentMonth);

                        if (currentMonth == 1) {
                          currentYear += 1;
                        }

                        init();
                      });
                    },
                    icon: const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: AspectRatio(
                aspectRatio: 1.2,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 7,
                  childAspectRatio: 1.2,
                  children: [
                    for (var i in weekdays)
                      Center(
                        child: Text(
                          i,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    for (var i in fromPrevMonth)
                      ArmCalendarButton(
                        currentYear: getPrevYear(currentYear, currentMonth),
                        currentMonth: getPrevMonth(currentMonth),
                        day: i,
                        selectedDate: selectedDate,
                        onPressed: () {
                          setDate(
                              year: getPrevYear(currentYear, currentMonth),
                              month: getPrevMonth(currentMonth),
                              day: i);
                        },
                        textColor: const Color(0xFFD1D5DB),
                        from: from,
                        to: to,
                      ),
                    for (var i = 1; i <= monthsDays[currentMonth - 1]; i++)
                      ArmCalendarButton(
                        currentYear: currentYear,
                        currentMonth: currentMonth,
                        day: i,
                        selectedDate: selectedDate,
                        onPressed: () {
                          setDate(
                              year: currentYear, month: currentMonth, day: i);
                        },
                        from: from,
                        to: to,
                      ),
                    for (var i in toNextMonth)
                      ArmCalendarButton(
                        currentYear: getNextYear(currentYear, currentMonth),
                        currentMonth: getNextMonth(currentMonth),
                        day: i,
                        selectedDate: selectedDate,
                        onPressed: () {
                          setDate(
                              year: getNextYear(currentYear, currentMonth),
                              month: getNextMonth(currentMonth),
                              day: i);
                        },
                        textColor: const Color(0xFFD1D5DB),
                        from: from,
                        to: to,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text("Отмена"),
                  onPressed: () {
                    widget.on(null);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 15),
                TextButton(
                  child: const Text("Выбрать"),
                  onPressed: () {
                    widget.on(selectedDate);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ArmCalendarButton extends StatelessWidget {
  const ArmCalendarButton({
    super.key,
    required this.currentYear,
    required this.currentMonth,
    required this.day,
    this.selectedDate,
    required this.onPressed,
    this.textColor,
    this.from,
    this.to,
  });

  final int currentYear;
  final int currentMonth;
  final int day;
  final Color? textColor;

  final DateTime? selectedDate;
  final DateTime? from;
  final DateTime? to;

  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    bool ignore = (from != null &&
            DateTime(currentYear, currentMonth, day).compareTo(from!) < 0) ||
        (to != null &&
            DateTime(currentYear, currentMonth, day).compareTo(to!) > 0);

    return IgnorePointer(
      ignoring: ignore,
      child: Center(
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor:
                DateTime(currentYear, currentMonth, day) == selectedDate
                    ? const Color(0xFF3B82F6)
                    : null,
          ),
          icon: Text(
            '$day',
            style: TextStyle(
              color: ignore
                  ? const Color(0xFFEF4444)
                  : DateTime(currentYear, currentMonth, day) == selectedDate
                      ? Colors.white
                      : textColor,
            ),
          ),
        ),
      ),
    );
  }
}
