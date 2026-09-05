import 'dart:html' as html;

void pickImageFromDeviceImpl(Function(String imageUrl) onImagePicked) {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();

      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        final result = reader.result as String?;
        if (result != null && result.isNotEmpty) {
          onImagePicked(result);
        }
      });
    }
  });
}
