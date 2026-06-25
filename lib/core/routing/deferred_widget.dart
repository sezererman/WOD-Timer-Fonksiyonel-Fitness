import 'package:flutter/material.dart';

/// Dart'ın "deferred loading" (gecikmeli yükleme) özelliğini
/// GoRouter ile sorunsuz kullanmak için modüler sarıcı (wrapper) widget.
/// 
/// Sayfa yalnızca kullanıcı o sekmeye veya rotaya yönlendiğinde RAM'e yüklenir.
class DeferredWidget extends StatefulWidget {
  final Future<void> Function() libraryLoader;
  final Widget Function() createWidget;
  final Widget? placeholder;

  const DeferredWidget({
    super.key,
    required this.libraryLoader,
    required this.createWidget,
    this.placeholder,
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    try {
      await widget.libraryLoader();
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return widget.createWidget();
    }
    
    if (_hasError) {
      return const Center(
        child: Text(
          'Sayfa yüklenirken bir hata oluştu.\nLütfen internet bağlantınızı kontrol edin.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }

    // Kütüphane indirilene veya belleğe alınana kadar gösterilecek geçici UI
    return widget.placeholder ?? const Center(child: CircularProgressIndicator());
  }
}
