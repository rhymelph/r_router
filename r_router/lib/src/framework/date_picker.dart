// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'dialog_override.dart';

const Size _calendarPortraitDialogSize = Size(330.0, 518.0);
const Size _calendarLandscapeDialogSize = Size(496.0, 346.0);
const Size _inputPortraitDialogSize = Size(330.0, 270.0);
const Size _inputLandscapeDialogSize = Size(496, 160.0);
const Size _inputRangeLandscapeDialogSize = Size(496, 164.0);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);
const double _inputFormPortraitHeight = 98.0;
const double _inputFormLandscapeHeight = 108.0;

class _DatePickerDialog extends StatefulWidget {
  _DatePickerDialog({
    Key? key,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.cancelText,
    this.confirmText,
    this.helpText,
    this.initialCalendarMode = DatePickerMode.day,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.restorationId,
  })  : assert(initialDate != null),
        assert(firstDate != null),
        assert(lastDate != null),
        initialDate = DateUtils.dateOnly(initialDate),
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()),
        assert(initialEntryMode != null),
        assert(initialCalendarMode != null),
        super(key: key) {
    assert(!this.lastDate.isBefore(this.firstDate),
        'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.');
    assert(!this.initialDate.isBefore(this.firstDate),
        'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.');
    assert(!this.initialDate.isAfter(this.lastDate),
        'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.');
    assert(
        selectableDayPredicate == null ||
            selectableDayPredicate!(this.initialDate),
        'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate');
  }

  /// The initially selected [DateTime] that the picker should display.
  final DateTime initialDate;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  final DatePickerEntryMode initialEntryMode;

  /// Function to provide full control over which [DateTime] can be selected.
  final SelectableDayPredicate? selectableDayPredicate;

  /// The text that is displayed on the cancel button.
  final String? cancelText;

  /// The text that is displayed on the confirm button.
  final String? confirmText;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String? helpText;

  /// The initial display of the calendar picker.
  final DatePickerMode initialCalendarMode;

  final String? errorFormatText;

  final String? errorInvalidText;

  final String? fieldHintText;

  final String? fieldLabelText;

  final String? restorationId;

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog>
    with RestorationMixin {
  late final RestorableDateTime _selectedDate =
      RestorableDateTime(widget.initialDate);
  late final _RestorableDatePickerEntryMode _entryMode =
      _RestorableDatePickerEntryMode(widget.initialEntryMode);
  final _RestorableAutovalidateMode _autovalidateMode =
      _RestorableAutovalidateMode(AutovalidateMode.disabled);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_autovalidateMode, 'autovalidateMode');
    registerForRestoration(_entryMode, 'calendar_entry_mode');
  }

  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleOk() {
    if (_entryMode.value == DatePickerEntryMode.input ||
        _entryMode.value == DatePickerEntryMode.inputOnly) {
      final FormState form = _formKey.currentState!;
      if (!form.validate()) {
        setState(() => _autovalidateMode.value = AutovalidateMode.always);
        return;
      }
      form.save();
    }
    Navigator.pop(context, _selectedDate.value);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case DatePickerEntryMode.calendar:
          _autovalidateMode.value = AutovalidateMode.disabled;
          _entryMode.value = DatePickerEntryMode.input;
          break;
        case DatePickerEntryMode.input:
          _formKey.currentState!.save();
          _entryMode.value = DatePickerEntryMode.calendar;
          break;
        case DatePickerEntryMode.calendarOnly:
        case DatePickerEntryMode.inputOnly:
          assert(false, 'Can not change entry mode from _entryMode');
          break;
      }
    });
  }

  void _handleDateChanged(DateTime date) {
    setState(() {
      _selectedDate.value = date;
    });
  }

  Size _dialogSize(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
      case DatePickerEntryMode.calendarOnly:
        switch (orientation) {
          case Orientation.portrait:
            return _calendarPortraitDialogSize;
          case Orientation.landscape:
            return _calendarLandscapeDialogSize;
        }
      case DatePickerEntryMode.input:
      case DatePickerEntryMode.inputOnly:
        switch (orientation) {
          case Orientation.portrait:
            return _inputPortraitDialogSize;
          case Orientation.landscape:
            return _inputLandscapeDialogSize;
        }
    }
  }

  static const Map<ShortcutActivator, Intent> _formShortcutMap =
      <ShortcutActivator, Intent>{
    // Pressing enter on the field will move focus to the next field or control.
    SingleActivator(LogicalKeyboardKey.enter): NextFocusIntent(),
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final Orientation orientation = MediaQuery.of(context).orientation;
    final TextTheme textTheme = theme.textTheme;
    // Constrain the textScaleFactor to the largest supported value to prevent
    // layout issues.
    final double textScaleFactor =
        math.min(MediaQuery.of(context).textScaleFactor, 1.3);

    final String dateText = localizations.formatMediumDate(_selectedDate.value);
    final Color onPrimarySurface = colorScheme.brightness == Brightness.light
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final TextStyle? dateStyle = orientation == Orientation.landscape
        ? textTheme.headline5?.copyWith(color: onPrimarySurface)
        : textTheme.headline4?.copyWith(color: onPrimarySurface);

    final Widget actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            onPressed: _handleCancel,
            child: Text(widget.cancelText ?? localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: _handleOk,
            child: Text(widget.confirmText ?? localizations.okButtonLabel),
          ),
        ],
      ),
    );

    CalendarDatePicker calendarDatePicker() {
      return CalendarDatePicker(
        key: _calendarPickerKey,
        initialDate: _selectedDate.value,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        currentDate: widget.currentDate,
        onDateChanged: _handleDateChanged,
        selectableDayPredicate: widget.selectableDayPredicate,
        initialCalendarMode: widget.initialCalendarMode,
      );
    }

    Form inputDatePicker() {
      return Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          height: orientation == Orientation.portrait
              ? _inputFormPortraitHeight
              : _inputFormLandscapeHeight,
          child: Shortcuts(
            shortcuts: _formShortcutMap,
            child: Column(
              children: <Widget>[
                const Spacer(),
                InputDatePickerFormField(
                  initialDate: _selectedDate.value,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateSubmitted: _handleDateChanged,
                  onDateSaved: _handleDateChanged,
                  selectableDayPredicate: widget.selectableDayPredicate,
                  errorFormatText: widget.errorFormatText,
                  errorInvalidText: widget.errorInvalidText,
                  fieldHintText: widget.fieldHintText,
                  fieldLabelText: widget.fieldLabelText,
                  autofocus: true,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    final Widget picker;
    final Widget? entryModeButton;
    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
        picker = calendarDatePicker();
        entryModeButton = IconButton(
          icon: const Icon(Icons.edit),
          color: onPrimarySurface,
          tooltip: localizations.inputDateModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );
        break;

      case DatePickerEntryMode.calendarOnly:
        picker = calendarDatePicker();
        entryModeButton = null;
        break;

      case DatePickerEntryMode.input:
        picker = inputDatePicker();
        entryModeButton = IconButton(
          icon: const Icon(Icons.calendar_today),
          color: onPrimarySurface,
          tooltip: localizations.calendarModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );
        break;

      case DatePickerEntryMode.inputOnly:
        picker = inputDatePicker();
        entryModeButton = null;
        break;
    }

    final Widget header = _DatePickerHeader(
      helpText: widget.helpText ?? localizations.datePickerHelpText,
      titleText: dateText,
      titleStyle: dateStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    final Size dialogSize = _dialogSize(context) * textScaleFactor;
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: textScaleFactor,
          ),
          child: Builder(builder: (BuildContext context) {
            switch (orientation) {
              case Orientation.portrait:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    header,
                    Expanded(child: picker),
                    actions,
                  ],
                );
              case Orientation.landscape:
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    header,
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(child: picker),
                          actions,
                        ],
                      ),
                    ),
                  ],
                );
            }
          }),
        ),
      ),
    );
  }
}

