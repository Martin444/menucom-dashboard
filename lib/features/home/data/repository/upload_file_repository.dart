import 'dart:typed_data';

abstract class UploadFileRepository {
  Future<String> uploadFile(Uint8List image);
}
