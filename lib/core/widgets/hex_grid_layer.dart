import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:ui' as ui;
import '../models/hex_cell.dart';
import 'hex_cell_color_mapper.dart';
 
class HexGridLayer extends StatelessWidget {
  final List<HexCell> cells;
  final MapCamera camera;
  final HexGridMode mode;
 
  const HexGridLayer({
    super.key,
    required this.cells,
    required this.camera,
    this.mode = HexGridMode.gameA,
  });
 
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexGridPainter(cells: cells, camera: camera, mode: mode),
      child: const SizedBox.expand(),
    );
  }
}
 
class _HexGridPainter extends CustomPainter {
  final List<HexCell> cells;
  final MapCamera camera;
  final HexGridMode mode;
 
  _HexGridPainter({
    required this.cells,
    required this.camera,
    required this.mode,
  });
 
  @override
  void paint(Canvas canvas, Size size) {
    for (final cell in cells) {
      _drawCell(canvas, cell, size);
    }
  }
 
  void _drawCell(Canvas canvas, HexCell cell, Size size) {
    final pixelVertices = cell.vertices.map((v) {
      final point = camera.latLngToScreenPoint(v);
      return Offset(point.x, point.y);
    }).toList();
 
    if (pixelVertices.isEmpty) return;
 
    final path = ui.Path()..moveTo(pixelVertices[0].dx, pixelVertices[0].dy);
    for (int i = 1; i < pixelVertices.length; i++) {
      path.lineTo(pixelVertices[i].dx, pixelVertices[i].dy);
    }
    path.close();
 
    switch (cell.state) {
      case CellState.hidden:
        _drawHidden(canvas, path);
        break;
      case CellState.revealed:
        _drawRevealed(canvas, path, cell, pixelVertices);
        break;
      case CellState.found:
        _drawFound(canvas, path, cell, pixelVertices);
        break;
    }
  }
 
  void _drawHidden(Canvas canvas, ui.Path path) {
    final fillPaint = ui.Paint()
      ..color = Colors.blueGrey.shade700.withAlpha(64)
      ..style = PaintingStyle.fill;
    final strokePaint = ui.Paint()
      ..color = Colors.blueGrey.shade900.withAlpha(128)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }
 
  void _drawRevealed(
    Canvas canvas,
    ui.Path path,
    HexCell cell,
    List<Offset> vertices,
  ) {
    final color = HexCellColorMapper.revealedColor(cell, mode);

    final fillPaint = ui.Paint()
      ..color = color.withAlpha(209)
      ..style = PaintingStyle.fill;
    final strokePaint = ui.Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
 
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
 
    // Label: nel Gioco A mostra adiacenti, nel Gioco B mostra distanza dal target
    if (mode == HexGridMode.gameB) {
      if (cell.distanceToNearest != null && cell.distanceToNearest! > 0) {
        _drawLabel(
          canvas,
          '${cell.distanceToNearest}',
          _centroid(vertices),
          Colors.white,
        );
      }
    } else {
      if (cell.adjacentSafeZones > 0) {
        _drawLabel(
          canvas,
          '${cell.adjacentSafeZones}',
          _centroid(vertices),
          HexCellColorMapper.textColor(cell),
        );
      }
    }
  }
 
  void _drawFound(
    Canvas canvas,
    ui.Path path,
    HexCell cell,
    List<Offset> vertices,
  ) {
    final fillPaint = Paint()
      ..color = const Color(0xFF1B5E20).withAlpha(235)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
 
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
 
    _drawLabel(canvas, '✓', _centroid(vertices), Colors.white, fontSize: 14);
  }
 
  void _drawLabel(
    Canvas canvas,
    String text,
    Offset center,
    Color color, {
    double fontSize = 11,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }
 
  Offset _centroid(List<Offset> vertices) {
    double x = 0, y = 0;
    for (final v in vertices) {
      x += v.dx;
      y += v.dy;
    }
    return Offset(x / vertices.length, y / vertices.length);
  }
 
  @override
  bool shouldRepaint(covariant _HexGridPainter oldDelegate) =>
      oldDelegate.cells != cells ||
      oldDelegate.camera != camera ||
      oldDelegate.mode != mode;
}