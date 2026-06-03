import '../../../main.dart';
import '../../models/category_model.dart';
import '../../models/characteristic_model.dart';

class CategoriesDatasource {
  Future<List<CategoryModel>> getCategories() async {
    final response = await supabase
        .from('categories')
        .select()
        .order('name');
    return (response as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CharacteristicModel>> getCharacteristics() async {
    final response = await supabase
        .from('characteristics')
        .select()
        .order('name');
    return (response as List)
        .map((e) => CharacteristicModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final response = await supabase
        .from('categories')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return CategoryModel.fromJson(response);
  }

  Future<List<CharacteristicModel>> getCharacteristicsByEstablishment(
      String establishmentId) async {
    final junctionRows = await supabase
        .from('establishment_characteristics')
        .select('characteristic_id')
        .eq('establishment_id', establishmentId);

    final ids = (junctionRows as List)
        .map((e) => e['characteristic_id'])
        .where((id) => id != null)
        .toList();

    if (ids.isEmpty) return [];

    final chars = await supabase
        .from('characteristics')
        .select()
        .inFilter('id', ids);

    return (chars as List)
        .map((e) => CharacteristicModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── CRUD Categorías ───────────────────────────────────────────────────────

  /// Convierte un nombre en slug URL-friendly: "Pádel Norte" → "padel-norte"
  String _toSlug(String text) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñçÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÑÇ';
    const to   = 'aaaaaeeeeiiiioooouuuuncAAAAEEEEIIIIOOOOUUUUNC';
    var s = text.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i].toLowerCase());
    }
    s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    s = s.trim().replaceAll(RegExp(r'\s+'), '-');
    return s.isEmpty ? 'categoria' : s;
  }

  Future<CategoryModel> createCategory({
    required String name,
    String? icon,
    String? parentId,
  }) async {
    final row = await supabase
        .from('categories')
        .insert({
          'name': name,
          'slug': _toSlug(name),
          if (icon != null) 'icon': icon,
          if (parentId != null) 'parent_id': int.parse(parentId),
        })
        .select()
        .single();
    return CategoryModel.fromJson(row);
  }

  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    String? icon,
    String? parentId,          // null = sin padre (tipo raíz)
    bool    clearParent = false,
  }) async {
    final update = <String, dynamic>{
      'name': name,
      'slug': _toSlug(name),
      if (icon != null) 'icon': icon,
    };
    // Solo tocar parent_id si el usuario cambió o eliminó explícitamente el padre
    if (clearParent) {
      update['parent_id'] = null;
    } else if (parentId != null) {
      update['parent_id'] = int.parse(parentId);
    }
    final row = await supabase
        .from('categories')
        .update(update)
        .eq('id', int.parse(id))
        .select()
        .single();
    return CategoryModel.fromJson(row);
  }

  Future<void> deleteCategory(String id) async {
    await supabase.from('categories').delete().eq('id', int.parse(id));
  }

  // ── CRUD Características ──────────────────────────────────────────────────

  Future<CharacteristicModel> createCharacteristic({
    required String name,
    String? icon,
  }) async {
    final row = await supabase
        .from('characteristics')
        .insert({'name': name, 'icon': icon})
        .select()
        .single();
    return CharacteristicModel.fromJson(row);
  }

  Future<CharacteristicModel> updateCharacteristic({
    required String id,
    required String name,
    String? icon,
  }) async {
    final row = await supabase
        .from('characteristics')
        .update({'name': name, 'icon': icon})
        .eq('id', int.parse(id))
        .select()
        .single();
    return CharacteristicModel.fromJson(row);
  }

  Future<void> deleteCharacteristic(String id) async {
    await supabase.from('characteristics').delete().eq('id', int.parse(id));
  }
}
