const fs = require('fs');
let content = fs.readFileSync('lib/features/profile/edit_profile_screen.dart', 'utf8');

const targetStr =                     Center(
                      child: Container(
                        width: 90,
                        height: 90,
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
                            'https://api.dicebear.com/7.x/adventurer/svg?seed=Lucky',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),;

const replaceStr =                     Center(
                      child: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getAvatarColor(_nameController.text.trim().isEmpty ? 'User' : _nameController.text),
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
                              child: _selectedAvatar != null && _selectedAvatar!.isNotEmpty
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
                                  ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),;

content = content.replace(targetStr, replaceStr);

// Add state variables and helper functions
const varStr = class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;;

const newVarStr = \class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedAvatar;
  
  static String _getInitials(String name) {
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

  void _showAvatarPicker() {
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
  }\;

content = content.replace(varStr, newVarStr);

// Init state avatar
const initStateStr =   @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  };

const newInitStateStr =   @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedAvatar = (user?.avatar != null && user!.avatar!.isNotEmpty && !user.avatar!.contains('dicebear'))
        ? user.avatar
        : null;
    
    // Add listener to update avatar initials when name changes
    _nameController.addListener(() {
      if (_selectedAvatar == null) {
        setState(() {}); // Re-render the initials
      }
    });
  };
content = content.replace(initStateStr, newInitStateStr);


// Save profile
const saveProfileStr =   Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );;

const newSaveProfileStr =   Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatar: _selectedAvatar,
    );;

content = content.replace(saveProfileStr, newSaveProfileStr);

fs.writeFileSync('lib/features/profile/edit_profile_screen.dart', content);
