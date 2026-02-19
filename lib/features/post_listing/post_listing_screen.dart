import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/mock_data.dart';

class PostListingScreen extends ConsumerStatefulWidget {
  const PostListingScreen({super.key});

  @override
  ConsumerState<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends ConsumerState<PostListingScreen> {
  int _currentStep = 0;
  final _totalSteps = 5;

  // Form data
  String? _brand, _series, _fuelType, _transmission, _bodyType, _color, _location;
  int? _year;
  int? _mileage;
  double? _price;
  bool _isNegotiable = false;
  String _description = '';
  List<String> _photos = [];
  String? _boostType; // null, 'homepage', 'emergency'
  String? _boostDuration; // '1', '3', '7'
  bool _isPhoneVerified = false;
  bool _showPhoneVerification = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('İlan Ver — Adım ${_currentStep + 1}/$_totalSteps'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: _buildStep(isDark),
              ),
            ),
          ),

          // Bottom navigation
          _buildNavButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildStep(bool isDark) {
    switch (_currentStep) {
      case 0:
        if (_showPhoneVerification && !_isPhoneVerified) {
          return _PhoneVerificationStep(
            isDark: isDark,
            onVerified: () {
              setState(() {
                _isPhoneVerified = true;
                _showPhoneVerification = false;
              });
            },
          );
        }
        return _Step1VehicleBasics(
          isDark: isDark,
          brand: _brand,
          series: _series,
          year: _year,
          mileage: _mileage,
          onBrandChanged: (v) => setState(() => _brand = v),
          onSeriesChanged: (v) => setState(() => _series = v),
          onYearChanged: (v) => setState(() => _year = v),
          onMileageChanged: (v) => setState(() => _mileage = v),
        );
      case 1:
        return _Step2VehicleDetails(
          isDark: isDark,
          fuelType: _fuelType,
          transmission: _transmission,
          bodyType: _bodyType,
          color: _color,
          onFuelChanged: (v) => setState(() => _fuelType = v),
          onTransmissionChanged: (v) => setState(() => _transmission = v),
          onBodyChanged: (v) => setState(() => _bodyType = v),
          onColorChanged: (v) => setState(() => _color = v),
        );
      case 2:
        return _Step3PriceLocation(
          isDark: isDark,
          price: _price,
          location: _location,
          isNegotiable: _isNegotiable,
          description: _description,
          onPriceChanged: (v) => setState(() => _price = v),
          onLocationChanged: (v) => setState(() => _location = v),
          onNegotiableChanged: (v) => setState(() => _isNegotiable = v),
          onDescriptionChanged: (v) => setState(() => _description = v),
        );
      case 3:
        return _Step4Photos(
          isDark: isDark,
          photos: _photos,
          onPhotosChanged: (v) => setState(() => _photos = v),
        );
      case 4:
        return _Step5BoostPayment(
          isDark: isDark,
          boostType: _boostType,
          boostDuration: _boostDuration,
          isNegotiable: _isNegotiable,
          onBoostTypeChanged: (v) => setState(() {
            _boostType = v;
            if (v == 'emergency') _isNegotiable = true;
          }),
          onBoostDurationChanged: (v) => setState(() => _boostDuration = v),
          onSubmit: _submitListing,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildNavButtons(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0 && !(_showPhoneVerification && !_isPhoneVerified))
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Geri'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          if (!(_showPhoneVerification && !_isPhoneVerified) && _currentStep < _totalSteps - 1)
            Expanded(
              child: ElevatedButton(
                onPressed: _canProceed() ? () => setState(() => _currentStep++) : null,
                child: const Text('Devam Et'),
              ),
            ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _brand != null && _year != null;
      case 1:
        return _fuelType != null && _transmission != null;
      case 2:
        return _price != null && _location != null;
      case 3:
        return _photos.isNotEmpty;
      default:
        return true;
    }
  }

  void _submitListing() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('İlan Gönderildi!'),
          ],
        ),
        content: const Text(
          'İlanınız admin onayına gönderildi. Onaylandıktan sonra yayına alınacak. Teşekkürler!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı İptal Et?'),
        content: const Text('Girdiğiniz bilgiler kaybolacak. Devam etmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hayır'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Evet, İptal Et'),
          ),
        ],
      ),
    );
  }
}

// -------------------- STEPS --------------------

