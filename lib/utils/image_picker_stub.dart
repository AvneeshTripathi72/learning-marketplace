import 'dart:math';

void pickImageFromDeviceImpl(Function(String imageUrl) onImagePicked) {
  final sampleAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
  ];
  final randomIndex = Random().nextInt(sampleAvatars.length);
  onImagePicked(sampleAvatars[randomIndex]);
}
