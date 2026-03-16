import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              onTap(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Products'),
            onTap: () {
              onTap(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () {
              // Handle users navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Handle settings navigation
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Currency (IDR/USD)'),
                BlocBuilder<CurrencyCubit, CurrencyType>(
                  builder: (context, state) {
                    return Switch(
                      value: state == CurrencyType.usd,
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