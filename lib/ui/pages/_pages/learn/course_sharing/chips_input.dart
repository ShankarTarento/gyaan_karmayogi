import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../constants/_constants/color_constants.dart';

typedef ChipsInputSuggestions<CourseSharingUserDataModel>
    = Future<List<CourseSharingUserDataModel>> Function(String query);
typedef ChipSelected<CourseSharingUserDataModel> = void Function(
    CourseSharingUserDataModel data, bool selected);
typedef ChipsBuilder<CourseSharingUserDataModel> = Widget Function(
    BuildContext context,
    ChipsInputState<CourseSharingUserDataModel> state,
    CourseSharingUserDataModel data);
typedef TextInputActionCallback<CourseSharingUserDataModel> = void Function(
    TextInputAction action,
    String text,
    ChipsInputState<CourseSharingUserDataModel> state);

class ChipsInput<CourseSharingUserDataModel> extends StatefulWidget {
  const ChipsInput({
    Key key,
    this.decoration = const InputDecoration(),
    @required this.chipBuilder,
    @required this.suggestionBuilder,
    @required this.findSuggestions,
    @required this.onChanged,
    @required this.onPerformAction,
    this.onChipTapped,
  }) : super(key: key);

  final InputDecoration decoration;
  final ChipsInputSuggestions findSuggestions;
  final ValueChanged<List<CourseSharingUserDataModel>> onChanged;
  final ValueChanged<CourseSharingUserDataModel> onChipTapped;
  final ChipsBuilder<CourseSharingUserDataModel> chipBuilder;
  final ChipsBuilder<CourseSharingUserDataModel> suggestionBuilder;
  final TextInputActionCallback<CourseSharingUserDataModel> onPerformAction;

  @override
  ChipsInputState<CourseSharingUserDataModel> createState() =>
      ChipsInputState<CourseSharingUserDataModel>();
}

class ChipsInputState<CourseSharingUserDataModel>
    extends State<ChipsInput<CourseSharingUserDataModel>>
    implements TextInputClient {
  static const kObjectReplacementChar = 0xFFFC;

  List<CourseSharingUserDataModel> _chips = List<CourseSharingUserDataModel>();
  List<CourseSharingUserDataModel> _suggestions;
  int _searchId = 0;

  FocusNode _focusNode;
  TextEditingValue _value = TextEditingValue();
  TextInputConnection _connection;

  final ScrollController _suggestionScrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  TextEditingValue get currentTextEditingValue => _textEditingController.value;

  @override
  set currentTextEditingValue(TextEditingValue value) {
    setState(() {
      _textEditingController.value = value;
    });
  }

  bool get _hasInputConnection => _connection != null && _connection.attached;

  void requestKeyboard() {
    if (!_focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void selectSuggestion(List<CourseSharingUserDataModel> data) {
    setState(() {
      _chips = data;
      _updateTextInputState();
      _suggestions = null;
      scrollToBottom();
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  void resetSuggestion() {
    setState(() {
      _suggestions = null;
    });
  }

  void deleteChip(List<CourseSharingUserDataModel> data) {
    print("TEST_LOG==delete====updateEditingValue==>${data.length}");
    setState(() {
      _chips = data;
      _updateTextInputState();
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    _textEditingController.addListener(_editTextListener);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _openInputConnection();
    } else {
      _closeInputConnectionIfNeeded();
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _scrollController.dispose();
    _textEditingController.dispose();
    _suggestionScrollController.dispose();
    _closeInputConnectionIfNeeded();
    super.dispose();
  }

  void _openInputConnection() {
    if (!_hasInputConnection) {
      _connection = TextInput.attach(this, TextInputConfiguration());
      _connection.setEditingState(_value);
    }
    _connection.show();
  }

  void _closeInputConnectionIfNeeded() {
    if (_hasInputConnection) {
      _connection.close();
      _connection = null;
      _updateTextInputState();
    }
  }

  @override
  Widget build(BuildContext context) {
    var chipsChildren = _chips
        .map<Widget>(
          (data) => widget.chipBuilder(context, this, data),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: requestKeyboard,
            child: Container(
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  InputDecorator(
                    textAlign: TextAlign.start,
                    decoration: widget.decoration,
                    isFocused: _focusNode.hasFocus,
                    isEmpty: _value.text.length == 0,
                    child: Scrollbar(
                      controller: _scrollController,
                      thickness: 8,
                      thumbVisibility: true,
                      child: Container(
                        height: 100, // Set a fixed height or adjust as needed
                        child: ListView(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          children: [
                            Wrap(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 12),
                                  child: Wrap(
                                    children: chipsChildren,
                                    spacing: 4.0,
                                    runSpacing: 4.0,
                                  ),
                                ),
                                Container(
                                  height: null,
                                  width: double.maxFinite,
                                  padding: EdgeInsets.only(right: 8),
                                  child: TextField(
                                    focusNode: _focusNode,
                                    controller: _textEditingController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    style: GoogleFonts.lato(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.25,
                                      height: 1.5,
                                    ),
                                    onSubmitted: _submitted,
                                  ),
                                ),
                              ],
                              spacing: 0.0,
                              runSpacing: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Hint Text
                  IgnorePointer(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 16.0,
                          top: 18.0), // Adjust left and top as needed
                      child: Text(
                        "To:",
                        style: GoogleFonts.lato(
                            color: AppColors.darkBlue.withOpacity(1.0),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.25), // Customize text color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if ((_suggestions ?? []).isNotEmpty)
          Container(
              margin: EdgeInsets.only(top: 2.0),
              height: (_suggestions?.length <= 2) ? 100 : 160,
              child: Card(
                  child: Scrollbar(
                controller: _suggestionScrollController,
                thickness: 8,
                thumbVisibility: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    return widget.suggestionBuilder(
                        context, this, _suggestions[index]);
                  },
                ),
              )))
      ],
    );
  }

  void _submitted(String value) {
    handleTextInputAction(
        TextInputAction.done, _textEditingController.text, this);
  }

  void scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _editTextListener() {
    print(
        "TEST_LOG==txt====updateEditingValue==> ${_textEditingController.text}");
    _onSearchChanged(_textEditingController.text);
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    print("TEST_LOG==txt====updateEditingValue==>");
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void connectionClosed() {
    _focusNode.unfocus();
  }

  @override
  void performAction(TextInputAction action) {
    handleTextInputAction(action, _textEditingController.text, this);
  }

  void _onSearchChanged(String value) async {
    final localId = ++_searchId;
    final results = await widget.findSuggestions(value);
    if (_searchId == localId && mounted) {
      setState(() => _suggestions = results);
    }
  }

  void handleTextInputAction(TextInputAction action, String text,
      ChipsInputState<CourseSharingUserDataModel> state) {
    widget.onPerformAction(action, text, state);
    _focusNode.unfocus();
    _suggestions = [];
  }

  void _updateTextInputState() {
    try {
      _textEditingController.text = '';
    } catch (_e) {}
  }

  @override
  AutofillScope get currentAutofillScope => throw UnimplementedError();

  @override
  void didChangeInputControl(
      TextInputControl oldControl, TextInputControl newControl) {}

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void performSelector(String selectorName) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void showToolbar() {}
}