// A restorable [DatePickerEntryMode] value.
//
// This serializes each entry as a unique `int` value.
class _RestorableDatePickerEntryMode
    extends RestorableValue<DatePickerEntryMode> {
  _RestorableDatePickerEntryMode(
    DatePickerEntryMode defaultValue,
  ) : _defaultValue = defaultValue;

  final DatePickerEntryMode _defaultValue;

  @override
  DatePickerEntryMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(DatePickerEntryMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  DatePickerEntryMode fromPrimitives(Object? data) =>
      DatePickerEntryMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

/// Re-usable widget that displays the selected date (in large font) and the
/// help text above it.
///
/// These types include:
///
/// * Single Date picker with calendar mode.
/// * Single Date picker with text input mode.
/// * Date Range picker with text input mode.
///
/// [helpText], [orientation], [icon], [onIconPressed] are required and must be
/// non-null.
class _DatePickerHeader extends StatelessWidget {
  /// Creates a header for use in a date picker dialog.
  const _DatePickerHeader({
    Key? key,
    required this.helpText,
    required this.titleText,
    this.titleSemanticsLabel,
    required this.titleStyle,
    required this.orientation,
    this.isShort = false,
    this.entryModeButton,
  })  : assert(helpText != null),
        assert(orientation != null),
        assert(isShort != null),
        super(key: key);

  static const double _datePickerHeaderLandscapeWidth = 152.0;
  static const double _datePickerHeaderPortraitHeight = 120.0;
  static const double _headerPaddingLandscape = 16.0;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String helpText;

  /// The text that is displayed at the center of the header.
  final String titleText;

  /// The semantic label associated with the [titleText].
  final String? titleSemanticsLabel;

  /// The [TextStyle] that the title text is displayed with.
  final TextStyle? titleStyle;

  /// The orientation is used to decide how to layout its children.
  final Orientation orientation;

  /// Indicates the header is being displayed in a shorter/narrower context.
  ///
  /// This will be used to tighten up the space between the help text and date
  /// text if `true`. Additionally, it will use a smaller typography style if
  /// `true`.
  ///
  /// This is necessary for displaying the manual input mode in
  /// landscape orientation, in order to account for the keyboard height.
  final bool isShort;

  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // The header should use the primary color in light themes and surface color in dark
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final Color primarySurfaceColor =
        isDark ? colorScheme.surface : colorScheme.primary;
    final Color onPrimarySurfaceColor =
        isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    final TextStyle? helpStyle = textTheme.overline?.copyWith(
      color: onPrimarySurfaceColor,
    );

    final Text help = Text(
      helpText,
      style: helpStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final Text title = Text(
      titleText,
      semanticsLabel: titleSemanticsLabel ?? titleText,
      style: titleStyle,
      maxLines: orientation == Orientation.portrait ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );

    switch (orientation) {
      case Orientation.portrait:
        return SizedBox(
          height: _datePickerHeaderPortraitHeight,
          child: Material(
            color: primarySurfaceColor,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 24,
                end: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),
                  help,
                  const Flexible(child: SizedBox(height: 38)),
                  Row(
                    children: <Widget>[
                      Expanded(child: title),
                      if (entryModeButton != null) entryModeButton!,
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      case Orientation.landscape:
        return SizedBox(
          width: _datePickerHeaderLandscapeWidth,
          child: Material(
            color: primarySurfaceColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _headerPaddingLandscape,
                  ),
                  child: help,
                ),
                SizedBox(height: isShort ? 16 : 56),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _headerPaddingLandscape,
                    ),
                    child: title,
                  ),
                ),
                if (entryModeButton != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: entryModeButton,
                  ),
              ],
            ),
          ),
        );
    }
  }
}

/// Returns a locale-appropriate string to describe the start of a date range.
///
/// If `startDate` is null, then it defaults to 'Start Date', otherwise if it
/// is in the same year as the `endDate` then it will use the short month
/// day format (i.e. 'Jan 21'). Otherwise it will return the short date format
/// (i.e. 'Jan 21, 2020').
String _formatRangeStartDate(MaterialLocalizations localizations,
    DateTime? startDate, DateTime? endDate) {
  return startDate == null
      ? localizations.dateRangeStartLabel
      : (endDate == null || startDate.year == endDate.year)
          ? localizations.formatShortMonthDay(startDate)
          : localizations.formatShortDate(startDate);
}

/// Returns an locale-appropriate string to describe the end of a date range.
///
/// If `endDate` is null, then it defaults to 'End Date', otherwise if it
/// is in the same year as the `startDate` and the `currentDate` then it will
/// just use the short month day format (i.e. 'Jan 21'), otherwise it will
/// include the year (i.e. 'Jan 21, 2020').
String _formatRangeEndDate(MaterialLocalizations localizations,
    DateTime? startDate, DateTime? endDate, DateTime currentDate) {
  return endDate == null
      ? localizations.dateRangeEndLabel
      : (startDate != null &&
              startDate.year == endDate.year &&
              startDate.year == currentDate.year)
          ? localizations.formatShortMonthDay(endDate)
          : localizations.formatShortDate(endDate);
}

class _DateRangePickerDialog extends StatefulWidget {
  const _DateRangePickerDialog({
    Key? key,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
    this.currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.saveText,
    this.errorInvalidRangeText,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
  }) : super(key: key);

  final DateTimeRange? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? currentDate;
  final DatePickerEntryMode initialEntryMode;
  final String? cancelText;
  final String? confirmText;
  final String? saveText;
  final String? helpText;
  final String? errorInvalidRangeText;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? fieldStartHintText;
  final String? fieldEndHintText;
  final String? fieldStartLabelText;
  final String? fieldEndLabelText;

  @override
  _DateRangePickerDialogState createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  late DatePickerEntryMode _entryMode;
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  late bool _autoValidate;
  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<_InputDateRangePickerState> _inputPickerKey =
      GlobalKey<_InputDateRangePickerState>();

  @override
  void initState() {
    super.initState();
    _selectedStart = widget.initialDateRange?.start;
    _selectedEnd = widget.initialDateRange?.end;
    _entryMode = widget.initialEntryMode;
    _autoValidate = false;
  }

