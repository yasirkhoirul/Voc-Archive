import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enums/currency_enum.dart';
import '../../utils/currency_converter.dart';

class SidebarAdmin extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;
  const SidebarAdmin({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Selamat Datang Admin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          _buildMenuItem(0, 'Setting Produk'),
          _buildMenuItem(1, 'Sold Out Produk'),
          _buildMenuItem(2, 'Setting Dashboard'),
          _buildMenuItem(3, 'Setting Display'),
          _buildMenuItem(4, 'Setting Harga'),
          _buildMenuItem(5, 'Brands produk'),
          _buildMenuItem(6, 'History Transaksi'),
          // _buildMenuItem(6, 'User'), // Optional
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Currency (IDR/USD)',
                  style: TextStyle(fontSize: 12),
                ),
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

  Widget _buildMenuItem(int index, String title) {
    final bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
