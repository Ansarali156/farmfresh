const fs = require('fs');
let content = fs.readFileSync('lib/features/profile/edit_profile_screen.dart', 'utf8');

const targetStr =   void _showAvatarPicker() {
    final List<String> presetAvatars = [
      'https://api.dicebear.com/7.x/avataaars/png?seed=Felix&backgroundColor=b6e3f4',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka&backgroundColor=c0aede',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Jack&backgroundColor=ffdfbf',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Oliver&backgroundColor=d1d4f9',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Mia&backgroundColor=ffd5dc',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Leo&backgroundColor=b6e3f4',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Lucy&backgroundColor=c0aede',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Bella&backgroundColor=ffdfbf',
      '' // Option for initials
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose an Avatar',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF23312B),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: presetAvatars.length,
                itemBuilder: (context, index) {
                  final avatarUrl = presetAvatars[index];
                  final isInitials = avatarUrl.isEmpty;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatar = isInitials ? null : avatarUrl;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isInitials ? _getAvatarColor(_nameController.text.trim().isEmpty ? 'U' : _nameController.text) : null,
                        border: Border.all(
                          color: _selectedAvatar == (isInitials ? null : avatarUrl)
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE5EDE7),
                          width: _selectedAvatar == (isInitials ? null : avatarUrl) ? 3 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isInitials
                          ? Text(
                              _getInitials(_nameController.text.trim().isEmpty ? 'U' : _nameController.text),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : ClipOval(
                              child: Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  };

const replaceStr = \  void _showAvatarPicker() {
    final List<String> presetAvatars = [
      '', // Initials
      'https://api.dicebear.com/7.x/notionists/png?seed=Felix&backgroundColor=b6e3f4', // Profile 1
      'https://api.dicebear.com/7.x/notionists/png?seed=Aneka&backgroundColor=c0aede', // Profile 2
      'emoji:??', // Vegetable 1
      'emoji:??', // Vegetable 2
      'emoji:??', // Vegetable 3
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose an Avatar',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF23312B),
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: presetAvatars.length,
                  itemBuilder: (context, index) {
                    final avatarUrl = presetAvatars[index];
                    final isInitials = avatarUrl.isEmpty;
                    final isEmoji = avatarUrl.startsWith('emoji:');
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = isInitials ? null : avatarUrl;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isInitials || isEmoji ? _getAvatarColor(_nameController.text.trim().isEmpty ? 'U' : _nameController.text).withOpacity(isEmoji ? 0.2 : 1.0) : null,
                          border: Border.all(
                            color: _selectedAvatar == (isInitials ? null : avatarUrl)
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE5EDE7),
                            width: _selectedAvatar == (isInitials ? null : avatarUrl) ? 3 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isInitials
                            ? Text(
                                _getInitials(_nameController.text.trim().isEmpty ? 'U' : _nameController.text),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : isEmoji
                                ? Text(
                                    avatarUrl.substring(6),
                                    style: const TextStyle(fontSize: 32),
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }\;

content = content.replace(targetStr, replaceStr);

// Now let's fix the same logic in the main avatar display in edit_profile_screen
const editAvatarDisplayTarget = \                              child: _selectedAvatar != null && _selectedAvatar!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _selectedAvatar!,
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    ),
                                  )
                                : Text(
                                    _getInitials(_nameController.text.trim().isEmpty ? 'U' : _nameController.text),
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),\;

const editAvatarDisplayReplace = \                              child: _selectedAvatar != null && _selectedAvatar!.isNotEmpty
                                ? (_selectedAvatar!.startsWith('emoji:')
                                    ? Text(
                                        _selectedAvatar!.substring(6),
                                        style: const TextStyle(fontSize: 40),
                                      )
                                    : ClipOval(
                                        child: Image.network(
                                          _selectedAvatar!,
                                          fit: BoxFit.cover,
                                          width: 90,
                                          height: 90,
                                        ),
                                      ))
                                : Text(
                                    _getInitials(_nameController.text.trim().isEmpty ? 'U' : _nameController.text),
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),\;

content = content.replace(editAvatarDisplayTarget, editAvatarDisplayReplace);

fs.writeFileSync('lib/features/profile/edit_profile_screen.dart', content);