  void _handleOk() {
    if (_entryMode == DatePickerEntryMode.input) {
      final _InputDateRangePickerState picker = _inputPickerKey.currentState!;
      if (!picker.validate()) {
        setState(() {
          _autoValidate = true;
        });
        return;
      }
    }
    final DateTimeRange? selectedRange = _hasSelectedDateRange
        ? DateTimeRange(start: _selectedStart!, end: _selectedEnd!)
        : null;

    Navigator.pop(context, selectedRange);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode) {
        case DatePickerEntryMode.calendar:
          _autoValidate = false;
          _entryMode = DatePickerEntryMode.input;
          break;

        case DatePickerEntryMode.input:
          // Validate the range dates
          if (_selectedStart != null &&
              (_selectedStart!.isBefore(widget.firstDate) ||
                  _selectedStart!.isAfter(widget.lastDate))) {
            _selectedStart = null;
            // With no valid start date, having an end date makes no sense for the UI.
            _selectedEnd = null;
          }
          if (_selectedEnd != null &&
              (_selectedEnd!.isBefore(widget.firstDate) ||
                  _selectedEnd!.isAfter(widget.lastDate))) {
            _selectedEnd = null;
          }
          // If invalid range (start after end), then just use the start date
          if (_selectedStart != null &&
              _selectedEnd != null &&
              _selectedStart!.isAfter(_selectedEnd!)) {
            _selectedEnd = null;
          }
          _entryMode = DatePickerEntryMode.calendar;
          break;

        case DatePickerEntryMode.calendarOnly:
        case DatePickerEntryMode.inputOnly:
          assert(false, 'Can not change entry mode from $_entryMode');
          break;
      }
    });
  }

  void _handleStartDateChanged(DateTime? date) {
    setState(() => _selectedStart = date);
  }

  void _handleEndDateChanged(DateTime? date) {
    setState(() => _selectedEnd = date);
  }

  bool get _hasSelectedDateRange =>
      _selectedStart != null && _selectedEnd != null;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Orientation orientation = mediaQuery.orientation;
    final double textScaleFactor = math.min(mediaQuery.textScaleFactor, 1.3);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color onPrimarySurface = colors.brightness == Brightness.light
        ? colors.onPrimary
        : colors.onSurface;

    final Widget contents;
    final Size size;
    ShapeBorder? shape;
    final double elevation;
    final EdgeInsets insetPadding;
    final bool showEntryModeButton =
        _entryMode == DatePickerEntryMode.calendar ||
            _entryMode == DatePickerEntryMode.input;
    switch (_entryMode) {
      case DatePickerEntryMode.calendar:
      case DatePickerEntryMode.calendarOnly:
        contents = _CalendarRangePickerDialog(
          key: _calendarPickerKey,
          selectedStartDate: _selectedStart,
          selectedEndDate: _selectedEnd,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          currentDate: widget.currentDate,
          onStartDateChanged: _handleStartDateChanged,
          onEndDateChanged: _handleEndDateChanged,
          onConfirm: _hasSelectedDateRange ? _handleOk : null,
          onCancel: _handleCancel,
          entryModeButton: showEntryModeButton
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  padding: EdgeInsets.zero,
                  color: onPrimarySurface,
                  tooltip: localizations.inputDateModeButtonLabel,
                  onPressed: _handleEntryModeToggle,
                )
              : null,
          confirmText: widget.saveText ?? localizations.saveButtonLabel,
          helpText: widget.helpText ?? localizations.dateRangePickerHelpText,
        );
        size = mediaQuery.size;
        insetPadding = EdgeInsets.zero;
        shape = const RoundedRectangleBorder(borderRadius: BorderRadius.zero);
        elevation = 0;
        break;

      case DatePickerEntryMode.input:
      case DatePickerEntryMode.inputOnly:
        contents = _InputDateRangePickerDialog(
          selectedStartDate: _selectedStart,
          selectedEndDate: _selectedEnd,
          currentDate: widget.currentDate,
          picker: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: orientation == Orientation.portrait
                ? _inputFormPortraitHeight
                : _inputFormLandscapeHeight,
            child: Column(
              children: <Widget>[
                const Spacer(),
                _InputDateRangePicker(
                  key: _inputPickerKey,
                  initialStartDate: _selectedStart,
                  initialEndDate: _selectedEnd,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onStartDateChanged: _handleStartDateChanged,
                  onEndDateChanged: _handleEndDateChanged,
                  autofocus: true,
                  autovalidate: _autoValidate,
                  helpText: widget.helpText,
                  errorInvalidRangeText: widget.errorInvalidRangeText,
                  errorFormatText: widget.errorFormatText,
                  errorInvalidText: widget.errorInvalidText,
                  fieldStartHintText: widget.fieldStartHintText,
                  fieldEndHintText: widget.fieldEndHintText,
                  fieldStartLabelText: widget.fieldStartLabelText,
                  fieldEndLabelText: widget.fieldEndLabelText,
                ),
                const Spacer(),
              ],
            ),
          ),
          onConfirm: _handleOk,
          onCancel: _handleCancel,
          entryModeButton: showEntryModeButton
              ? IconButton(
                  icon: const Icon(Icons.calendar_today),
                  padding: EdgeInsets.zero,
                  color: onPrimarySurface,
                  tooltip: localizations.calendarModeButtonLabel,
                  onPressed: _handleEntryModeToggle,
                )
              : null,
          confirmText: widget.confirmText ?? localizations.okButtonLabel,
          cancelText: widget.cancelText ?? localizations.cancelButtonLabel,
          helpText: widget.helpText ?? localizations.dateRangePickerHelpText,
        );
        final DialogTheme dialogTheme = Theme.of(context).dialogTheme;
        size = orientation == Orientation.portrait
            ? _inputPortraitDialogSize
            : _inputRangeLandscapeDialogSize;
        insetPadding =
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);
        shape = dialogTheme.shape;
        elevation = dialogTheme.elevation ?? 24;
        break;
    }

    return Dialog(
      child: AnimatedContainer(
        width: size.width,
        height: size.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: textScaleFactor,
          ),
          child: Builder(builder: (BuildContext context) {
            return contents;
          }),
        ),
      ),
      insetPadding: insetPadding,
      shape: shape,
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
    );
  }
}

