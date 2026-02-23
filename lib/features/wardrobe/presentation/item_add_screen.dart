import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/image_utils.dart';
import '../../subscription/presentation/widgets/limit_reached_sheet.dart';
import '../providers/item_registration_provider.dart';
import '../providers/wardrobe_provider.dart';

/// S08: Add item (camera/gallery → image processing → register screen)
class ItemAddScreen extends ConsumerWidget {
  const ItemAddScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이템 추가')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 24),
              const Text(
                '옷을 촬영해주세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '배경이 깔끔할수록\n더 정확하게 인식해요',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(context, ref, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('카메라로 촬영'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _pickImage(context, ref, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('갤러리에서 선택'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    // Check free tier limit (premium users skip this)
    final canAdd = await ref.read(canAddItemProvider.future);
    if (!canAdd) {
      if (context.mounted) {
        LimitReachedSheet.show(context, LimitType.wardrobe);
      }
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
    );

    if (picked == null) return;

    final rawBytes = await picked.readAsBytes();

    // Process image (resize + strip EXIF)
    final processed = ImageUtils.processImage(rawBytes);
    if (processed == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지를 처리할 수 없습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Store processed image in provider
    ref.read(pendingImageProvider.notifier).state = processed;

    // Navigate to register screen
    if (context.mounted) {
      context.push(AppRoutes.wardrobeRegister);
    }
  }
}
