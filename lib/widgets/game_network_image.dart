import 'package:flutter/material.dart';

class GameNetworkImage extends StatelessWidget {
  const GameNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fallbackEmoji = '🐼',
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final String fallbackEmoji;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Text(
            fallbackEmoji,
            style: TextStyle(fontSize: (height ?? 64) * .42),
          ),
        ),
      ),
    );
  }
}
