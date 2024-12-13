<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

Простой плагин с удобным календарём для Flutter.

## Возможности

-   Выбор даты
-   Ограничение выбора даты
-   Установка изначальной даты

## Использование

Использование в виде `future`

```dart
Completer<DateTime?> c = Completer<DateTime?>();

showDialog(
    context: context,
    builder: (context) => ArmDatePicker(
            from: min,
            to: max,
            on: (date) {
            c.complete(date);
            },
            initial: initial,
        ));

return c.future;
```

---

Использование в виде `callback`

```dart
showDialog(
    context: context,
    builder: (context) => ArmDatePicker(
            from: min,
            to: max,
            on: (date) {
            //TODO
            },
            initial: initial,
        ));

```
