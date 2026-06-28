import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyouthconnect/presentation/providers/auth_provider.dart';

/// AdvisoryDashboardWidget fetches and displays AI planting calendar & input recommendations.
class AdvisoryDashboardWidget extends StatefulWidget {
  final String district;
  final String sector;
  final String cropType;

  const AdvisoryDashboardWidget({
    super.key,
    required this.district,
    required this.sector,
    required this.cropType,
  });

  @override
  State<AdvisoryDashboardWidget> createState() => _AdvisoryDashboardWidgetState();
}

class _AdvisoryDashboardWidgetState extends State<AdvisoryDashboardWidget> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _advisoryData;
  bool _feedbackSubmitted = false;
  String _feedbackValue = '';

  @override
  void initState() {
    super.initState();
    _fetchAdvisory();
  }

  Future<void> _fetchAdvisory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiClient = authProvider.apiClient;

      // Extract first crop from user interests
      final crops = widget.cropType.split(',');
      final primaryCrop = crops.isNotEmpty ? crops.first.trim() : 'Maize';

      final response = await apiClient.post(
        '/advisory',
        data: {
          'district': widget.district,
          'sector': widget.sector,
          'crop_type': primaryCrop,
          'current_month': 'October', // Current season A starting month
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _advisoryData = Map<String, dynamic>.from(response.data as Map);
          _isLoading = false;
        });
      } else {
        throw Exception('Server returned code ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load real-time AI advisory. Showing local fallback matrix.';
        _advisoryData = _getLocalFallbackAdvisory();
        _isLoading = false;
      });
    }
  }

  void _submitFeedback(String score) {
    setState(() {
      _feedbackSubmitted = true;
      _feedbackValue = score;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for rating this advisory as "$score"!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Map<String, dynamic> _getLocalFallbackAdvisory() {
    return {
      'optimal_planting_window': 'September 15 - October 15 (Season A)',
      'input_optimization': {
        'fertilizer_type': 'NPK 17-17-17',
        'application_interval_weeks': 4,
        'quantity_kg_per_ha': 250.0,
        'application_instructions': 'Apply standard NPK mix in row beds. Mix with organic manure.'
      },
      'irrigation_threshold_m3_per_ha': 150.0,
      'yield_forecast_tons_per_ha': 2.1,
      'risk_metrics': [
        {'hazard_name': 'Drought Risk', 'probability_pct': 30.0, 'warning_level': 'Medium'},
        {'hazard_name': 'Flood Risk', 'probability_pct': 10.0, 'warning_level': 'Low'},
        {'hazard_name': 'Pest Outbreak', 'probability_pct': 40.0, 'warning_level': 'Medium'}
      ],
      'overall_status': 'Local cached agricultural baseline data active.'
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 4.0),
        ),
      );
    }

    if (_advisoryData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2.0),
        ),
        child: const Text(
          'Failed to retrieve advisory. Please check your network connection.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    final data = _advisoryData!;
    final inputOpt = data['input_optimization'] as Map;
    final risks = data['risk_metrics'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error/Warning banner if showing fallback cache
        if (_errorMessage.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              border: Border.all(color: Colors.amber, width: 2.0),
            ),
            child: Text(
              _errorMessage,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        // 1. Optimal Planting Window Card
        Text(
          'Optimal Planting Schedule',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white54 : Colors.black, width: 2.0),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, size: 36, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PLANTING WINDOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      data['optimal_planting_window'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Yield Forecast & Inputs
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildAdvisoryValueCard(
                title: 'PROJECTED YIELD',
                value: '${data['yield_forecast_tons_per_ha']} T/Ha',
                detail: 'Based on soil analytics',
                icon: Icons.trending_up,
                color: Colors.green,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAdvisoryValueCard(
                title: 'WATER IRRIGATION',
                value: '${data['irrigation_threshold_m3_per_ha']} m³',
                detail: 'Volume per hectare',
                icon: Icons.water_drop,
                color: Colors.blue,
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 3. Input Optimizations
        Text(
          'Input Recommendations',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white30 : Colors.black26),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletDetail('Fertilizer Type:', inputOpt['fertilizer_type'] as String, isDark),
              _buildBulletDetail('Quantity per Ha:', '${inputOpt['quantity_kg_per_ha']} Kg', isDark),
              _buildBulletDetail('Application Interval:', 'Every ${inputOpt['application_interval_weeks']} weeks', isDark),
              const Divider(height: 24),
              Text(
                'Instructions:\n${inputOpt['application_instructions']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 4. Risk warnings
        Text(
          'Risk & Hazards Forecast',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: risks.length,
          itemBuilder: (context, index) {
            final risk = risks[index] as Map;
            final isHigh = risk['warning_level'] == 'High';
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isHigh ? Colors.red : (isDark ? Colors.white24 : Colors.black12),
                  width: isHigh ? 2.0 : 1.0,
                ),
                color: isHigh ? Colors.red.withValues(alpha: 0.05) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isHigh ? Icons.warning : Icons.info,
                        color: isHigh ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        risk['hazard_name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    '${risk['probability_pct']}% Prob (${risk['warning_level']})',
                    style: TextStyle(
                      fontWeight: FontWeight.black,
                      color: isHigh ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // 5. Feedback loops
        Text(
          'Was this advisory accurate?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (_feedbackSubmitted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2.0),
              color: Colors.green.withValues(alpha: 0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Feedback logged: "$_feedbackValue"',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _submitFeedback('Helpful'),
                  icon: const Icon(Icons.thumb_up, color: Colors.green),
                  label: const Text('HELPFUL', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _submitFeedback('Not Helpful'),
                  icon: const Icon(Icons.thumb_down, color: Colors.red),
                  label: const Text('NOT HELPFUL', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAdvisoryValueCard({
    required String title,
    required String value,
    required String detail,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white54 : Colors.black,
          width: 2.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletDetail(String title, String val, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