class _PhoneVerificationStep extends StatefulWidget {
  final bool isDark;
  final VoidCallback onVerified;

  const _PhoneVerificationStep({required this.isDark, required this.onVerified});

  @override
  State<_PhoneVerificationStep> createState() => _PhoneVerificationStepState();
}

class _PhoneVerificationStepState extends State<_PhoneVerificationStep> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.phone_android, color: AppColors.primary, size: 48)
              .animate().scale(duration: 400.ms),
          const SizedBox(height: 16),
          const Text(
            'Telefon Doğrulama',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlan vermek için telefon numaranızı doğrulamanız gerekiyor. Her numara için yalnızca bir hesap açılabilir.',
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 32),
          if (!_codeSent) ...[
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası',
                hintText: '+90 555 xxx xx xx',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {
                        _codeSent = true;
                        _loading = false;
                      });
                    },
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Kod Gönder'),
            ),
          ] else ...[
            const Text(
              'Telefonunuza 6 haneli doğrulama kodu gönderildi.',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '6 Haneli Kod',
                hintText: '123456',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await Future.delayed(const Duration(seconds: 1));
                      widget.onVerified();
                    },
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Doğrula'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _codeSent = false;
                _codeCtrl.clear();
              }),
              child: const Text('Kodu Yeniden Gönder'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Step1VehicleBasics extends StatelessWidget {
  final bool isDark;
  final String? brand, series;
  final int? year, mileage;
  final Function(String?) onBrandChanged, onSeriesChanged;
  final Function(int?) onYearChanged, onMileageChanged;

  const _Step1VehicleBasics({
    required this.isDark,
    required this.brand,
    required this.series,
    required this.year,
    required this.mileage,
    required this.onBrandChanged,
    required this.onSeriesChanged,
    required this.onYearChanged,
    required this.onMileageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final years = List.generate(35, (i) => 2025 - i);
    final seriesList = brand != null ? (MockData.brandSeries[brand] ?? []) : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Araç Temel Bilgileri', '1/5', Icons.directions_car),
          const SizedBox(height: 24),
          _dropdown(
            label: 'Marka *',
            value: brand,
            items: MockData.brands,
            isDark: isDark,
            onChanged: (v) {
              onBrandChanged(v);
              onSeriesChanged(null);
            },
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Seri',
            value: series,
            items: seriesList,
            isDark: isDark,
            onChanged: onSeriesChanged,
            enabled: brand != null,
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Yıl *',
            value: year?.toString(),
            items: years.map((y) => y.toString()).toList(),
            isDark: isDark,
            onChanged: (v) => onYearChanged(v != null ? int.tryParse(v) : null),
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kilometre *',
              suffixText: 'km',
              prefixIcon: Icon(Icons.speed),
            ),
            onChanged: (v) => onMileageChanged(int.tryParse(v.replaceAll('.', ''))),
          ),
        ],
      ),
    );
  }
}

class _Step2VehicleDetails extends StatelessWidget {
  final bool isDark;
  final String? fuelType, transmission, bodyType, color;
  final Function(String?) onFuelChanged, onTransmissionChanged, onBodyChanged, onColorChanged;

  const _Step2VehicleDetails({
    required this.isDark,
    required this.fuelType,
    required this.transmission,
    required this.bodyType,
    required this.color,
    required this.onFuelChanged,
    required this.onTransmissionChanged,
    required this.onBodyChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Araç Detayları', '2/5', Icons.settings),
          const SizedBox(height: 24),
          _dropdown(
            label: 'Yakıt Tipi *',
            value: fuelType,
            items: MockData.fuelTypes,
            isDark: isDark,
            onChanged: onFuelChanged,
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Vites *',
            value: transmission,
            items: MockData.transmissions,
            isDark: isDark,
            onChanged: onTransmissionChanged,
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Kasa Tipi',
            value: bodyType,
            items: MockData.bodyTypes,
            isDark: isDark,
            onChanged: onBodyChanged,
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Renk',
            value: color,
            items: MockData.colors,
            isDark: isDark,
            onChanged: onColorChanged,
          ),
        ],
      ),
    );
  }
}

class _Step3PriceLocation extends StatelessWidget {
  final bool isDark;
  final double? price;
  final String? location;
  final bool isNegotiable;
  final String description;
  final Function(double?) onPriceChanged;
  final Function(String?) onLocationChanged;
  final Function(bool) onNegotiableChanged;
  final Function(String) onDescriptionChanged;

