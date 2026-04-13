import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_core/shared_domain/shared_usecases/get_brands_usecase.dart';
import 'package:get_it/get_it.dart';

typedef FilterCallback = void Function(List<String> types, double? minPrice, double? maxPrice);

class MobileFilterContent extends StatefulWidget {
  final FilterCallback onSet;
  const MobileFilterContent({super.key, required this.onSet});

  @override
  State<MobileFilterContent> createState() => _MobileFilterContentState();
}

class _MobileFilterContentState extends State<MobileFilterContent> {
  final List<String> _selectedTypes = [];
  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();
  late final Future<dynamic> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _brandsFuture = GetIt.I.get<GetBrandsUsecase>().call();
  }

  void _toggleType(String type, bool? value) {
    setState(() {
      if (value == true) {
        _selectedTypes.add(type);
      } else {
        _selectedTypes.remove(type);
      }
    });
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            FutureBuilder(
              future: _brandsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data!.isRight()) {
                  final brands = snapshot.data!.getOrElse(() => <Map<String, dynamic>>[]);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: brands.map((brand) {
                      final title = brand['nama'] ?? 'Unknown';
                      return _CheckboxItem(
                        title: title,
                        value: _selectedTypes.contains(title),
                        onChanged: (val) => _toggleType(title, val),
                      );
                    }).toList(),
                  );
                }
                return const Text('Failed to load types');
              },
            ),
          ],
        ),
        const Divider(height: 32),
        const Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _PriceInput(controller: _minPriceCtrl, hintText: 'Min (USD)')),
            const SizedBox(width: 16),
            Expanded(child: _PriceInput(controller: _maxPriceCtrl, hintText: 'Max (USD)')),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
               final minP = double.tryParse(_minPriceCtrl.text);
               final maxP = double.tryParse(_maxPriceCtrl.text);
               widget.onSet(_selectedTypes, minP, maxP);
               Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Set'),
          ),
        ),
      ],
    );
  }
}

class DesktopFilter extends StatefulWidget {
  final VoidCallback onToggle;
  final Animation<double> animation;
  final FilterCallback onSet;

  const DesktopFilter({
    super.key,
    required this.onToggle,
    required this.animation,
    required this.onSet,
  });

  @override
  State<DesktopFilter> createState() => _DesktopFilterState();
}

class _DesktopFilterState extends State<DesktopFilter> {
  final List<String> _selectedTypes = [];
  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();
  late final Future<dynamic> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _brandsFuture = GetIt.I.get<GetBrandsUsecase>().call();
  }

  void _toggleType(String type, bool? value) {
    setState(() {
      if (value == true) {
        _selectedTypes.add(type);
      } else {
        _selectedTypes.remove(type);
      }
    });
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(Widget child, int index, int total) {
    // Calculate staggered slide animation for each item
    final start = 0.4 + (index / total) * 0.4;
    final end = start + 0.2;
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.animation,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animation,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeIn),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _brandsFuture,
      builder: (context, snapshot) {
        List<Widget> brandWidgets = [const Text('Loading types...')];
        if (snapshot.hasData && snapshot.data!.isRight()) {
          final brands = snapshot.data!.getOrElse(() => <Map<String, dynamic>>[]);
          brandWidgets = brands.map<Widget>((brand) {
            final title = brand['nama'] ?? 'Unknown';
            return _CheckboxItem(
              title: title,
              value: _selectedTypes.contains(title),
              onChanged: (val) => _toggleType(title, val),
            );
          }).toList();
        }

        final filterItems = [
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          ...brandWidgets,
          const Divider(height: 32),
          const Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _PriceInput(controller: _minPriceCtrl, hintText: 'Min (USD)')),
              const SizedBox(width: 8),
              Expanded(child: _PriceInput(controller: _maxPriceCtrl, hintText: 'Max (USD)')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final minP = double.tryParse(_minPriceCtrl.text);
                final maxP = double.tryParse(_maxPriceCtrl.text);
                widget.onSet(_selectedTypes, minP, maxP);
                widget.onToggle();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Set', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ];

        return Container(
          width: 250,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          onPressed: widget.onToggle,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(filterItems.length, (index) {
                      return _buildAnimatedItem(filterItems[index], index, filterItems.length);
                    }),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24.0),
                color: Colors.grey[400],
                width: double.infinity,
                child: const Text('USD \$ | United State', textAlign: TextAlign.center),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxItem({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          visualDensity: VisualDensity.compact,
        ),
        Text(title),
      ],
    );
  }
}

class _PriceInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _PriceInput({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
      ],
    );
  }
}
