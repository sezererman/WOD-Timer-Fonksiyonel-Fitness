import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../bloc/share_form/workout_share_form_cubit.dart';
import '../bloc/share_form/workout_share_form_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../community/domain/repositories/workout_share_repository.dart';
import 'package:go_router/go_router.dart';

class ShareWorkoutScreen extends StatelessWidget {
  const ShareWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkoutShareFormCubit(
        repository: sl<WorkoutShareRepository>(),
        authBloc: context.read<AuthBloc>(),
      ),
      child: const _ShareWorkoutView(),
    );
  }
}

class _ShareWorkoutView extends StatefulWidget {
  const _ShareWorkoutView();

  @override
  State<_ShareWorkoutView> createState() => _ShareWorkoutViewState();
}

class _ShareWorkoutViewState extends State<_ShareWorkoutView> {
  final TextEditingController _tipsController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  // Exercise input controllers
  TextEditingController? _autoCompleteController;
  final TextEditingController _exSetsController = TextEditingController();
  final TextEditingController _exRepsController = TextEditingController();

  final List<String> _workoutTypes = ['AMRAP', 'FOR_TIME', 'EMOM', 'TABATA'];

  static const List<String> _popularExercises = [
    'Air Squat', 'Back Squat', 'Front Squat', 'Overhead Squat',
    'Deadlift', 'Sumo Deadlift High Pull', 'Medicine Ball Clean',
    'Clean', 'Power Clean', 'Squat Clean', 'Hang Clean',
    'Jerk', 'Push Jerk', 'Split Jerk',
    'Snatch', 'Power Snatch', 'Squat Snatch', 'Hang Snatch',
    'Thruster', 'Wall Ball',
    'Pull-up', 'Chest-to-Bar Pull-up', 'Bar Muscle-up', 'Ring Muscle-up',
    'Toes-to-Bar', 'Knees-to-Elbows',
    'Push-up', 'Handstand Push-up', 'Handstand Walk',
    'Double Under', 'Single Under',
    'Box Jump', 'Box Jump Over',
    'Burpee', 'Burpee Box Jump Over', 'Bar-Facing Burpee',
    'Kettlebell Swing', 'Dumbbell Snatch', 'Clean and Jerk',
    'Rowing', 'Assault Bike', 'SkiErg', 'Running'
  ];

  @override
  void initState() {
    super.initState();
    _tipsController.addListener(() {
      context.read<WorkoutShareFormCubit>().updateTips(_tipsController.text);
    });
  }

  @override
  void dispose() {
    _tipsController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _exSetsController.dispose();
    _exRepsController.dispose();
    super.dispose();
  }

  void _updateDuration() {
    final int min = int.tryParse(_minutesController.text) ?? 0;
    final int sec = int.tryParse(_secondsController.text) ?? 0;
    context.read<WorkoutShareFormCubit>().setDuration((min * 60) + sec);
  }

  void _addExercise() {
    if (_autoCompleteController == null || _autoCompleteController!.text.trim().isEmpty) return;
    
    context.read<WorkoutShareFormCubit>().addExercise(
      _autoCompleteController!.text.trim(),
      int.tryParse(_exSetsController.text),
      int.tryParse(_exRepsController.text),
    );

    _autoCompleteController!.clear();
    _exSetsController.clear();
    _exRepsController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutShareFormCubit, WorkoutShareFormState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
          );
        }
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Antrenman başarıyla paylaşıldı!'), backgroundColor: Colors.green),
          );
          context.pop(true); // Geri dön ve refresh tetikle
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'ANTRENMAN PAYLAŞ',
              style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('ANTRENMAN TİPİ'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: _workoutTypes.map((type) {
                        final isSelected = state.workoutType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              context.read<WorkoutShareFormCubit>().setWorkoutType(type);
                            }
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: AppColors.surface,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('TOPLAM SÜRE'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_minutesController, 'Dakika', keyboardType: TextInputType.number, onChanged: (_) => _updateDuration()),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(_secondsController, 'Saniye', keyboardType: TextInputType.number, onChanged: (_) => _updateDuration()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('HAREKETLER'),
                    const SizedBox(height: 12),
                    if (state.exercises.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.exercises.length,
                        itemBuilder: (context, index) {
                          final ex = state.exercises[index];
                          String detail = '';
                          if (ex.sets != null && ex.reps != null) {
                            detail = '${ex.sets} x ${ex.reps}';
                          } else if (ex.reps != null) {
                            detail = '${ex.reps} Tekrar';
                          }
                          return Card(
                            color: AppColors.surface,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: detail.isNotEmpty ? Text(detail, style: const TextStyle(color: AppColors.textHint)) : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => context.read<WorkoutShareFormCubit>().removeExercise(index),
                              ),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          _buildExerciseAutocomplete(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_exSetsController, 'Set (Ops)', keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildTextField(_exRepsController, 'Tekrar (Ops)', keyboardType: TextInputType.number)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _addExercise,
                            icon: const Icon(Icons.add, color: AppColors.primary),
                            label: const Text('Hareketi Ekle', style: TextStyle(color: AppColors.primary)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              minimumSize: const Size(double.infinity, 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('NOTLAR & TAVSİYELER (OPSİYONEL)'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _tipsController, 
                      'Bu antrenmanı yapacaklara tavsiyelerin neler? (Max 300 karakter)', 
                      maxLines: 4,
                      maxLength: 300,
                    ),
                    
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: state.isValid && !state.isSubmitting
                          ? () => context.read<WorkoutShareFormCubit>().submit()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade800,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: state.isSubmitting
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'TOPLULUKTA PAYLAŞ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _popularExercises.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        // Selection is automatically placed into the controller by the widget
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        _autoCompleteController = textEditingController;
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onSubmitted: (String value) {
            onFieldSubmitted();
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Hareket Adı (Örn: Double Under)',
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width - 64, // Ekran genişliğinden paddingleri çıkarıyoruz
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        option,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterStyle: const TextStyle(color: AppColors.textHint),
      ),
    );
  }
}
