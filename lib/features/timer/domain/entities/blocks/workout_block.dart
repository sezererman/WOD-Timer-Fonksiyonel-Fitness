import 'package:equatable/equatable.dart';

/// Tüm antrenman bloklarının türeyeceği temel soyut (abstract) sınıf.
/// 'Composite Design Pattern' temel alınarak oluşturulmuştur.
/// Bir WorkoutBlock, basit bir yaprak (leaf - örneğin bir AMRAP seti) 
/// ya da karmaşık bir dal (branch - örneğin birden fazla setin tekrarı) olabilir.
abstract class WorkoutBlock extends Equatable {
  /// Bloğun benzersiz kimliği (Sıralama ve state takibi için gerekli).
  final String id;

  /// Bloğun kullanıcıya gösterilecek ismi (Örn: "Isınma", "5 dk AMRAP").
  final String name;

  const WorkoutBlock({
    required this.id,
    required this.name,
  });

  /// Bu bloğun *toplam* ne kadar süreceğini hesaplar (saniye cinsinden).
  /// Dal (branch) bloklarda alt blokların sürelerinin toplamını döndürür.
  int get totalDurationSeconds;

  // Not: İleride bu bloğu listeye/ağaca yaymak (flatten) için 
  // List<TimerPhase> toPhases() gibi bir metod eklenebilir, 
  // şimdilik sadece veri omurgasına odaklanıyoruz.
}
