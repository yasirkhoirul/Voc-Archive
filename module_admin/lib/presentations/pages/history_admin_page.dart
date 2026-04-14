import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:module_core/shared_domain/shared_entities/order_history.dart';
import '../cubit/history_cubit.dart';
import 'package:module_core/module_core.dart';

class HistoryAdminPage extends StatefulWidget {
  const HistoryAdminPage({super.key});

  @override
  State<HistoryAdminPage> createState() => _HistoryAdminPageState();
}

class _HistoryAdminPageState extends State<HistoryAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().fetchAllHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (state is HistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.read<HistoryCubit>().fetchAllHistory(),
                    child: const Text('Coba Ulang'),
                  )
                ],
              ),
            );
          } else if (state is HistoryLoaded) {
            final allOrders = state.historyList;
            final orders = allOrders.where((element) {
              final val = element.orderId.toLowerCase() + element.customer.name.toLowerCase();
              return val.contains(_searchQuery.toLowerCase());
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 500,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari Transaksi',
                          suffixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (orders.isEmpty)
                    const Center(child: Text('Tidak ada transaksi ditemukan.'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _OrderHistoryCard(order: orders[index]);
                      },
                    ),
                ],
              ),
            );
          }
          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }
}

class _OrderHistoryCard extends StatefulWidget {
  final OrderHistoryEntity order;
  const _OrderHistoryCard({required this.order});

  @override
  State<_OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends State<_OrderHistoryCard> {
  bool _isExpanded = false;

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('success') || status.toLowerCase().contains('settlement')) {
      return Colors.green;
    } else if (status.toLowerCase().contains('failed') || status.toLowerCase().contains('expire')) {
      return Colors.red.shade400;
    }
    return Colors.amber.shade400; // Pending
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final createdAt = order.createdAt ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Id Transaksi  : ${order.orderId}', style: const TextStyle(fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        order.status,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Nama Pembeli  : ${order.customer.name}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text('Tanggal Transaksi : ${DateFormat('dd/MM/yyyy').format(createdAt)}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text('Waktu Transaksi : ${DateFormat('HH.mm').format(createdAt)}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? 'Tutup Detail' : 'Detail Selengkapnya',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Email Pembeli  : ${order.customer.email}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('No Hp : ${order.customer.phone}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('Metode Pembayaran : ${order.paymentMethod}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  const Text('List Item :', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ...order.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nama : ${item.productName}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          BlocBuilder<CurrencyCubit, CurrencyState>(
                            builder: (context, currencyState) {
                              return Text('Harga : ${context.read<CurrencyCubit>().format(item.finalPriceUsd)}', style: const TextStyle(fontSize: 16));
                            },
                          ),
                          const SizedBox(height: 8),
                          Text('Brand : ${item.brandName}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Ukuran : ${item.size}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Qty : ${item.quantity}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text('Shipping : ${order.shippingArea}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('Kota : ${order.customer.city}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('Kode Pos : ${order.customer.postalCode}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('Alamat : ${order.customer.address}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  BlocBuilder<CurrencyCubit, CurrencyState>(
                    builder: (context, currencyState) {
                      return Text(
                        'Total Harga : ${context.read<CurrencyCubit>().format(order.totalUsd)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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