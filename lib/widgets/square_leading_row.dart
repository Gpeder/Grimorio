import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SquareLeadingRow extends MultiChildRenderObjectWidget {
  SquareLeadingRow({
    super.key,
    required Widget leading,
    required Widget child,
    this.gap = 16,
  }) : super(children: [leading, child]);

  final double gap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSquareLeadingRow(gap);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSquareLeadingRow renderObject,
  ) {
    renderObject.gap = gap;
  }
}

class _SquareLeadingParentData extends ContainerBoxParentData<RenderBox> {}

class RenderSquareLeadingRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SquareLeadingParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SquareLeadingParentData> {
  RenderSquareLeadingRow(this._gap);

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  RenderBox get _leading => firstChild!;
  RenderBox get _content => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SquareLeadingParentData) {
      child.parentData = _SquareLeadingParentData();
    }
  }

  double _side(double width, double Function(double contentWidth) heightFor) {
    var side = 0.0;
    for (var i = 0; i < 8; i++) {
      final height = heightFor(math.max(0.0, width - side - _gap));
      if (height <= side) break;
      side = height;
    }
    return side;
  }

  double _contentWidth(double width, double side) =>
      math.max(0.0, width - side - _gap);

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth);
    final width = constraints.maxWidth;

    final side = _side(width, (w) {
      _content.layout(BoxConstraints.tightFor(width: w), parentUsesSize: true);
      return _content.size.height;
    });

    _content.layout(
      BoxConstraints.tightFor(width: _contentWidth(width, side)),
      parentUsesSize: true,
    );
    final finalSide = math.max(side, _content.size.height);
    _leading.layout(BoxConstraints.tight(Size.square(finalSide)));

    (_leading.parentData! as _SquareLeadingParentData).offset = Offset.zero;
    (_content.parentData! as _SquareLeadingParentData).offset = Offset(
      finalSide + _gap,
      (finalSide - _content.size.height) / 2,
    );

    size = constraints.constrain(Size(width, finalSide));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final side = _side(
      width,
      (w) => _content.getDryLayout(BoxConstraints.tightFor(width: w)).height,
    );
    return constraints.constrain(Size(width, side));
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _side(width, _content.getMinIntrinsicHeight);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _side(width, _content.getMaxIntrinsicHeight);

  @override
  double computeMinIntrinsicWidth(double height) =>
      _content.getMinIntrinsicWidth(height) +
      _gap +
      (height.isFinite ? height : 0);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _content.getMaxIntrinsicWidth(height) +
      _gap +
      (height.isFinite ? height : 0);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}
