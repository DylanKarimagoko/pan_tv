import 'package:flutter/material.dart';
import 'package:pan_tv/utils/styles.dart';
import 'package:pan_tv/utils/triangle_paint.dart';

class GenreWidget extends StatefulWidget {
  const GenreWidget(
      {super.key,
      required this.onTap,
      required this.selected,
      required this.title});
  final VoidCallback onTap;
  final bool selected;
  final String title;

  @override
  State<GenreWidget> createState() => _GenreWidgetState();
}

class _GenreWidgetState extends State<GenreWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: .8),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onTap,
            splashColor: Styles.mainColor,
            child: Ink(
              color: Styles.mainGrey,
              child: Container(
                width: size.width * .25,
                height: size.height * .07,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            width: 2,
                            color: widget.selected
                                ? Styles.mainColor
                                : Colors.transparent))),
                child: Text(
                  widget.title,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
          widget.selected
              ? RotatedBox(
                  quarterTurns: 2,
                  child: CustomPaint(
                    painter: TrianglePainter(
                      strokeColor: Styles.mainGrey,
                      strokeWidth: 10,
                      paintingStyle: PaintingStyle.fill,
                    ),
                    child: SizedBox(
                      width: size.width * .05,
                      height: size.height * .01,
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
