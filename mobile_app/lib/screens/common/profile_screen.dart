import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../models/user_role.dart';
import '../../navigation/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/media_location_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ne_pattern_strip.dart';

/// Displays the registered profile and allows editing.
/// User ID is never editable. Changes are saved locally.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  bool _locating = false;
  bool _pickingPhoto = false;
  String? _photoPath;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _accessibilityController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _linkedIdsController = TextEditingController();
  String? _gender;
  bool _voiceAssistancePreferred = false;

  static const _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _accessibilityController.dispose();
    _relationshipController.dispose();
    _linkedIdsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await AuthService.instance.loadCurrentProfile();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
      if (p != null) _fillControllers(p);
    });
  }

  void _fillControllers(UserProfile p) {
    _nameController.text = p.name;
    _phoneController.text = p.phone ?? '';
    _emailController.text = p.email ?? '';
    _dobController.text = p.dateOfBirth ?? '';
    _addressController.text = p.address ?? '';
    _emergencyNameController.text = p.emergencyContactName ?? '';
    _emergencyPhoneController.text = p.emergencyContactPhone ?? '';
    _accessibilityController.text = p.accessibilityPreferences ?? '';
    _relationshipController.text = p.relationshipWithElderly ?? '';
    _linkedIdsController.text = (p.linkedElderlyIds ?? []).join(', ');
    _gender = p.gender;
    _voiceAssistancePreferred = p.voiceAssistancePreferred ?? false;
    _photoPath = p.profilePhotoPath;
  }

  Future<void> _pickPhoto({required bool fromCamera}) async {
    final t = context.read<AppState>().localizations.t;
    setState(() => _pickingPhoto = true);
    final path = await MediaLocationService.instance
        .pickProfilePhoto(fromCamera: fromCamera);
    if (!mounted) return;
    setState(() {
      _pickingPhoto = false;
      if (path != null) _photoPath = path;
    });
    if (path == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('profile_photoCancelled'))));
    }
  }

  void _showPhotoOptions() {
    final t = context.read<AppState>().localizations.t;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(t('profile_photoCamera')),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(t('profile_photoGallery')),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(fromCamera: false);
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(t('profile_photoRemove')),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    final t = context.read<AppState>().localizations.t;
    setState(() => _locating = true);
    final addr = await MediaLocationService.instance.getCurrentLocationAddress();
    if (!mounted) return;
    setState(() => _locating = false);
    if (addr == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('register_locationFailed'))));
      return;
    }
    _addressController.text = addr;
    setState(() {});
  }

  Future<void> _save() async {
    final t = context.read<AppState>().localizations.t;
    final current = _profile;
    if (current == null) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('auth_required'))));
      return;
    }
    if (_phoneController.text.trim().isNotEmpty &&
        !Validators.isValidPhone(_phoneController.text)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('auth_invalidPhone'))));
      return;
    }
    if (_emailController.text.trim().isNotEmpty &&
        !Validators.isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('auth_invalidEmail'))));
      return;
    }

    setState(() => _saving = true);
    final linkedRaw = _linkedIdsController.text.trim();
    final linked = linkedRaw.isEmpty
        ? null
        : linkedRaw.split(RegExp(r'[,;\s]+')).where((s) => s.isNotEmpty).toList();

    final updated = current.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _gender,
      address: _addressController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      accessibilityPreferences: _accessibilityController.text.trim(),
      voiceAssistancePreferred: _voiceAssistancePreferred,
      relationshipWithElderly: _relationshipController.text.trim(),
      linkedElderlyIds: linked,
      profilePhotoPath: _photoPath,
    );
    await AuthService.instance.updateProfile(updated);
    if (!mounted) return;
    setState(() {
      _profile = updated;
      _saving = false;
      _editing = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t('profile_saved'))));
  }

  void _cancelEdit() {
    if (_profile != null) _fillControllers(_profile!);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().localizations.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_title')),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(14),
          child: NePatternStrip(),
        ),
        actions: [
          if (!_loading && _profile != null && !_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
              tooltip: t('profile_edit'),
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _profile == null
                ? Center(child: Text(t('profile_empty')))
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      _buildHeader(t),
                      const SizedBox(height: AppSpacing.lg),
                      if (_editing) _buildEditForm(t) else _buildView(t),
                      if (_editing) ...[
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: t('profile_save'),
                          loading: _saving,
                          onPressed: _save,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: t('common_cancel'),
                          onPressed: _cancelEdit,
                          variant: AppButtonVariant.outline,
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader(String Function(String) t) {
    final p = _profile!;
    final photo = _editing ? _photoPath : p.profilePhotoPath;
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage:
                photo != null && File(photo).existsSync() ? FileImage(File(photo)) : null,
            child: photo == null || !File(photo).existsSync()
                ? Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('${t('profile_userId')}: ${p.id}',
                    style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  p.role == UserRole.elderly
                      ? t('role_elderly')
                      : t('role_caregiver'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : '—')),
        ],
      ),
    );
  }

  Widget _buildView(String Function(String) t) {
    final p = _profile!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(t('register_phone'), p.phone),
          _row(t('register_gmail'), p.email),
          _row(t('register_dob'), p.dateOfBirth),
          _row(t('register_gender'), p.gender),
          _row(t('register_address'), p.address),
          _row(t('register_emergencyName'), p.emergencyContactName),
          _row(t('register_emergencyPhone'), p.emergencyContactPhone),
          _row(t('profile_language'), p.preferredLanguage),
          if (p.role == UserRole.elderly) ...[
            _row(t('register_accessibility'), p.accessibilityPreferences),
            _row(
              t('register_voiceAssistance'),
              p.voiceAssistancePreferred == true
                  ? t('common_yes')
                  : (p.voiceAssistancePreferred == false ? t('common_no') : null),
            ),
          ],
          if (p.role == UserRole.caregiver) ...[
            _row(t('register_relationship'), p.relationshipWithElderly),
            _row(t('register_linkedIds'), (p.linkedElderlyIds ?? []).join(', ')),
          ],
        ],
      ),
    );
  }

  Widget _buildEditForm(String Function(String) t) {
    final isElderly = _profile!.role == UserRole.elderly;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t('register_photoOptional'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: _photoPath != null && File(_photoPath!).existsSync()
                    ? FileImage(File(_photoPath!))
                    : null,
                child: _photoPath == null || !File(_photoPath!).existsSync()
                    ? const Icon(Icons.person, size: 36)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: t('profile_addPhoto'),
                  loading: _pickingPhoto,
                  onPressed: _pickingPhoto ? null : _showPhotoOptions,
                  variant: AppButtonVariant.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_name'), style: Theme.of(context).textTheme.titleMedium),
          TextField(controller: _nameController),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_phone'), style: Theme.of(context).textTheme.titleMedium),
          TextField(controller: _phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_gmail'), style: Theme.of(context).textTheme.titleMedium),
          TextField(
              controller: _emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_dob'), style: Theme.of(context).textTheme.titleMedium),
          TextField(
            controller: _dobController,
            readOnly: true,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.tryParse(_dobController.text) ?? DateTime(now.year - 60),
                firstDate: DateTime(1920),
                lastDate: now,
              );
              if (picked != null) {
                _dobController.text =
                    '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                setState(() {});
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_gender'), style: Theme.of(context).textTheme.titleMedium),
          DropdownButtonFormField<String>(
            value: _genders.contains(_gender) ? _gender : null,
            items:
                _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_address'), style: Theme.of(context).textTheme.titleMedium),
          TextField(controller: _addressController, maxLines: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _locating ? null : _useCurrentLocation,
              icon: _locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(t('register_useCurrentLocation')),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_emergencyName'),
              style: Theme.of(context).textTheme.titleMedium),
          TextField(controller: _emergencyNameController),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_emergencyPhone'),
              style: Theme.of(context).textTheme.titleMedium),
          TextField(
              controller: _emergencyPhoneController,
              keyboardType: TextInputType.phone),
          if (isElderly) ...[
            const SizedBox(height: AppSpacing.md),
            Text(t('register_accessibility'),
                style: Theme.of(context).textTheme.titleMedium),
            TextField(controller: _accessibilityController, maxLines: 2),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t('register_voiceAssistance')),
              value: _voiceAssistancePreferred,
              onChanged: (v) => setState(() => _voiceAssistancePreferred = v),
            ),
          ],
          if (!isElderly) ...[
            const SizedBox(height: AppSpacing.md),
            Text(t('register_relationship'),
                style: Theme.of(context).textTheme.titleMedium),
            TextField(controller: _relationshipController),
            const SizedBox(height: AppSpacing.md),
            Text(t('register_linkedIds'),
                style: Theme.of(context).textTheme.titleMedium),
            TextField(controller: _linkedIdsController),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text('${t('profile_userId')}: ${_profile!.id} (${t('profile_idLocked')})',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
