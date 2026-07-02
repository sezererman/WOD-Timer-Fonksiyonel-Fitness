/// Uygulama genelinde kullanılan sabit metinler.
class AppStrings {
  AppStrings._();

  // Uygulama
  static const String appName = 'Fonksiyonel Fitness Timer';
  static const String appTagline = 'Her saniye sayılır!';

  // Antrenman Modları
  static const String emom = 'EMOM';
  static const String amrap = 'AMRAP';
  static const String tabata = 'TABATA';
  static const String forTime = 'FOR TIME';
  static const String custom = 'CUSTOM';

  // Mod Açıklamaları
  static const String emomDesc = 'Every Minute On the Minute';
  static const String amrapDesc = 'As Many Reps As Possible';
  static const String tabataDesc = '20s Work / 10s Rest';
  static const String forTimeDesc = 'Tamamlama süresi';
  static const String customDesc = 'Kendi zamanlayıcını oluştur';

  // Timer Fazları
  static const String work = 'WORK';
  static const String rest = 'REST';
  static const String prepare = 'HAZIRLAN';
  static const String cooldown = 'COOLDOWN';
  static const String completed = 'TAMAMLANDI!';

  // Butonlar
  static const String start = 'BAŞLA';
  static const String pause = 'DURAKLAT';
  static const String resume = 'DEVAM';
  static const String reset = 'SIFIRLA';
  static const String skip = 'ATLA';
  static const String save = 'KAYDET';
  static const String cancel = 'İPTAL';

  // Ayarlar
  static const String settings = 'Ayarlar';
  static const String soundEnabled = 'Ses Efektleri';
  static const String vibrationEnabled = 'Titreşim';
  static const String darkMode = 'Karanlık Mod';
  static const String language = 'Dil';

  // Geçmiş
  static const String history = 'Geçmiş';
  static const String noHistory = 'Henüz antrenman kaydı yok';
  static const String totalWorkouts = 'Toplam Antrenman';
  static const String totalTime = 'Toplam Süre';

  // Yapılandırma
  static const String rounds = 'Tur Sayısı';
  static const String workTime = 'Çalışma Süresi';
  static const String restTime = 'Dinlenme Süresi';
  static const String prepareTime = 'Hazırlık Süresi';
  static const String totalDuration = 'Toplam Süre';
}