class _CalendarRangePickerDialog extends StatelessWidget {
  const _CalendarRangePickerDialog({
    Key? key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onConfirm,
    required this.onCancel,
    required this.confirmText,
    required this.helpText,
    this.entryModeButton,
  }) : super(key: key);

  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? currentDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String helpText;
  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final Orientation orientation = MediaQuery.of(context).orientation;
    final TextTheme textTheme = theme.textTheme;
    final Color headerForeground = colorScheme.brightness == Brightness.light
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final Color headerDisabledForeground = headerForeground.withOpacity(0.38);
    final String startDateText = _formatRangeStartDate(
        localizations, selectedStartDate, selectedEndDate);
    final String endDateText = _formatRangeEndDate(
        localizations, selectedStartDate, selectedEndDate, DateTime.now());
    final TextStyle? headlineStyle = textTheme.headline5;
    final TextStyle? startDateStyle = headlineStyle?.apply(
        color: selectedStartDate != null
            ? headerForeground
            : headerDisabledForeground);
    final TextStyle? endDateStyle = headlineStyle?.apply(
        color: selectedEndDate != null
            ? headerForeground
            : headerDisabledForeground);
    final TextStyle saveButtonStyle = textTheme.button!.apply(
        color: onConfirm != null ? headerForeground : headerDisabledForeground);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(
            onPressed: onCancel,
          ),
          actions: <Widget>[
            if (orientation == Orientation.landscape && entryModeButton != null)
              entryModeButton!,
            TextButton(
              onPressed: onConfirm,
              child: Text(confirmText, style: saveButtonStyle),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            child: Row(children: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width < 360 ? 42 : 72),
              Expanded(
                child: Semantics(
                  label: '$helpText $startDateText to $endDateText',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        helpText,
                        style: textTheme.overline!.apply(
                          color: headerForeground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Text(
                            startDateText,
                            style: startDateStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            ' – ',
                            style: startDateStyle,
                          ),
                          Flexible(
                            child: Text(
                              endDateText,
                              style: endDateStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (orientation == Orientation.portrait &&
                  entryModeButton != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: entryModeButton!,
                ),
            ]),
            preferredSize: const Size(double.infinity, 64),
          ),
        ),
        body: _CalendarDateRangePicker(
          initialStartDate: selectedStartDate,
          initialEndDate: selectedEndDate,
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: currentDate,
          onStartDateChanged: onStartDateChanged,
          onEndDateChanged: onEndDateChanged,
        ),
      ),
    );
  }
}

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _monthItemHeaderHeight = 58.0;
const double _monthItemFooterHeight = 12.0;
const double _monthItemRowHeight = 42.0;
const double _monthItemSpaceBetweenRows = 8.0;
const double _horizontalPadding = 8.0;
const double _maxCalendarWidthLandscape = 384.0;
const double _maxCalendarWidthPortrait = 480.0;

/// Displays a scrollable calendar grid that allows a user to select a range
/// of dates.
class _CalendarDateRangePicker extends StatefulWidget {
  /// Creates a scrollable calendar grid for picking date ranges.
  _CalendarDateRangePicker({
    Key? key,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  })  : initialStartDate = initialStartDate != null
            ? DateUtils.dateOnly(initialStartDate)
            : null,
        initialEndDate =
            initialEndDate != null ? DateUtils.dateOnly(initialEndDate) : null,
        assert(firstDate != null),
        assert(lastDate != null),
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()),
        super(key: key) {
    assert(
        this.initialStartDate == null ||
            this.initialEndDate == null ||
            !this.initialStartDate!.isAfter(initialEndDate!),
        'initialStartDate must be on or before initialEndDate.');
    assert(!this.lastDate.isBefore(this.firstDate),
        'firstDate must be on or before lastDate.');
  }

  /// The [DateTime] that represents the start of the initial date range selection.
  final DateTime? initialStartDate;

  /// The [DateTime] that represents the end of the initial date range selection.
  final DateTime? initialEndDate;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  /// Called when the user changes the start date of the selected range.
  final ValueChanged<DateTime>? onStartDateChanged;

  /// Called when the user changes the end date of the selected range.
  final ValueChanged<DateTime?>? onEndDateChanged;

  @override
  _CalendarDateRangePickerState createState() =>
      _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<_CalendarDateRangePicker> {
  final GlobalKey _scrollViewKey = GlobalKey();
  DateTime? _startDate;
  DateTime? _endDate;
  int _initialMonthIndex = 0;
  late ScrollController _controller;
  late bool _showWeekBottomDivider;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;

    // Calculate the index for the initially displayed month. This is needed to
    // divide the list of months into two `SliverList`s.
    final DateTime initialDate = widget.initialStartDate ?? widget.currentDate;
    if (!initialDate.isBefore(widget.firstDate) &&
        !initialDate.isAfter(widget.lastDate)) {
      _initialMonthIndex = DateUtils.monthDelta(widget.firstDate, initialDate);
    }

    _showWeekBottomDivider = _initialMonthIndex != 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.offset <= _controller.position.minScrollExtent) {
      setState(() {
        _showWeekBottomDivider = false;
      });
    } else if (!_showWeekBottomDivider) {
      setState(() {
        _showWeekBottomDivider = true;
      });
    }
  }

  int get _numberOfMonths =>
      DateUtils.monthDelta(widget.firstDate, widget.lastDate) + 1;

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      default:
        break;
    }
  }

  // This updates the selected date range using this logic:
  //
  // * From the unselected state, selecting one date creates the start date.
  //   * If the next selection is before the start date, reset date range and
  //     set the start date to that selection.
  //   * If the next selection is on or after the start date, set the end date
  //     to that selection.
  // * After both start and end dates are selected, any subsequent selection
  //   resets the date range and sets start date to that selection.
  void _updateSelection(DateTime date) {
    _vibrate();
    setState(() {
      if (_startDate != null &&
          _endDate == null &&
          !date.isBefore(_startDate!)) {
        _endDate = date;
        widget.onEndDateChanged?.call(_endDate);
      } else {
        _startDate = date;
        widget.onStartDateChanged?.call(_startDate!);
        if (_endDate != null) {
          _endDate = null;
          widget.onEndDateChanged?.call(_endDate);
        }
      }
    });
  }

  Widget _buildMonthItem(
      BuildContext context, int index, bool beforeInitialMonth) {
    final int monthIndex = beforeInitialMonth
        ? _initialMonthIndex - index - 1
        : _initialMonthIndex + index;
    final DateTime month =
        DateUtils.addMonthsToMonthDate(widget.firstDate, monthIndex);
    return _MonthItem(
      selectedDateStart: _startDate,
      selectedDateEnd: _endDate,
      currentDate: widget.currentDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      onChanged: _updateSelection,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Key sliverAfterKey = Key('sliverAfterKey');

    return Column(
      children: <Widget>[
        _DayHeaders(),
        if (_showWeekBottomDivider) const Divider(height: 0),
        Expanded(
          child: _CalendarKeyboardNavigator(
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialFocusedDay:
                _startDate ?? widget.initialStartDate ?? widget.currentDate,
            // In order to prevent performance issues when displaying the
            // correct initial month, 2 `SliverList`s are used to split the
            // months. The first item in the second SliverList is the initial
            // month to be displayed.
            child: CustomScrollView(
              key: _scrollViewKey,
              controller: _controller,
              center: sliverAfterKey,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) =>
                        _buildMonthItem(context, index, true),
                    childCount: _initialMonthIndex,
                  ),
                ),
                SliverList(
                  key: sliverAfterKey,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) =>
                        _buildMonthItem(context, index, false),
                    childCount: _numberOfMonths - _initialMonthIndex,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarKeyboardNavigator extends StatefulWidget {
  const _CalendarKeyboardNavigator({
    Key? key,
    required this.child,
    required this.firstDate,
    required this.lastDate,
    required this.initialFocusedDay,
  }) : super(key: key);

  final Widget child;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialFocusedDay;

  @override
  _CalendarKeyboardNavigatorState createState() =>
      _CalendarKeyboardNavigatorState();
}

class _CalendarKeyboardNavigatorState
    extends State<_CalendarKeyboardNavigator> {
  late Map<LogicalKeySet, Intent> _shortcutMap;
  late Map<Type, Action<Intent>> _actionMap;
  late FocusNode _dayGridFocus;
  TraversalDirection? _dayTraversalDirection;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();

    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft):
          const DirectionalFocusIntent(TraversalDirection.left),
      LogicalKeySet(LogicalKeyboardKey.arrowRight):
          const DirectionalFocusIntent(TraversalDirection.right),
      LogicalKeySet(LogicalKeyboardKey.arrowDown):
          const DirectionalFocusIntent(TraversalDirection.down),
      LogicalKeySet(LogicalKeyboardKey.arrowUp):
          const DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent:
          CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: _handleGridPreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: _handleDirectionFocus),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void dispose() {
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused) {
        _focusedDay ??= widget.initialFocusedDay;
      }
    });
  }

  /// Move focus to the next element after the day grid.
  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  /// Move focus to the previous element before the day grid.
  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  /// Move the internal focus date in the direction of the given intent.
  ///
  /// This will attempt to move the focused day to the next selectable day in
  /// the given direction. If the new date is not in the current month, then
  /// the page view will be scrolled to show the new date's month.
  ///
  /// For horizontal directions, it will move forward or backward a day (depending
  /// on the current [TextDirection]). For vertical directions it will move up and
  /// down a week at a time.
  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final DateTime? nextDate =
          _nextDateInDirection(_focusedDay!, intent.direction);
      if (nextDate != null) {
        _focusedDay = nextDate;
        _dayTraversalDirection = intent.direction;
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset =
      <TraversalDirection, int>{
    TraversalDirection.up: -DateTime.daysPerWeek,
    TraversalDirection.right: 1,
    TraversalDirection.down: DateTime.daysPerWeek,
    TraversalDirection.left: -1,
  };

  int _dayDirectionOffset(
      TraversalDirection traversalDirection, TextDirection textDirection) {
    // Swap left and right if the text direction if RTL
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left)
        traversalDirection = TraversalDirection.right;
      else if (traversalDirection == TraversalDirection.right)
        traversalDirection = TraversalDirection.left;
    }
    return _directionOffset[traversalDirection]!;
  }

  DateTime? _nextDateInDirection(DateTime date, TraversalDirection direction) {
    final TextDirection textDirection = Directionality.of(context);
    final DateTime nextDate = DateUtils.addDaysToDate(
        date, _dayDirectionOffset(direction, textDirection));
    if (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      return nextDate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: _shortcutMap,
      actions: _actionMap,
      focusNode: _dayGridFocus,
      onFocusChange: _handleGridFocusChange,
      child: _FocusedDate(
        date: _dayGridFocus.hasFocus ? _focusedDay : null,
        scrollDirection: _dayGridFocus.hasFocus ? _dayTraversalDirection : null,
        child: widget.child,
      ),
    );
  }
}

