const fs = require('fs');
let content = fs.readFileSync('lib/features/profile/profile_screen.dart', 'utf8');

// Replace the GestureDetector with simple Container
const startMarker = '              GestureDetector(';
const endMarker = '              const SizedBox(height: 12),';

const startIndex = content.indexOf(startMarker);
const endIndex = content.indexOf(endMarker, startIndex);

if (startIndex !== -1 && endIndex !== -1) {
  const replacement =               Container(
                width: 80,
                height: 80,
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
                  child: Image.network(
                    (user.avatar != null && user.avatar!.isNotEmpty && !user.avatar!.contains('dicebear'))
                        ? user.avatar!
                        : 'https://api.dicebear.com/7.x/adventurer/png?seed=\',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),;
  
  content = content.substring(0, startIndex) + replacement + content.substring(endIndex + endMarker.length);
}

// Remove unused imports
content = content.replace("import '../../providers/profile_image_provider.dart';\n", "");
content = content.replace("import '../../core/widgets/profile_image_picker_dialog.dart';\n", "");
content = content.replace("import 'dart:convert';\n", "");

// Remove _uploadProfilePicture method
const uploadMethodStart = '  static Future<void> _uploadProfilePicture(';
const uploadMethodStartIndex = content.indexOf(uploadMethodStart);
if (uploadMethodStartIndex !== -1) {
    const nextMethodOrEnd = content.indexOf('}\n}', uploadMethodStartIndex);
    if (nextMethodOrEnd !== -1) {
        content = content.substring(0, uploadMethodStartIndex) + content.substring(nextMethodOrEnd + 2);
    }
}

// Also remove inal profileImage = ref.watch(profileImageProvider(user.id));
content = content.replace("    final profileImage = ref.watch(profileImageProvider(user.id));\n\n", "");

fs.writeFileSync('lib/features/profile/profile_screen.dart', content);
