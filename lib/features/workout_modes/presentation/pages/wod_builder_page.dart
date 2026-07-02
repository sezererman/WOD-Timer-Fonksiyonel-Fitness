import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../design_system/widgets/gradient_background.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../timer/domain/entities/blocks/workout_block.dart';
import '../../../timer/domain/entities/blocks/single_interval_block.dart';
import '../../../timer/domain/entities/timer_config.dart';
import '../../../timer/presentation/pages/timer_page.dart';

class WodBuilderPage extends StatefulWidget {
  const WodBuilderPage({super.key});

  @override
  State<WodBuilderPage> createState() => _WodBuilderPageState();
}

class _WodBuilderPageState extends State<WodBuilderPage> {
  final List<WorkoutBlock> _blocks = [];
  final _uuid = const Uuid();

  void _showAddBlockModal() {
    String name = 'Custom Block';
    int workSeconds = 60;
    int restSeconds = 0;
    int rounds = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'BLOK EKLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: name,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Blok Adı',
                      labelStyle: TextStyle(color: AppColors.textHint),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textHint),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: workSeconds.toString(),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Çalışma (sn)',
                            labelStyle: TextStyle(color: AppColors.textHint),
                          ),
                          onChanged: (val) => workSeconds = int.tryParse(val) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: restSeconds.toString(),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Dinlenme (sn)',
                            labelStyle: TextStyle(color: AppColors.textHint),
                          ),
                          onChanged: (val) => restSeconds = int.tryParse(val) ?? 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: rounds.toString(),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Tur Sayısı (Rounds)',
                      labelStyle: TextStyle(color: AppColors.textHint),
                    ),
                    onChanged: (val) => rounds = int.tryParse(val) ?? 1,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'EKLE',
                      onPressed: () {
                        setState(() {
                          _blocks.add(
                            SingleIntervalBlock(
                              id: _uuid.v4(),
                              name: name.isEmpty ? 'Custom Block' : name,
                              workSeconds: workSeconds,
                              restSeconds: restSeconds,
                              rounds: rounds,
                            ),
                          );
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startWorkout() {
    if (_blocks.isEmpty) return;

    final config = TimerConfig(
      blocks: _blocks,
      rounds: 1, // Legacy (Artık blocks dolu olduğu için bu önemsiz)
      workSeconds: 0,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TimerPage(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('CUSTOM WOD BUILDER'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _blocks.isEmpty
                    ? const Center(
                        child: Text(
                          'Henüz blok eklenmedi.\nAşağıdan ekleyebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textHint),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _blocks.length,
                        itemBuilder: (context, index) {
                          final block = _blocks[index];
                          return Card(
                            color: AppColors.backgroundCard,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.fitness_center, color: AppColors.primary),
                              title: Text(
                                block.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Toplam: ${block.totalDurationSeconds} saniye',
                                style: const TextStyle(color: AppColors.textHint),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() => _blocks.removeAt(index));
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        label: const Text('Blok Ekle', style: TextStyle(color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _showAddBlockModal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        text: 'BAŞLAT',
                        icon: Icons.play_arrow_rounded,
                        color: _blocks.isEmpty ? Colors.grey : AppColors.primary,
                        onPressed: _blocks.isEmpty ? null : _startWorkout,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
