import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/shared/domain/media_image.dart';

void main() {
  group('MediaImage.fromJson', () {
    test('parses an /images backdrop row', () {
      final image = MediaImage.fromJson(const <String, dynamic>{
        'file_path': '/backdrop.jpg',
        'aspect_ratio': 1.778,
        'width': 3840,
        'height': 2160,
      });

      expect(image.filePath, '/backdrop.jpg');
      expect(image.aspectRatio, 1.778);
      expect(image.width, 3840);
      expect(image.height, 2160);
    });

    test('defaults missing fields gracefully', () {
      final image = MediaImage.fromJson(const <String, dynamic>{});

      expect(image.filePath, '');
      expect(image.aspectRatio, closeTo(16 / 9, 0.0001));
      expect(image.width, 0);
      expect(image.height, 0);
    });
  });

  group('MediaImage.url', () {
    test('builds a backdrop url at the requested size', () {
      final image = MediaImage.fromJson(const <String, dynamic>{
        'file_path': '/backdrop.jpg',
      });

      expect(image.url(size: 'w1280'), endsWith('/w1280/backdrop.jpg'));
      expect(image.url(), contains('/w780/backdrop.jpg'));
    });

    test('is empty when there is no file path', () {
      expect(MediaImage.fromJson(const <String, dynamic>{}).url(), '');
    });
  });
}
