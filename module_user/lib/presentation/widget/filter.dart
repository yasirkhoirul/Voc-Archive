import 'package:flutter/material.dart';
import 'package:module_core/shared_domain/shared_usecases/get_brands_usecase.dart';
import 'package:get_it/get_it.dart';

typedef FilterCallback = void Function(List<String> types, double? minPrice, double? maxPrice);
typedef BrandSelectionCallback = void Function(String brand, bool isSelected);

class MobileFilterContent extends StatefulWidget {
  final FilterCallback onSet;
  const MobileFilterContent({super.key, required this.onSet});

  @override
  State<MobileFilterContent> createState() => _MobileFilterContentState();
}

class _MobileFilterContentState extends State<MobileFilterContent> {
  final List<String> _selectedTypes = [];
  late final Future<dynamic> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _brandsFuture = GetIt.I.get<GetBrandsUsecase>().call();
  }

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
      widget.onSet(_selectedTypes, null, null);
    });
  }

  void _showAll() {
    setState(() {
      _selectedTypes.clear();
      widget.onSet(_selectedTypes, null, null);
      Navigator.of(context).pop();
    });
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
                  final brands = (snapshot.data!.getOrElse(() => <Map<String, dynamic>>[]) as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _BrandFilterButton(
                        label: 'Show All',
                        isSelected: _selectedTypes.isEmpty,
                        onPressed: _showAll,
                      ),
                      ...brands.map((brand) {
                        final title = brand['nama']?.toString() ?? 'Unknown';
                        return _BrandFilterButton(
                          label: title,
                          isSelected: _selectedTypes.contains(title),
                          onPressed: () => _toggleType(title),
                        );
                      }).toList(),
                    ],
                  );
                }
                return const Text('Failed to load types');
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
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
  late final Future<dynamic> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _brandsFuture = GetIt.I.get<GetBrandsUsecase>().call();
  }

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
      widget.onSet(_selectedTypes, null, null);
    });
  }

  void _showAll() {
    setState(() {
      _selectedTypes.clear();
      widget.onSet(_selectedTypes, null, null);
    });
  }

  Widget _buildAnimatedItem(Widget child, int index, int total) {
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
          final brandsData = snapshot.data!.getOrElse(() => <Map<String, dynamic>>[]);
          final brands = (brandsData as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
          brandWidgets = [
            _BrandFilterButton(
              label: 'Show All',
              isSelected: _selectedTypes.isEmpty,
              onPressed: _showAll,
            ),
            const SizedBox(height: 8),
            ...brands.map<Widget>((brand) {
              final title = brand['nama']?.toString() ?? 'Unknown';
              return Column(
                children: [
                  _BrandFilterButton(
                    label: title,
                    isSelected: _selectedTypes.contains(title),
                    onPressed: () => _toggleType(title),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ];
        }

        final filterItems = [
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          ...brandWidgets,
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

class _BrandFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _BrandFilterButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: BorderSide(
          color: isSelected ? Colors.black : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
