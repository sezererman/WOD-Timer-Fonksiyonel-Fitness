import 'dart:convert';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_share_model.dart';
import 'workout_share_local_datasource.dart';

class WorkoutShareLocalDataSourceImpl implements WorkoutShareLocalDataSource {
  static const String boxName = 'workout_share_box';
  static const String cacheKey = 'cached_workouts';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<void> cacheSharedWorkouts(List<WorkoutShareModel> workouts) async {
    try {
      final box = await _getBox();
      final jsonList = workouts.map((w) => w.toJson()).toList();
      await box.put(cacheKey, json.encode(jsonList));
    } catch (e) {
      throw const CacheException('Gönderiler önbelleğe alınamadı.');
    }
  }

  @override
  Future<List<WorkoutShareModel>> getCachedSharedWorkouts() async {
    try {
      final box = await _getBox();
      final jsonString = box.get(cacheKey) as String?;
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(jsonString);
        return decodedList.map((jsonObj) => WorkoutShareModel.fromJson(jsonObj as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw const CacheException('Önbellekteki gönderiler okunamadı.');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await _getBox();
      await box.delete(cacheKey);
    } catch (e) {
      throw const CacheException('Önbellek temizlenemedi.');
    }
  }
}
