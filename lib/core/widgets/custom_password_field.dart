import 'package:flutter/material.dart';
import '../utils/password_validator.dart';
import '../constants/app_colors.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool showStrengthIndicator;
  final bool enabled;

  const CustomPasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Şifre',
    this.prefixIcon = Icons.lock_outline,
    this.validator,
    this.showStrengthIndicator = true,
    this.enabled = true,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;
  double _strength = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.showStrengthIndicator) {
      widget.controller.addListener(_updateStrength);
      _updateStrength();
    }
  }

  @override
  void dispose() {
    if (widget.showStrengthIndicator) {
      widget.controller.removeListener(_updateStrength);
    }
    super.dispose();
  }

  void _updateStrength() {
    final newStrength = calculatePasswordStrength(widget.controller.text);
    if (newStrength != _strength) {
      setState(() {
        _strength = newStrength;
      });
    }
  }

  Color _getStrengthColor() {
    if (_strength < 0.3) return Colors.redAccent;
    if (_strength < 0.7) return Colors.orangeAccent;
    return AppColors.primary; // CrossFit temasına uygun Neon Yeşil veya birincil renk
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscureText,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
        if (widget.showStrengthIndicator) ...[
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    height: 6,
                    width: constraints.maxWidth * _strength,
                    decoration: BoxDecoration(
                      color: _getStrengthColor(),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: _strength > 0.7 
                        ? [BoxShadow(color: _getStrengthColor().withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)] 
                        : null,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          if (_strength > 0)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _strength < 0.3
                    ? 'Zayıf Şifre'
                    : _strength < 0.7
                        ? 'Orta Güçte Şifre'
                        : 'Güçlü Şifre',
                key: ValueKey<double>(_strength),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStrengthColor(),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ],
    );
  }
}
