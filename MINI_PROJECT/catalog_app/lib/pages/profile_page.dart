import 'dart:io';

import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  User? _authUser;
  bool _isUploading = false;
  bool _isSaving = false;
  bool _isLoadingProfile = true;

  String? _email;
  String? _plan;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _authUser = FirebaseAuth.instance.currentUser;
    _loadUserInfo();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final user = _authUser;
    if (user == null) {
      setState(() => _isLoadingProfile = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final userModel = UserModel.fromFirestore(doc);
        LoadUserDataMutation(userModel);

        setState(() {
          _firstNameController.text = userModel.firstName ?? '';
          _lastNameController.text = userModel.lastName ?? '';
          _usernameController.text = userModel.username ?? '';
          _email = userModel.email ?? user.email;
          _plan = userModel.plan;
          _photoUrl = userModel.photoURL ?? user.photoURL;
        });
      } else {
        setState(() {
          _email = user.email;
          _plan = 'Free';
          _photoUrl = user.photoURL;
        });
      }
    } catch (_) {
      _showSnack(
        'Failed to load profile details. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveChanges() async {
    final user = _authUser;
    if (user == null) {
      _showSnack('You are not signed in.', isError: true);
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();

    // All fields are optional - no validation errors
    final composedName = [
      if (firstName.isNotEmpty) firstName,
      if (lastName.isNotEmpty) lastName,
    ].join(' ');
    final fallbackEmailName =
        (_email ?? user.email)?.split('@').first ?? 'User';
    final displayName = (composedName.isNotEmpty
            ? composedName
            : (username.isNotEmpty ? username : null)) ??
        fallbackEmailName;

    final updates = <String, dynamic>{
      'firstName': firstName.isEmpty ? FieldValue.delete() : firstName,
      'lastName': lastName.isEmpty ? FieldValue.delete() : lastName,
      'username': username.isEmpty ? FieldValue.delete() : username,
      'displayName': displayName,
      'email': _email ?? user.email,
      if (_photoUrl != null) 'photoURL': _photoUrl,
      if (_plan != null) 'plan': _plan,
      'premium': _plan?.toLowerCase() == 'premium' ||
          _plan?.toLowerCase() == 'vip',
    };

    // Remove null or empty values
    updates.removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updates, SetOptions(merge: true));
      await user.updateDisplayName(displayName);
      await user.reload();

      final refreshedDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (refreshedDoc.exists) {
        LoadUserDataMutation(UserModel.fromFirestore(refreshedDoc));
      }

      _showSnack('Profile updated successfully.');
    } catch (e) {
      _showSnack('Failed to save changes: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final user = _authUser;
    if (user == null) {
      _showSnack('You are not signed in.', isError: true);
      return;
    }
    if (_isUploading) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('${user.uid}.jpg');

      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      await user.updatePhotoURL(url);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'photoURL': url}, SetOptions(merge: true));

      final refreshedDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (refreshedDoc.exists) {
        final updatedModel = UserModel.fromFirestore(refreshedDoc);
        LoadUserDataMutation(updatedModel);
        setState(() => _photoUrl = updatedModel.photoURL ?? url);
      } else {
        setState(() => _photoUrl = url);
      }

      _showSnack('Profile picture updated.');
    } catch (e) {
      _showSnack('Error uploading image: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    if (!mounted) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickAndUploadImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final photoURL = _photoUrl ?? _authUser?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        backgroundImage:
                            photoURL != null ? NetworkImage(photoURL) : null,
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : (photoURL == null
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  )
                                : null),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: _isUploading ? null : _showImageSourceDialog,
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.camera_alt,
                                color: theme.colorScheme.onPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // User Info Display Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.email_outlined,
                              color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: theme.textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email ?? 'No email',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.workspace_premium_outlined,
                              color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plan',
                                  style: theme.textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _plan ?? 'Free',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _plan?.toLowerCase() == 'premium'
                                        ? Colors.deepPurple
                                        : _plan?.toLowerCase() == 'vip'
                                            ? Colors.amber.shade800
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Editable Fields Section
                Text(
                  'Edit Profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // First Name Field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant.withAlpha(76),
                  ),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  // Optional field - no validation
                ),
                const SizedBox(height: 16),

                // Last Name Field
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant.withAlpha(76),
                  ),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  // Optional field - no validation
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username (optional)',
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant.withAlpha(76),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  // Optional field - no validation
                ),
                const SizedBox(height: 32),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveChanges,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
