import 'dart:math';

void pickImageFromDeviceImpl(Function(String imageUrl) onImagePicked) {
  final sampleAvatars = [
    'https://ui-avatars.com/api/?name=Hariom+Student&background=0000D1&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Academic+Pro&background=FF2D55&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Scholar+Star&background=00A86B&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Master+Mind&background=7C4DFF&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Top+Ranker&background=FF9100&color=fff&size=200&bold=true',
  ];
  final randomIndex = Random().nextInt(sampleAvatars.length);
  onImagePicked(sampleAvatars[randomIndex]);
}
