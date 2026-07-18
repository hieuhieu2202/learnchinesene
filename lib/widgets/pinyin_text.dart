import 'package:flutter/material.dart';

class PinyinText extends StatelessWidget {
  final String chinese;
  final String pinyin;
  final TextStyle? chineseStyle;
  final TextStyle? pinyinStyle;
  final WrapAlignment alignment;

  const PinyinText({
    super.key,
    required this.chinese,
    required this.pinyin,
    this.chineseStyle,
    this.pinyinStyle,
    this.alignment = WrapAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    // Split pinyin by spaces
    final List<String> pinyinParts =
        pinyin.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();

    // Split chinese by character
    final List<String> chars = chinese.split('');

    List<Widget> columns = [];
    int pIndex = 0;

    for (int i = 0; i < chars.length; i++) {
      final char = chars[i];
      // Check if it's a punctuation mark
      final isPunctuation =
          RegExp(r'''[。，！？；：“”（）【】《》、.,!?;:"'()\[\]<>\-—]+''').hasMatch(char);

      String py = '';
      if (!isPunctuation && pIndex < pinyinParts.length) {
        py = pinyinParts[pIndex];
        pIndex++;
      }

      columns.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: isPunctuation ? 1.0 : 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              py,
              style: pinyinStyle ??
                  const TextStyle(fontSize: 14, color: Colors.orange),
            ),
            Text(
              char,
              style: chineseStyle ?? const TextStyle(fontSize: 32),
            ),
          ],
        ),
      ));
    }

    return Wrap(
      alignment: alignment,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: columns,
    );
  }
}
