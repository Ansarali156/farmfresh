import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_image_picker_stub.dart'
    if (dart.library.html) 'profile_image_picker_web.dart';

class ProfileImagePickerDialog extends StatefulWidget {
  final String userId;
  final Function(String base64Image, double scale, double dx, double dy) onImageSelected;

  const ProfileImagePickerDialog({
    super.key,
    required this.userId,
    required this.onImageSelected,
  });

  static void show(
    BuildContext context, {
    required String userId,
    required Function(String base64Image, double scale, double dx, double dy) onImageSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProfileImagePickerDialog(
        userId: userId,
        onImageSelected: onImageSelected,
      ),
    );
  }

  @override
  State<ProfileImagePickerDialog> createState() => _ProfileImagePickerDialogState();
}

class _ProfileImagePickerDialogState extends State<ProfileImagePickerDialog> {
  void _pickImage() {
    ProfileImagePickerService.pickImage(context, (base64Image) {
      Navigator.pop(context); // Close sheet
      _showAdjustmentDialog(base64Image);
    });
  }

  void _openCamera() {
    Navigator.pop(context); // Close sheet
    ProfileImagePickerService.openCamera(context, (base64Image) {
      _showAdjustmentDialog(base64Image);
    });
  }

  void _showAdjustmentDialog(String base64Image) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImageAdjustmentDialog(
        base64Image: base64Image,
        onSave: (scale, dx, dy) {
          widget.onImageSelected(base64Image, scale, dx, dy);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Profile Picture',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF23312B),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: _pickImage,
              ),
              _buildOptionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: _openCamera,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5EDE7), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF23312B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageAdjustmentDialog extends StatefulWidget {
  final String base64Image;
  final Function(double scale, double dx, double dy) onSave;

  const ImageAdjustmentDialog({
    super.key,
    required this.base64Image,
    required this.onSave,
  });

  @override
  State<ImageAdjustmentDialog> createState() => _ImageAdjustmentDialogState();
}

class _ImageAdjustmentDialogState extends State<ImageAdjustmentDialog> {
  double _scale = 1.0;
  double _dx = 0.0;
  double _dy = 0.0;

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(widget.base64Image.split(',')[1]);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adjust Photo',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF23312B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Drag to position, slider to zoom',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF647C72),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _dx += details.delta.dx;
                  _dy += details.delta.dy;
                });
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8F5E9), width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F2E5C45),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(_dx, _dy),
                          child: Transform.scale(
                            scale: _scale,
                            child: Image.memory(
                              imageBytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.zoom_out, color: Color(0xFF647C72), size: 16),
                Expanded(
                  child: Slider(
                    value: _scale,
                    min: 1.0,
                    max: 3.0,
                    activeColor: const Color(0xFF2E7D32),
                    inactiveColor: const Color(0xFFE5EDE7),
                    onChanged: (val) {
                      setState(() {
                        _scale = val;
                      });
                    },
                  ),
                ),
                const Icon(Icons.zoom_in, color: Color(0xFF647C72), size: 16),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF647C72),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(_scale, _dx, _dy);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
