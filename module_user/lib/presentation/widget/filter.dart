import 'package:flutter/material.dart';
import 'package:module_core/shared_domain/shared_usecases/get_brands_usecase.dart';
import 'package:get_it/get_it.dart';

class MobileFilterContent extends StatelessWidget {
  const MobileFilterContent({super.key});

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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  const _CheckboxItem(title: 'Kategori'),
                  const _CheckboxItem(title: 'Kategori'),
                  const _CheckboxItem(title: 'Kategori'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future: GetIt.I.get<GetBrandsUsecase>().call(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData && snapshot.data!.isRight()) {
                        final brands = snapshot.data!.getOrElse(() => []);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: brands.map((brand) {
                            return _CheckboxItem(title: brand['nama'] ?? 'Unknown');
                          }).toList(),
                        );
                      }
                      return const Text('Failed to load types');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 32),
        const Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: _PriceInput()),
            SizedBox(width: 16),
            Expanded(child: _PriceInput()),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
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

class DesktopFilter extends StatelessWidget {
  final VoidCallback onToggle;
  final Animation<double> animation;

  const DesktopFilter({
    super.key,
    required this.onToggle,
    required this.animation,
  });

  Widget _buildAnimatedItem(Widget child, int index, int total) {
    // Calculate staggered slide animation for each item
    final start = 0.4 + (index / total) * 0.4;
    final end = start + 0.2;
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
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
      future: GetIt.I.get<GetBrandsUsecase>().call(),
      builder: (context, snapshot) {
        List<Widget> brandWidgets = [const Text('Loading types...')];
        if (snapshot.hasData && snapshot.data!.isRight()) {
          final brands = snapshot.data!.getOrElse(() => []);
          brandWidgets = brands.map((b) => _DesktopFilterItem(title: b['nama'] ?? 'Unknown')).toList();
        }

        final filterItems = [
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          const _DesktopFilterItem(title: 'Shirt'),
          const _DesktopFilterItem(title: 'T-Shirt'),
          const _DesktopFilterItem(title: 'Jeans'),
          const Divider(height: 32),
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          ...brandWidgets,
          const Divider(height: 32),
          const Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _PriceInput()),
              SizedBox(width: 8),
              Expanded(child: _PriceInput()),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
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
                          onPressed: onToggle,
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

  const _CheckboxItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: false,
          onChanged: (val) {},
          visualDensity: VisualDensity.compact,
        ),
        Text(title),
      ],
    );
  }
}

class _PriceInput extends StatelessWidget {
  const _PriceInput();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
    );
  }
}

class _DesktopFilterItem extends StatelessWidget {
  final String title;

  const _DesktopFilterItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 14)),
    );
  }
}
