import 'dart:convert';

import 'package:pickmeup_dashboard/features/home/data/repository/upload_file_repository.dart';
import 'package:dio/dio.dart' as dio;

import '../../../../core/config.dart';

class UploadFileProvider extends UploadFileRepository {
  @override
  Future<String> uploadFile(image) async {
    try {
      Uri uploadURl = Uri.parse('$URL_PICKME_API/cloudinary/upload');
      var responseUp = await dio.Dio().post(
        uploadURl.toString(),
        data: dio.FormData.fromMap(
          {
            'file': dio.MultipartFile.fromBytes(
              image,
              filename: 'plato${DateTime.now().toIso8601String()}',
            ),
          },
        ),
        options: dio.Options(
          headers: {
            'Content-Type':
                'multipart/form-data', // Especifica el tipo de contenido
          },
        ),
      );

      var respoJson = jsonDecode(responseUp.toString());

      return respoJson['body'].toString();
    } catch (e) {
      rethrow;
    }
  }
}