/// InheritedWidget indicating what the current focused date is for its children.
///
/// This is used by the [_MonthPicker] to let its children [_DayPicker]s know
/// what the currently focused date (if any) should be.
class _FocusedDate extends InheritedWidget {
  const _FocusedDate({
    Key? key,
    required Widget child,
    this.date,
    this.scrollDirection,
  }) : super(key: key, child: child);

  final DateTime? date;
  final TraversalDirection? scrollDirection;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !DateUtils.isSameDay(date, oldWidget.date) ||
        scrollDirection != oldWidget.scrollDirection;
  }

  static _FocusedDate? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
  }
}

class _DayHeaders extends StatelessWidget {
  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  /// ```
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  /// ```
  List<Widget> _getDayHeaders(
      TextStyle headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextStyle textStyle =
        themeData.textTheme.subtitle2!.apply(color: colorScheme.onSurface);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<Widget> labels = _getDayHeaders(textStyle, localizations);

    // Add leading and trailing containers for edges of the custom grid layout.
    labels.insert(0, Container());
    labels.add(Container());

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).orientation == Orientation.landscape
            ? _maxCalendarWidthLandscape
            : _maxCalendarWidthPortrait,
        maxHeight: _monthItemRowHeight,
      ),
      child: GridView.custom(
        shrinkWrap: true,
        gridDelegate: _monthItemGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          labels,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class _MonthItemGridDelegate extends SliverGridDelegate {
  const _MonthItemGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth =
        (constraints.crossAxisExtent - 2 * _horizontalPadding) /
            DateTime.daysPerWeek;
    return _MonthSliverGridLayout(
      crossAxisCount: DateTime.daysPerWeek + 2,
      dayChildWidth: tileWidth,
      edgeChildWidth: _horizontalPadding,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_MonthItemGridDelegate oldDelegate) => false;
}

const _MonthItemGridDelegate _monthItemGridDelegate = _MonthItemGridDelegate();

class _MonthSliverGridLayout extends SliverGridLayout {
  /// Creates a layout that uses equally sized and spaced tiles for each day of
  /// the week and an additional edge tile for padding at the start and end of
  /// each row.
  ///
  /// This is necessary to facilitate the painting of the range highlight
  /// correctly.
  const _MonthSliverGridLayout({
    required this.crossAxisCount,
    required this.dayChildWidth,
    required this.edgeChildWidth,
    required this.reverseCrossAxis,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(dayChildWidth != null && dayChildWidth >= 0),
        assert(edgeChildWidth != null && edgeChildWidth >= 0),
        assert(reverseCrossAxis != null);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The width in logical pixels of the day child widgets.
  final double dayChildWidth;

  /// The width in logical pixels of the edge child widgets.
  final double edgeChildWidth;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  /// The number of logical pixels from the leading edge of one row to the
  /// leading edge of the next row.
  double get _rowHeight {
    return _monthItemRowHeight + _monthItemSpaceBetweenRows;
  }

  /// The height in logical pixels of the children widgets.
  double get _childHeight {
    return _monthItemRowHeight;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return crossAxisCount * (scrollOffset ~/ _rowHeight);
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final int mainAxisCount = (scrollOffset / _rowHeight).ceil();
    return math.max(0, crossAxisCount * mainAxisCount - 1);
  }

  double _getCrossAxisOffset(double crossAxisStart, bool isPadding) {
    if (reverseCrossAxis) {
      return ((crossAxisCount - 2) * dayChildWidth + 2 * edgeChildWidth) -
          crossAxisStart -
          (isPadding ? edgeChildWidth : dayChildWidth);
    }
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final int adjustedIndex = index % crossAxisCount;
    final bool isEdge =
        adjustedIndex == 0 || adjustedIndex == crossAxisCount - 1;
    final double crossAxisStart =
        math.max(0, (adjustedIndex - 1) * dayChildWidth + edgeChildWidth);

    return SliverGridGeometry(
      scrollOffset: (index ~/ crossAxisCount) * _rowHeight,
      crossAxisOffset: _getCrossAxisOffset(crossAxisStart, isEdge),
      mainAxisExtent: _childHeight,
      crossAxisExtent: isEdge ? edgeChildWidth : dayChildWidth,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    assert(childCount >= 0);
    final int mainAxisCount = ((childCount - 1) ~/ crossAxisCount) + 1;
    final double mainAxisSpacing = _rowHeight - _childHeight;
    return _rowHeight * mainAxisCount - mainAxisSpacing;
  }
}

/// Displays the days of a given month and allows choosing a date range.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
class _MonthItem extends StatefulWidget {
  /// Creates a month item.
  _MonthItem({
    Key? key,
    required this.selectedDateStart,
    required this.selectedDateEnd,
    required this.currentDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.displayedMonth,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(firstDate != null),
        assert(lastDate != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDateStart == null ||
            !selectedDateStart.isBefore(firstDate)),
        assert(selectedDateEnd == null || !selectedDateEnd.isBefore(firstDate)),
        assert(
            selectedDateStart == null || !selectedDateStart.isAfter(lastDate)),
        assert(selectedDateEnd == null || !selectedDateEnd.isAfter(lastDate)),
        assert(selectedDateStart == null ||
            selectedDateEnd == null ||
            !selectedDateStart.isAfter(selectedDateEnd)),
        assert(currentDate != null),
        assert(onChanged != null),
        assert(displayedMonth != null),
        assert(dragStartBehavior != null),
        super(key: key);

  /// The currently selected start date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDateStart;

  /// The currently selected end date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDateEnd;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to scroll a
  /// date picker wheel will begin upon the detection of a drag gesture. If set
  /// to [DragStartBehavior.down] it will begin when a down event is first
  /// detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for
  ///    the different behaviors.
  final DragStartBehavior dragStartBehavior;

  @override
  _MonthItemState createState() => _MonthItemState();
}

class _MonthItemState extends State<_MonthItem> {
  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final int daysInMonth = DateUtils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
        daysInMonth,
        (int index) =>
            FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final DateTime? focusedDate = _FocusedDate.of(context)?.date;
    if (focusedDate != null &&
        DateUtils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Color _highlightColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withOpacity(0.12);
  }

  void _dayFocusChanged(bool focused) {
    if (focused) {
      final TraversalDirection? focusDirection =
          _FocusedDate.of(context)?.scrollDirection;
      if (focusDirection != null) {
        ScrollPositionAlignmentPolicy policy =
            ScrollPositionAlignmentPolicy.explicit;
        switch (focusDirection) {
          case TraversalDirection.up:
          case TraversalDirection.left:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
            break;
          case TraversalDirection.right:
          case TraversalDirection.down:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
            break;
        }
        Scrollable.ensureVisible(
          primaryFocus!.context!,
          duration: _monthScrollDuration,
          alignmentPolicy: policy,
        );
      }
    }
  }

  Widget _buildDayItem(BuildContext context, DateTime dayToBuild,
      int firstDayOffset, int daysInMonth) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final TextDirection textDirection = Directionality.of(context);
    final Color highlightColor = _highlightColor(context);
    final int day = dayToBuild.day;

    final bool isDisabled = dayToBuild.isAfter(widget.lastDate) ||
        dayToBuild.isBefore(widget.firstDate);

    BoxDecoration? decoration;
    TextStyle? itemStyle = textTheme.bodyText2;

    final bool isRangeSelected =
        widget.selectedDateStart != null && widget.selectedDateEnd != null;
    final bool isSelectedDayStart = widget.selectedDateStart != null &&
        dayToBuild.isAtSameMomentAs(widget.selectedDateStart!);
    final bool isSelectedDayEnd = widget.selectedDateEnd != null &&
        dayToBuild.isAtSameMomentAs(widget.selectedDateEnd!);
    final bool isInRange = isRangeSelected &&
        dayToBuild.isAfter(widget.selectedDateStart!) &&
        dayToBuild.isBefore(widget.selectedDateEnd!);

    _HighlightPainter? highlightPainter;

    if (isSelectedDayStart || isSelectedDayEnd) {
      // The selected start and end dates gets a circle background
      // highlight, and a contrasting text color.
      itemStyle = textTheme.bodyText2?.apply(color: colorScheme.onPrimary);
      decoration = BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      );

      if (isRangeSelected &&
          widget.selectedDateStart != widget.selectedDateEnd) {
        final _HighlightPainterStyle style = isSelectedDayStart
            ? _HighlightPainterStyle.highlightTrailing
            : _HighlightPainterStyle.highlightLeading;
        highlightPainter = _HighlightPainter(
          color: highlightColor,
          style: style,
          textDirection: textDirection,
        );
      }
    } else if (isInRange) {
      // The days within the range get a light background highlight.
      highlightPainter = _HighlightPainter(
        color: highlightColor,
        style: _HighlightPainterStyle.highlightAll,
        textDirection: textDirection,
      );
    } else if (isDisabled) {
      itemStyle = textTheme.bodyText2
          ?.apply(color: colorScheme.onSurface.withOpacity(0.38));
    } else if (DateUtils.isSameDay(widget.currentDate, dayToBuild)) {
      // The current day gets a different text color and a circle stroke
      // border.
      itemStyle = textTheme.bodyText2?.apply(color: colorScheme.primary);
      decoration = BoxDecoration(
        border: Border.all(color: colorScheme.primary, width: 1),
        shape: BoxShape.circle,
      );
    }

    // We want the day of month to be spoken first irrespective of the
    // locale-specific preferences or TextDirection. This is because
    // an accessibility user is more likely to be interested in the
    // day of month before the rest of the date, as they are looking
    // for the day of month. To do that we prepend day of month to the
    // formatted full date.
    String semanticLabel =
        '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}';
    if (isSelectedDayStart) {
      semanticLabel =
          localizations.dateRangeStartDateSemanticLabel(semanticLabel);
    } else if (isSelectedDayEnd) {
      semanticLabel =
          localizations.dateRangeEndDateSemanticLabel(semanticLabel);
    }

    Widget dayWidget = Container(
      decoration: decoration,
      child: Center(
        child: Semantics(
          label: semanticLabel,
          selected: isSelectedDayStart || isSelectedDayEnd,
          child: ExcludeSemantics(
            child: Text(localizations.formatDecimal(day), style: itemStyle),
          ),
        ),
      ),
    );

    if (highlightPainter != null) {
      dayWidget = CustomPaint(
        painter: highlightPainter,
        child: dayWidget,
      );
    }

    if (!isDisabled) {
      dayWidget = InkResponse(
        focusNode: _dayFocusNodes[day - 1],
        onTap: () => widget.onChanged(dayToBuild),
        radius: _monthItemRowHeight / 2 + 4,
        splashColor: colorScheme.primary.withOpacity(0.38),
        onFocusChange: _dayFocusChanged,
        child: dayWidget,
      );
    }

    return dayWidget;
  }

  Widget _buildEdgeContainer(BuildContext context, bool isHighlighted) {
    return Container(color: isHighlighted ? _highlightColor(context) : null);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;
    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset = DateUtils.firstDayOffset(year, month, localizations);
    final int weeks = ((daysInMonth + dayOffset) / DateTime.daysPerWeek).ceil();
    final double gridHeight =
        weeks * _monthItemRowHeight + (weeks - 1) * _monthItemSpaceBetweenRows;
    final List<Widget> dayItems = <Widget>[];

    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - dayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final Widget dayItem = _buildDayItem(
          context,
          dayToBuild,
          dayOffset,
          daysInMonth,
        );
        dayItems.add(dayItem);
      }
    }

    // Add the leading/trailing edge containers to each week in order to
    // correctly extend the range highlight.
    final List<Widget> paddedDayItems = <Widget>[];
    for (int i = 0; i < weeks; i++) {
      final int start = i * DateTime.daysPerWeek;
      final int end = math.min(
        start + DateTime.daysPerWeek,
        dayItems.length,
      );
      final List<Widget> weekList = dayItems.sublist(start, end);

      final DateTime dateAfterLeadingPadding =
          DateTime(year, month, start - dayOffset + 1);
      // Only color the edge container if it is after the start date and
      // on/before the end date.
      final bool isLeadingInRange = !(dayOffset > 0 && i == 0) &&
          widget.selectedDateStart != null &&
          widget.selectedDateEnd != null &&
          dateAfterLeadingPadding.isAfter(widget.selectedDateStart!) &&
          !dateAfterLeadingPadding.isAfter(widget.selectedDateEnd!);
      weekList.insert(0, _buildEdgeContainer(context, isLeadingInRange));

      // Only add a trailing edge container if it is for a full week and not a
      // partial week.
      if (end < dayItems.length ||
          (end == dayItems.length &&
              dayItems.length % DateTime.daysPerWeek == 0)) {
        final DateTime dateBeforeTrailingPadding =
            DateTime(year, month, end - dayOffset);
        // Only color the edge container if it is on/after the start date and
        // before the end date.
        final bool isTrailingInRange = widget.selectedDateStart != null &&
            widget.selectedDateEnd != null &&
            !dateBeforeTrailingPadding.isBefore(widget.selectedDateStart!) &&
            dateBeforeTrailingPadding.isBefore(widget.selectedDateEnd!);
        weekList.add(_buildEdgeContainer(context, isTrailingInRange));
      }

      paddedDayItems.addAll(weekList);
    }

    final double maxWidth =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? _maxCalendarWidthLandscape
            : _maxCalendarWidthPortrait;
    return Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          height: _monthItemHeaderHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: AlignmentDirectional.centerStart,
          child: ExcludeSemantics(
            child: Text(
              localizations.formatMonthYear(widget.displayedMonth),
              style: textTheme.bodyText2!
                  .apply(color: themeData.colorScheme.onSurface),
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: gridHeight,
          ),
          child: GridView.custom(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: _monthItemGridDelegate,
            childrenDelegate: SliverChildListDelegate(
              paddedDayItems,
              addRepaintBoundaries: false,
            ),
          ),
        ),
        const SizedBox(height: _monthItemFooterHeight),
      ],
    );
  }
}

