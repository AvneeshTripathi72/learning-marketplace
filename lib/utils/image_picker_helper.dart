import 'image_picker_stub.dart'
    if (dart.library.html) 'image_picker_web.dart';

void pickProfileImageFromDevice(Function(String imageUrl) onImagePicked) {
  pickImageFromDeviceImpl(onImagePicked);
}
