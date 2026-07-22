const fs = require('fs');
let content = fs.readFileSync('lib/features/profile/profile_screen.dart', 'utf8');

content = content.replace("import '../../providers/profile_image_provider.dart';\r\n", "");
content = content.replace("import '../../core/widgets/profile_image_picker_dialog.dart';\r\n", "");
content = content.replace("import 'dart:convert';\r\n", "");

// Replace unix newlines just in case
content = content.replace("import '../../providers/profile_image_provider.dart';\n", "");
content = content.replace("import '../../core/widgets/profile_image_picker_dialog.dart';\n", "");
content = content.replace("import 'dart:convert';\n", "");


const uploadMethodStart = '  static Future<void> _uploadProfilePicture(';
const uploadMethodStartIndex = content.indexOf(uploadMethodStart);
if (uploadMethodStartIndex !== -1) {
    const nextMethodOrEnd = content.indexOf('}\n}', uploadMethodStartIndex);
    if (nextMethodOrEnd !== -1) {
        content = content.substring(0, uploadMethodStartIndex) + content.substring(nextMethodOrEnd + 3);
    }
}

fs.writeFileSync('lib/features/profile/profile_screen.dart', content);
