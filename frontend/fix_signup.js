const fs = require('fs');
let content = fs.readFileSync('lib/features/authentication/signup_screen.dart', 'utf8');

// 1. Fix password < 6 to < 8
content = content.replace(
  "if (value.length < 6) {\n                            return 'Password must be at least 6 characters';",
  "if (value.length < 8) {\n                            return 'Password must be at least 8 characters';"
);

// 2. Add Confirm Password Field right after Password Field
const searchStr = "const SizedBox(height: 24);\n                      \n                      CustomButton";
const insertStr = const SizedBox(height: 16);
                      
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF23312B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF647C72),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5EDE7)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5EDE7)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF647C72)),
                          fillColor: const Color(0xFFFAFBF9),
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24);
                      
                      CustomButton;

content = content.replace(searchStr, insertStr);
fs.writeFileSync('lib/features/authentication/signup_screen.dart', content);
