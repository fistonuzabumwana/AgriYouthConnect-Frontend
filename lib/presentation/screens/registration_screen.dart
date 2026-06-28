import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyouthconnect/core/localization/app_localizations.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';
import 'package:agriyouthconnect/presentation/providers/profile_provider.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_button.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_text_field.dart';
import 'package:agriyouthconnect/presentation/widgets/advisory_dashboard_widget.dart';
import 'package:agriyouthconnect/presentation/widgets/financial_literacy_widget.dart';

/// RegistrationScreen allows youth farmers in Rwanda to register their farm profiles.
/// Includes cascading dropdowns, multi-select chips, and a real-time progress indicator.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _farmSizeController = TextEditingController();

  String? _selectedDistrict;
  String? _selectedSector;
  String? _selectedExperience;
  final List<String> _selectedCrops = [];

  bool _initialized = false;
  bool _isEditing = false;
  int _dashboardTabIndex = 0;

  // Cascading Location selector mapping
  final Map<String, List<String>> _locationMatrix = {
    'Gasabo': ['Kimironko', 'Kinyinya', 'Remera'],
    'Musanze': ['Kinigi', 'Muhoza', 'Shingiro'],
    'Rubavu': ['Gisenyi', 'Rubavu', 'Rugerero'],
    'Huye': ['Ngoma', 'Mukura', 'Tumba'],
  };

  @override
  void initState() {
    super.initState();
    // Add real-time text input listeners to redraw the progress bar instantly
    _nameController.addListener(_updateProgressState);
    _farmSizeController.addListener(_updateProgressState);
  }

  void _updateProgressState() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final profileProvider = Provider.of<ProfileProvider>(context);
      if (profileProvider.profile != null) {
        final profile = profileProvider.profile!;
        _nameController.text = profile.name;
        _farmSizeController.text = profile.farmSize.toString();
        
        // Restore cascaded locations safely
        if (_locationMatrix.containsKey(profile.district)) {
          _selectedDistrict = profile.district;
          if (_locationMatrix[profile.district]!.contains(profile.sector)) {
            _selectedSector = profile.sector;
          }
        }
        
        _selectedExperience = profile.experienceLevel;
        
        // Restore crop type selection (represented as a single crop or list)
        _selectedCrops.clear();
        if (profile.cropType.isNotEmpty) {
          _selectedCrops.addAll(profile.cropType.split(','));
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateProgressState);
    _farmSizeController.removeListener(_updateProgressState);
    _nameController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  /// Calculates form completion progress in 20% steps
  double _calculateCompletionProgress() {
    double progress = 0.0;
    if (_nameController.text.trim().isNotEmpty) progress += 0.2;
    if (_selectedDistrict != null) progress += 0.2;
    if (_selectedSector != null) progress += 0.2;
    if (_farmSizeController.text.trim().isNotEmpty && 
        double.tryParse(_farmSizeController.text) != null && 
        double.parse(_farmSizeController.text) > 0) {
      progress += 0.2;
    }
    if (_selectedCrops.isNotEmpty) progress += 0.2;
    return progress;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDistrict == null || _selectedSector == null) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    // Save profile using the provider
    final profile = UserProfileModel(
      name: _nameController.text.trim(),
      district: _selectedDistrict!,
      sector: _selectedSector!,
      cropType: _selectedCrops.join(','),
      farmSize: double.tryParse(_farmSizeController.text) ?? 0.0,
      experienceLevel: _selectedExperience ?? 'Beginner',
    );

    final success = await profileProvider.saveProfile(profile);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.successRegistered,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileProvider = Provider.of<ProfileProvider>(context);

    final progress = _calculateCompletionProgress();

    final cropOptions = [
      {'value': 'Maize', 'label': l10n.maize},
      {'value': 'Beans', 'label': l10n.beans},
      {'value': 'Coffee', 'label': l10n.coffee},
      {'value': 'Irish Potatoes', 'label': l10n.irishPotatoes},
    ];

    final experienceOptions = [
      {'value': 'Beginner', 'label': l10n.experienceBeginner},
      {'value': 'Intermediate', 'label': l10n.experienceIntermediate},
      {'value': 'Expert', 'label': l10n.experienceExpert},
    ];

    // Selected district sectors
    final sectorOptions = _selectedDistrict != null ? _locationMatrix[_selectedDistrict]! : [];

    // Expose dynamic dashboards for completed farm profiles
    final profile = profileProvider.profile;
    if (profile != null && !_isEditing) {
      final isEn = l10n.locale.languageCode == 'en';
      final activeCrops = profile.cropType.isNotEmpty ? profile.cropType : 'Maize';

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome header card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? Colors.white54 : Colors.black, width: 2.0),
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            profile.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text(
                            isEn ? 'EDIT PROFILE' : 'GUHINDURA',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📍 ${profile.district}, ${profile.sector} Sector',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🌾 Crops: $activeCrops • 📐 Size: ${profile.farmSize} Ha',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Segmented Tabs Header
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => setState(() => _dashboardTabIndex = 0),
                        style: TextButton.styleFrom(
                          backgroundColor: _dashboardTabIndex == 0 
                              ? theme.colorScheme.primary 
                              : Colors.transparent,
                          foregroundColor: _dashboardTabIndex == 0 
                              ? theme.colorScheme.onPrimary 
                              : (isDark ? Colors.white70 : Colors.black87),
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Text(
                          isEn ? 'AI ADVISORY' : 'INAMA ZA AI',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => setState(() => _dashboardTabIndex = 1),
                        style: TextButton.styleFrom(
                          backgroundColor: _dashboardTabIndex == 1 
                              ? theme.colorScheme.primary 
                              : Colors.transparent,
                          foregroundColor: _dashboardTabIndex == 1 
                              ? theme.colorScheme.onPrimary 
                              : (isDark ? Colors.white70 : Colors.black87),
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Text(
                          isEn ? 'FINANCIAL LITERACY' : 'IBY\'UMUTUNGO',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab contents
              if (_dashboardTabIndex == 0)
                AdvisoryDashboardWidget(
                  district: profile.district,
                  sector: profile.sector,
                  cropType: activeCrops,
                )
              else
                FinancialLiteracyWidget(
                  farmSize: profile.farmSize,
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.registrationTitle,
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.registrationSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // Profile Completion Progress Bar (Engagement indicator)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                  border: Border.all(
                    color: isDark ? Colors.white54 : Colors.black,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.locale.languageCode == 'en' ? 'Profile Completion:' : 'Ubwuzure bw\'Umwirondoro:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: isDark ? Colors.black38 : Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Full Name
              CustomTextField(
                controller: _nameController,
                labelText: l10n.name,
                hintText: l10n.nameHint,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // District Dropdown (Cascading Selector Matrix Level 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.district,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDistrict,
                    hint: Text(
                      l10n.districtHint,
                      style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                    ),
                    items: _locationMatrix.keys.map((dist) {
                      return DropdownMenuItem<String>(
                        value: dist,
                        child: Text(
                          dist,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDistrict = val;
                        _selectedSector = null; // Reset sector when district changes
                      });
                    },
                    validator: (value) => value == null ? l10n.fieldRequired : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sector Dropdown (Cascading Selector Matrix Level 2)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sector,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSector,
                    hint: Text(
                      _selectedDistrict == null 
                          ? (l10n.locale.languageCode == 'en' ? 'Select District First' : 'Banza uhitemo Akarere')
                          : l10n.sectorHint,
                      style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                    ),
                    items: sectorOptions.map((sect) {
                      return DropdownMenuItem<String>(
                        value: sect,
                        child: Text(
                          sect,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _selectedDistrict == null 
                        ? null 
                        : (val) {
                            setState(() {
                              _selectedSector = val;
                            });
                          },
                    validator: (value) => value == null ? l10n.fieldRequired : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Farm Size (Numeric Input)
              CustomTextField(
                controller: _farmSizeController,
                labelText: l10n.farmSize,
                hintText: l10n.farmSizeHint,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.landscape,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.fieldRequired;
                  }
                  final size = double.tryParse(value);
                  if (size == null || size <= 0) {
                    return l10n.invalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Experience Level selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.experienceLevel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedExperience,
                    hint: Text(
                      l10n.selectExperience,
                      style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                    ),
                    items: experienceOptions.map((exp) {
                      return DropdownMenuItem<String>(
                        value: exp['value'],
                        child: Text(
                          exp['label']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedExperience = val;
                      });
                    },
                    decoration: const InputDecoration(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Primary Crop Interests (Multi-select Filter Chips)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cropType,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: cropOptions.map((crop) {
                      final cropValue = crop['value']!;
                      final isSelected = _selectedCrops.contains(cropValue);
                      return ChoiceChip(
                        label: Text(
                          crop['label']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? Colors.white 
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        side: BorderSide(
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : (isDark ? Colors.white30 : Colors.black),
                          width: 2.0,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCrops.add(cropValue);
                            } else {
                              _selectedCrops.remove(cropValue);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              profileProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0,
                      ),
                    )
                  : CustomButton(
                      label: l10n.submit,
                      onPressed: _submitForm,
                      icon: Icons.check_circle_outline,
                    ),
              
              if (profileProvider.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  profileProvider.errorMessage,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
