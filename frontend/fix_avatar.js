const fs = require('fs');
let content = fs.readFileSync('lib/features/profile/profile_screen.dart', 'utf8');

const targetStr =               Container(
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
              ),;

const replaceStr =               Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getAvatarColor(user.name),
                  border: Border.all(color: const Color(0xFFE8F5E9), width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F2E5C45),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: (user.avatar != null && user.avatar!.isNotEmpty && !user.avatar!.contains('dicebear'))
                  ? ClipOval(
                      child: Image.network(
                        user.avatar!,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    )
                  : Text(
                      _getInitials(user.name),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),;

content = content.replace(targetStr, replaceStr);

const helperMethods =   static String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '\\'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  static Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFE50914), // Netflix Red
      const Color(0xFF0071EB), // Blue
      const Color(0xFFF4B400), // Yellow
      const Color(0xFF0F9D58), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Deep Orange
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  static Widget _buildProfileHeader;

content = content.replace('  static Widget _buildProfileHeader', helperMethods);

fs.writeFileSync('lib/features/profile/profile_screen.dart', content);
