import 'package:flutter/material.dart';

/// Lazy yükleme yapan IndexedStack.
///
/// PERFORMANS: Standart IndexedStack tüm child widget'ları
/// başlangıçta aynı anda build eder (4 sekme = 4 sayfa, 4 Supabase sorgusu).
///
/// Bu widget yalnızca kullanıcının ziyaret ettiği sekmeyi build eder.
/// İlk ziyaretten sonra widget ağacında kalır (IndexedStack davranışı),
/// dolayısıyla state korunur.
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late final List<bool> _activated;

  @override
  void initState() {
    super.initState();
    // Yalnızca başlangıç sekmesi aktif — diğerleri SizedBox.shrink()
    _activated = List.filled(widget.children.length, false);
    _activated[widget.index] = true;
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kullanıcı sekmeye geçtiğinde aktive et — bir daha SizedBox olmaz
    if (!_activated[widget.index]) {
      _activated[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(
        widget.children.length,
        (i) => _activated[i] ? widget.children[i] : const SizedBox.shrink(),
      ),
    );
  }
}