  const _Step3PriceLocation({
    required this.isDark,
    required this.price,
    required this.location,
    required this.isNegotiable,
    required this.description,
    required this.onPriceChanged,
    required this.onLocationChanged,
    required this.onNegotiableChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Fiyat & Konum', '3/5', Icons.attach_money),
          const SizedBox(height: 24),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Fiyat (TL) *',
              suffixText: '₺',
              prefixIcon: Icon(Icons.attach_money),
              helperText: 'Min: 10.000 TL — Max: 20.000.000 TL',
            ),
            onChanged: (v) => onPriceChanged(double.tryParse(v.replaceAll('.', ''))),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pazarlığa Açık', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        'Alıcılar fiyat teklifinde bulunabilir',
                        style: TextStyle(fontSize: 12, color: AppColors.darkTextHint),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isNegotiable,
                  onChanged: onNegotiableChanged,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Şehir *',
            value: location,
            items: MockData.locations,
            isDark: isDark,
            onChanged: onLocationChanged,
          ),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
              hintText: 'Aracınız hakkında detaylı bilgi verin...',
              alignLabelWithHint: true,
            ),
            onChanged: onDescriptionChanged,
          ),
        ],
      ),
    );
  }
}

class _Step4Photos extends StatelessWidget {
  final bool isDark;
  final List<String> photos;
  final Function(List<String>) onPhotosChanged;

