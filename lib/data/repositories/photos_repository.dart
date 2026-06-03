import 'package:image_picker/image_picker.dart';
import '../datasources/supabase/photos_datasource.dart';
import '../models/establishment_photo_model.dart';

class PhotosRepository {
  final PhotosDatasource _datasource;

  PhotosRepository({PhotosDatasource? datasource})
      : _datasource = datasource ?? PhotosDatasource();

  Future<List<EstablishmentPhotoModel>> getPhotos(String establishmentId) =>
      _datasource.getPhotos(establishmentId);

  Future<String> uploadLogo(String establishmentId, XFile file) =>
      _datasource.uploadLogo(establishmentId, file);

  Future<EstablishmentPhotoModel> uploadPhoto(
    String establishmentId,
    String category,
    XFile  file,
  ) =>
      _datasource.uploadPhoto(establishmentId, category, file);

  Future<void> deletePhoto(EstablishmentPhotoModel photo) =>
      _datasource.deletePhoto(photo);
}
