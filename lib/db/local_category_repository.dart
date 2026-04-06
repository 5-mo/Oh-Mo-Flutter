import 'package:drift/drift.dart' as drift;
import 'package:ohmo/models/category_item.dart';
import 'package:ohmo/db/drift_database.dart' as db;

class LocalCategoryRepository {
  final db.LocalDatabase _db;

  LocalCategoryRepository(this._db);

  // ------------------ Category ------------------
  Future<List<CategoryItem>> fetchCategories({
    required String scheduleType,
  }) async {
    final rows = await _db.getAllCategories(scheduleType);
    return rows
        .map(
          (r) => CategoryItem(
            id: r.id,
            serverId: r.categoryId,
            categoryName: r.name,
            colorType: r.color,
            scheduleType: r.type,
            isSynced: r.isSynced,
          ),
        )
        .toList();
  }

  Future<void> updateCategoryServerId(int localId, int serverId) async {
    await _db.updateCategoryServerId(localId, serverId);
  }

  Future<CategoryItem> insertCategory({
    required String name,
    required String type,
    required String color,
    int? serverCategoryId,
    bool isSynced = false,
  }) async {
    final id = await _db.insertCategory(
      name: name,
      type: type,
      color: color,
      serverCategoryId: serverCategoryId,
      isSynced: isSynced,
    );
    return CategoryItem(
      id: id,
      serverId: serverCategoryId,
      categoryName: name,
      colorType: color,
      scheduleType: type,
      isSynced: isSynced,
    );
  }

  Future<void> updateCategoryName(int id, String newName) async {
    await _db.updateCategoryName(id, newName);
  }

  Future<void> deleteCategory(int categoryId) async {
    await _db.updateChildrenOnCategoryDelete(categoryId);

    await _db.deleteCategoryById(categoryId);
  }

  Future<void> softDeleteCategory(int id) async {
    await _db.softDeleteCategory(id);
  }

  Future<void> updateCategoryColor(int id, String newColor) async {
    await (_db.update(_db.categories)..where(
      (t) => t.id.equals(id),
    )).write(db.CategoriesCompanion(color: drift.Value(newColor)));
  }

  // ------------------ DayLog ------------------
  Future<List<DayLogQuestionItem>> fetchDayLogQuestions() async {
    final rows = await _db.getAllDayLogQuestions();
    return rows
        .map(
          (r) => DayLogQuestionItem(
        id: r.id,
        question: r.question,
        emoji: r.emoji,
        serverId: r.serverId,
      ),
    )
        .toList();
  }

  Future<DayLogQuestionItem> insertDayLogQuestion(String question, String emoji, {int? serverId}) async {
    final id = await _db.into(_db.dayLogQuestions).insert(
      db.DayLogQuestionsCompanion(
        question: drift.Value(question),
        emoji: drift.Value(emoji),
        serverId: drift.Value(serverId),
      ),
    );

    return DayLogQuestionItem(
        id: id,
        question: question,
        emoji: emoji,
        serverId: serverId
    );
  }

  Future<void> updateDayLogQuestion(
      int id,
      String question,
      String emoji, {
        int? serverId,
      }) async {
    await (_db.update(_db.dayLogQuestions)..where((t) => t.id.equals(id)))
        .write(db.DayLogQuestionsCompanion(
      question: drift.Value(question),
      emoji: drift.Value(emoji),
      serverId: serverId != null ? drift.Value(serverId) : const drift.Value.absent(), // ID가 있을 때만 업데이트
    ));
  }

  Future<void> deleteDayLogQuestion(int id) async {
    await _db.deleteDayLogQuestion(id);
  }
}