  const _Step4Photos({
    required this.isDark,
    required this.photos,
    required this.onPhotosChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Fotoğraflar', '4/5', Icons.photo_camera),
          const SizedBox(height: 8),
          Text(
            'En az 1, en fazla 15 fotoğraf ekleyebilirsiniz. İlk fotoğraf kapak olacak.',
            style: TextStyle(
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                ...photos.asMap().entries.map((entry) => _PhotoTile(
                  index: entry.key,
                  isFirst: entry.key == 0,
                  isDark: isDark,
                  onDelete: () {
                    final updated = List<String>.from(photos)..removeAt(entry.key);
                    onPhotosChanged(updated);
                  },
                )),
                if (photos.length < 15)
                  GestureDetector(
                    onTap: () async {
                      if (photos.length < 15) {
                        // Simulate photo addition with a placeholder
                        final updated = List<String>.from(photos)
                          ..add('https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400');
                        onPhotosChanged(updated);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 32),
                          SizedBox(height: 4),
                          Text('Ekle', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${photos.length}/15 fotoğraf',
            style: const TextStyle(color: AppColors.darkTextHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final int index;
  final bool isFirst;
  final bool isDark;
  final VoidCallback onDelete;

  const _PhotoTile({
    required this.index,
    required this.isFirst,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
            child: const Icon(Icons.image, size: 40, color: AppColors.darkTextHint),
          ),
        ),
        if (isFirst)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Kapak', style: TextStyle(color: Colors.white, fontSize: 9)),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _Step5BoostPayment extends StatelessWidget {
  final bool isDark;
  final String? boostType, boostDuration;
  final bool isNegotiable;
  final Function(String?) onBoostTypeChanged;
  final Function(String?) onBoostDurationChanged;
  final VoidCallback onSubmit;

  const _Step5BoostPayment({
    required this.isDark,
    required this.boostType,
    required this.boostDuration,
    required this.isNegotiable,
    required this.onBoostTypeChanged,
    required this.onBoostDurationChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final homepagePrices = {'1': '99,99', '3': '249,99', '7': '549,99'};
    final emergencyPrices = {'1': '129,99', '3': '329,99', '7': '649,99'};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Boost & Ödeme', '5/5', Icons.bolt),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.success, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'İlk ilanınız ÜCRETSİZ! Sonraki ilanlar: 199,99 ₺',
                    style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Boost Tipi (İsteğe Bağlı)', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _BoostOptionCard(
            title: 'Boost Yok',
            subtitle: 'Normal ilan olarak yayınla',
            icon: Icons.list_alt,
            isSelected: boostType == null,
            price: 'Ücretsiz',
            isDark: isDark,
            onTap: () => onBoostTypeChanged(null),
          ),
          const SizedBox(height: 10),
          _BoostOptionCard(
            title: 'Ana Sayfa Boost',
            subtitle: 'Ana sayfada üstte sabit, parlayan efekt',
            icon: Icons.bolt,
            isSelected: boostType == 'homepage',
            price: '',
            isDark: isDark,
            onTap: () => onBoostTypeChanged('homepage'),
            isGold: true,
          ),
          if (boostType == 'homepage') ...[
            const SizedBox(height: 10),
            _DurationSelector(
              prices: homepagePrices,
              selected: boostDuration,
              onSelect: onBoostDurationChanged,
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 10),
          _BoostOptionCard(
            title: 'Acil Boost',
            subtitle: 'Acil sayfasında + ana sayfada öne çık',
            icon: Icons.warning_amber_rounded,
            isSelected: boostType == 'emergency',
            price: '',
            isDark: isDark,
            onTap: () => onBoostTypeChanged('emergency'),
            isRed: true,
          ),
          if (boostType == 'emergency') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.emergencyRed.withOpacity(0.3)),
              ),
              child: const Text(
                '"Pazarlığa Açık" otomatik olarak işaretlendi. Acil ilanlar için zorunludur.',
                style: TextStyle(color: AppColors.emergencyRed, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            _DurationSelector(
              prices: emergencyPrices,
              selected: boostDuration,
              onSelect: onBoostDurationChanged,
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 24),
          _PriceSummary(
            boostType: boostType,
            boostDuration: boostDuration,
            homepagePrices: homepagePrices,
            emergencyPrices: emergencyPrices,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              boostType == null ? 'İlanı Yayınla (Ücretsiz)' : 'Ödemeye Geç (PayTR)',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoostOptionCard extends StatelessWidget {
  final String title, subtitle, price;
  final IconData icon;
  final bool isSelected, isDark;
  final bool isGold, isRed;
  final VoidCallback onTap;

  const _BoostOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.price,
    required this.isDark,
    required this.onTap,
    this.isGold = false,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed
        ? AppColors.emergencyRed
        : (isGold ? AppColors.gold : AppColors.primary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.darkTextHint, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? color : null)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                    ),
                  ),
                ],
              ),
            ),
            if (price.isNotEmpty)
              Text(price, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final Map<String, String> prices;
  final String? selected;
  final Function(String?) onSelect;
  final bool isDark;

  const _DurationSelector({
    required this.prices,
    required this.selected,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: prices.entries.map((entry) {
        final isSelected = selected == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(entry.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : (isDark ? AppColors.darkSurface2 : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${entry.key} Gün',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isSelected ? AppColors.primaryLight : null,
                    ),
                  ),
                  Text(
                    '${entry.value} ₺',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppColors.primaryLight : AppColors.darkTextHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final String? boostType, boostDuration;
  final Map<String, String> homepagePrices, emergencyPrices;
  final bool isDark;

  const _PriceSummary({
    required this.boostType,
    required this.boostDuration,
    required this.homepagePrices,
    required this.emergencyPrices,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    String boostPrice = '0';
    if (boostType == 'homepage' && boostDuration != null) {
      boostPrice = homepagePrices[boostDuration]!;
    } else if (boostType == 'emergency' && boostDuration != null) {
      boostPrice = emergencyPrices[boostDuration]!;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'İlan Yayınlama', value: 'Ücretsiz (İlk İlan)', isDark: isDark),
          if (boostType != null && boostDuration != null) ...[
            const Divider(height: 16),
            _PriceRow(
              label: '${boostType == 'homepage' ? 'Ana Sayfa' : 'Acil'} Boost ($boostDuration gün)',
              value: '$boostPrice ₺',
              isDark: isDark,
              isHighlighted: true,
            ),
          ],
          const Divider(height: 16),
          _PriceRow(
            label: 'Toplam',
            value: boostDuration != null ? '$boostPrice ₺' : '0 ₺',
            isDark: isDark,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isDark, isHighlighted, isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isHighlighted = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted || isBold ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}

// Helper widgets
Widget _stepTitle(String title, String step, IconData icon) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ],
  ).animate().fadeIn(duration: 300.ms);
}

Widget _dropdown({
  required String label,
  required String? value,
  required List<String> items,
  required bool isDark,
  required Function(String?) onChanged,
  bool enabled = true,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      enabled: enabled,
    ),
    dropdownColor: isDark ? AppColors.darkSurface2 : AppColors.lightBackground,
    items: items
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    onChanged: enabled ? onChanged : null,
  );
}