/// Determines which style to use to paint the highlight.
enum _HighlightPainterStyle {
  /// Paints nothing.
  none,

  /// Paints a rectangle that occupies the leading half of the space.
  highlightLeading,

  /// Paints a rectangle that occupies the trailing half of the space.
  highlightTrailing,

  /// Paints a rectangle that occupies all available space.
  highlightAll,
}

/// This custom painter will add a background highlight to its child.
///
/// This highlight will be drawn depending on the [style], [color], and
/// [textDirection] supplied. It will either paint a rectangle on the
/// left/right, a full rectangle, or nothing at all. This logic is determined by
/// a combination of the [style] and [textDirection].
class _HighlightPainter extends CustomPainter {
  _HighlightPainter({
    required this.color,
    this.style = _HighlightPainterStyle.none,
    this.textDirection,
  });

  final Color color;
  final _HighlightPainterStyle style;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (style == _HighlightPainterStyle.none) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Rect rectLeft = Rect.fromLTWH(0, 0, size.width / 2, size.height);
    final Rect rectRight =
        Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);

    switch (style) {
      case _HighlightPainterStyle.highlightTrailing:
        canvas.drawRect(
          textDirection == TextDirection.ltr ? rectRight : rectLeft,
          paint,
        );
        break;
      case _HighlightPainterStyle.highlightLeading:
        canvas.drawRect(
          textDirection == TextDirection.ltr ? rectLeft : rectRight,
          paint,
        );
        break;
      case _HighlightPainterStyle.highlightAll:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
      case _HighlightPainterStyle.none:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _InputDateRangePickerDialog extends StatelessWidget {
  const _InputDateRangePickerDialog({
    Key? key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.currentDate,
    required this.picker,
    required this.onConfirm,
    required this.onCancel,
    required this.confirmText,
    required this.cancelText,
    required this.helpText,
    required this.entryModeButton,
  }) : super(key: key);

  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final DateTime? currentDate;
  final Widget picker;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String? confirmText;
  final String? cancelText;
  final String? helpText;
  final Widget? entryModeButton;

  String _formatDateRange(
      BuildContext context, DateTime? start, DateTime? end, DateTime now) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String startText = _formatRangeStartDate(localizations, start, end);
    final String endText = _formatRangeEndDate(localizations, start, end, now);
    if (start == null || end == null) {
      return localizations.unspecifiedDateRange;
    }
    if (Directionality.of(context) == TextDirection.ltr) {
      return '$startText – $endText';
    } else {
      return '$endText – $startText';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final Orientation orientation = MediaQuery.of(context).orientation;
    final TextTheme textTheme = theme.textTheme;

    final Color onPrimarySurfaceColor =
        colorScheme.brightness == Brightness.light
            ? colorScheme.onPrimary
            : colorScheme.onSurface;
    final TextStyle? dateStyle = orientation == Orientation.landscape
        ? textTheme.headline5?.apply(color: onPrimarySurfaceColor)
        : textTheme.headline4?.apply(color: onPrimarySurfaceColor);
    final String dateText = _formatDateRange(
        context, selectedStartDate, selectedEndDate, currentDate!);
    final String semanticDateText = selectedStartDate != null &&
            selectedEndDate != null
        ? '${localizations.formatMediumDate(selectedStartDate!)} – ${localizations.formatMediumDate(selectedEndDate!)}'
        : '';

    final Widget header = _DatePickerHeader(
      helpText: helpText ?? localizations.dateRangePickerHelpText,
      titleText: dateText,
      titleSemanticsLabel: semanticDateText,
      titleStyle: dateStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    final Widget actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            child: Text(cancelText ?? localizations.cancelButtonLabel),
            onPressed: onCancel,
          ),
          TextButton(
            child: Text(confirmText ?? localizations.okButtonLabel),
            onPressed: onConfirm,
          ),
        ],
      ),
    );

    switch (orientation) {
      case Orientation.portrait:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            header,
            Expanded(child: picker),
            actions,
          ],
        );

      case Orientation.landscape:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            header,
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: picker),
                  actions,
                ],
              ),
            ),
          ],
        );
    }
  }
}

