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
  }) async {
    final id = await _db.insertCategory(
      name: name,
      type: type,
      color: color,
      serverCategoryId: serverCategoryId,
    );
    return CategoryItem(
      id: id,
      serverId: serverCategoryId,
      categoryName: name,
      colorType: color,
      scheduleType: type,
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
          ),
        )
        .toList();
  }

  Future<DayLogQuestionItem> insertDayLogQuestion(
    String question,
    String emoji,
  ) async {
    final id = await _db.insertDayLogQuestion(question, emoji);
    return DayLogQuestionItem(id: id, question: question, emoji: emoji);
  }

  Future<void> updateDayLogQuestion(
    int id,
    String question,
    String emoji,
  ) async {
    await _db.updateDayLogQuestion(id, question, emoji);
  }

  Future<void> deleteDayLogQuestion(int id) async {
    await _db.deleteDayLogQuestion(id);
  }
}
