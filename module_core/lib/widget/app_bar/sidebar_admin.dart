import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enums/currency_enum.dart';
import '../../utils/currency_converter.dart';

class SidebarAdmin extends StatelessWidget {
  final Function(int index) onTap;
  const SidebarAdmin({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Products'),
            onTap: () {
              onTap(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Settings'),
            onTap: () {
              onTap(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_carousel),
            title: const Text('Sliders'),
            onTap: () {
              onTap(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dvr),
            title: const Text('Displays'),
            onTap: () {
              onTap(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.branding_watermark),
            title: const Text('Brands'),
            onTap: () {
              onTap(4);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Currency (IDR/USD)'),
                BlocBuilder<CurrencyCubit, CurrencyState>(
                  builder: (context, state) {
                    return Switch(
                      value: state.currencyType == CurrencyType.usd,
                      onChanged: (value) {
                        context.read<CurrencyCubit>().toggleCurrency();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