/// Provides a pair of text fields that allow the user to enter the start and
/// end dates that represent a range of dates.
class _InputDateRangePicker extends StatefulWidget {
  /// Creates a row with two text fields configured to accept the start and end dates
  /// of a date range.
  _InputDateRangePicker({
    Key? key,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.helpText,
    this.errorFormatText,
    this.errorInvalidText,
    this.errorInvalidRangeText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
    this.autofocus = false,
    this.autovalidate = false,
  })  : initialStartDate = initialStartDate == null
            ? null
            : DateUtils.dateOnly(initialStartDate),
        initialEndDate =
            initialEndDate == null ? null : DateUtils.dateOnly(initialEndDate),
        assert(firstDate != null),
        firstDate = DateUtils.dateOnly(firstDate),
        assert(lastDate != null),
        lastDate = DateUtils.dateOnly(lastDate),
        assert(firstDate != null),
        assert(lastDate != null),
        assert(autofocus != null),
        assert(autovalidate != null),
        super(key: key);

  /// The [DateTime] that represents the start of the initial date range selection.
  final DateTime? initialStartDate;

  /// The [DateTime] that represents the end of the initial date range selection.
  final DateTime? initialEndDate;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// Called when the user changes the start date of the selected range.
  final ValueChanged<DateTime?>? onStartDateChanged;

