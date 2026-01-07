import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  final authService = AuthService();
  final user = Supabase.instance.client.auth.currentUser!;

  String userName = "Student";
  String? avatarUrl;
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', user.id)
          .maybeSingle(); 

      if (mounted) {
        setState(() {
          userName = response?['full_name'] ?? "Student";
          avatarUrl = response?['avatar_url'] as String?;
          isLoading = false;
        });
      }
    } catch (e) {
      final fallback = await authService.getUserName();
      if (mounted) {
        setState(() {
          userName = fallback ?? "Student";
          avatarUrl = null;
          isLoading = false;
        });
      }
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image == null) return;

    setState(() => isUploading = true);

    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final filePath = '${user.id}.$fileExt';  

      await supabase.storage.from('avatars').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: 'image/$fileExt'),
      );

      final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      
      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': userName,
        'avatar_url': publicUrl,
      });

      if (mounted) {
        setState(() => avatarUrl = publicUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: pickAndUploadImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.white,
                              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                              child: avatarUrl == null
                                  ? const Icon(Icons.person, size: 100, color: Colors.blueGrey)
                                  : null,
                            ),
                            if (isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black45,
                                  ),
                                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                                ),
                              ),
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.camera_alt, size: 20, color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Tap photo to change", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 32),
                      Text(userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(user.email ?? "", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 40),
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 16),
                      const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      ListTile(leading: Icon(Icons.notifications, color: Colors.white70), title: Text("Notifications", style: TextStyle(color: Colors.white)), trailing: Icon(Icons.chevron_right, color: Colors.white70), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon")))),
                      ListTile(leading: Icon(Icons.dark_mode, color: Colors.white70), title: Text("Appearance", style: TextStyle(color: Colors.white)), trailing: Icon(Icons.chevron_right, color: Colors.white70), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon")))),
                      ListTile(leading: Icon(Icons.help_outline, color: Colors.white70), title: Text("Help & Support", style: TextStyle(color: Colors.white)), trailing: Icon(Icons.chevron_right, color: Colors.white70), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon")))),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}