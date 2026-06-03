import '../datasources/supabase/categories_datasource.dart';
import '../models/category_model.dart';
import '../models/characteristic_model.dart';

class CategoriesRepository {
  final CategoriesDatasource _datasource;

  CategoriesRepository({CategoriesDatasource? datasource})
      : _datasource = datasource ?? CategoriesDatasource();

  Future<List<CategoryModel>> getCategories() =>
      _datasource.getCategories();

  Future<List<CharacteristicModel>> getCharacteristics() =>
      _datasource.getCharacteristics();

  Future<CategoryModel?> getCategoryById(int id) =>
      _datasource.getCategoryById(id);

  Future<List<CharacteristicModel>> getCharacteristicsByEstablishment(
          String establishmentId) =>
      _datasource.getCharacteristicsByEstablishment(establishmentId);

  // ── CRUD Categorías ───────────────────────────────────────────────────────

  Future<CategoryModel> createCategory({
    required String name,
    String? icon,
    String? parentId,
  }) =>
      _datasource.createCategory(
          name: name, icon: icon, parentId: parentId);

  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    String? icon,
    String? parentId,
    bool    clearParent = false,
  }) =>
      _datasource.updateCategory(
          id: id, name: name, icon: icon,
          parentId: parentId, clearParent: clearParent);

  Future<void> deleteCategory(String id) => _datasource.deleteCategory(id);

  // ── CRUD Características ──────────────────────────────────────────────────

  Future<CharacteristicModel> createCharacteristic({
    required String name,
    String? icon,
  }) =>
      _datasource.createCharacteristic(name: name, icon: icon);

  Future<CharacteristicModel> updateCharacteristic({
    required String id,
    required String name,
    String? icon,
  }) =>
      _datasource.updateCharacteristic(id: id, name: name, icon: icon);

  Future<void> deleteCharacteristic(String id) =>
      _datasource.deleteCharacteristic(id);
}