  /// Called when the user changes the end date of the selected range.
  final ValueChanged<DateTime?>? onEndDateChanged;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String? helpText;

  /// Error text used to indicate the text in a field is not a valid date.
  final String? errorFormatText;

  /// Error text used to indicate the date in a field is not in the valid range
  /// of [firstDate] - [lastDate].
  final String? errorInvalidText;

  /// Error text used to indicate the dates given don't form a valid date
  /// range (i.e. the start date is after the end date).
  final String? errorInvalidRangeText;

  /// Hint text shown when the start date field is empty.
  final String? fieldStartHintText;

  /// Hint text shown when the end date field is empty.
  final String? fieldEndHintText;

  /// Label used for the start date field.
  final String? fieldStartLabelText;

  /// Label used for the end date field.
  final String? fieldEndLabelText;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// If true, this the date fields will validate and update their error text
  /// immediately after every change. Otherwise, you must call
  /// [_InputDateRangePickerState.validate] to validate.
  final bool autovalidate;

  @override
  _InputDateRangePickerState createState() => _InputDateRangePickerState();
}

/// The current state of an [_InputDateRangePicker]. Can be used to
/// [validate] the date field entries.
class _InputDateRangePickerState extends State<_InputDateRangePicker> {
  late String _startInputText;
  late String _endInputText;
  DateTime? _startDate;
  DateTime? _endDate;
  late TextEditingController _startController;
  late TextEditingController _endController;
  String? _startErrorText;
  String? _endErrorText;
  bool _autoSelected = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _startController = TextEditingController();
    _endDate = widget.initialEndDate;
    _endController = TextEditingController();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    if (_startDate != null) {
      _startInputText = localizations.formatCompactDate(_startDate!);
      final bool selectText = widget.autofocus && !_autoSelected;
      _updateController(_startController, _startInputText, selectText);
      _autoSelected = selectText;
    }

    if (_endDate != null) {
      _endInputText = localizations.formatCompactDate(_endDate!);
      _updateController(_endController, _endInputText, false);
    }
  }

  /// Validates that the text in the start and end fields represent a valid
  /// date range.
  ///
  /// Will return true if the range is valid. If not, it will
  /// return false and display an appropriate error message under one of the
  /// text fields.
  bool validate() {
    String? startError = _validateDate(_startDate);
    final String? endError = _validateDate(_endDate);
    if (startError == null && endError == null) {
      if (_startDate!.isAfter(_endDate!)) {
        startError = widget.errorInvalidRangeText ??
            MaterialLocalizations.of(context).invalidDateRangeLabel;
      }
    }
    setState(() {
      _startErrorText = startError;
      _endErrorText = endError;
    });
    return startError == null && endError == null;
  }

  DateTime? _parseDate(String? text) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    return localizations.parseCompactDate(text);
  }

  String? _validateDate(DateTime? date) {
    if (date == null) {
      return widget.errorFormatText ??
          MaterialLocalizations.of(context).invalidDateFormatLabel;
    } else if (date.isBefore(widget.firstDate) ||
        date.isAfter(widget.lastDate)) {
      return widget.errorInvalidText ??
          MaterialLocalizations.of(context).dateOutOfRangeLabel;
    }
    return null;
  }

  void _updateController(
      TextEditingController controller, String text, bool selectText) {
    TextEditingValue textEditingValue = controller.value.copyWith(text: text);
    if (selectText) {
      textEditingValue = textEditingValue.copyWith(
          selection: TextSelection(
        baseOffset: 0,
        extentOffset: text.length,
      ));
    }
    controller.value = textEditingValue;
  }

  void _handleStartChanged(String text) {
    setState(() {
      _startInputText = text;
      _startDate = _parseDate(text);
      widget.onStartDateChanged?.call(_startDate);
    });
    if (widget.autovalidate) {
      validate();
    }
  }

  void _handleEndChanged(String text) {
    setState(() {
      _endInputText = text;
      _endDate = _parseDate(text);
      widget.onEndDateChanged?.call(_endDate);
    });
    if (widget.autovalidate) {
      validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final InputDecorationTheme inputTheme =
        Theme.of(context).inputDecorationTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _startController,
            decoration: InputDecoration(
              border: inputTheme.border ?? const UnderlineInputBorder(),
              filled: inputTheme.filled,
              hintText: widget.fieldStartHintText ?? localizations.dateHelpText,
              labelText: widget.fieldStartLabelText ??
                  localizations.dateRangeStartLabel,
              errorText: _startErrorText,
            ),
            keyboardType: TextInputType.datetime,
            onChanged: _handleStartChanged,
            autofocus: widget.autofocus,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _endController,
            decoration: InputDecoration(
              border: inputTheme.border ?? const UnderlineInputBorder(),
              filled: inputTheme.filled,
              hintText: widget.fieldEndHintText ?? localizations.dateHelpText,
              labelText:
                  widget.fieldEndLabelText ?? localizations.dateRangeEndLabel,
              errorText: _endErrorText,
            ),
            keyboardType: TextInputType.datetime,
            onChanged: _handleEndChanged,
          ),
        ),
      ],
    );
  }
}
