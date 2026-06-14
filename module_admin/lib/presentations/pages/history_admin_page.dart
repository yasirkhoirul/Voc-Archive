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

class _HistoryAdminPageState extends State<HistoryAdminPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<HistoryCubit>().fetchAllHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<OrderHistoryEntity> _filterOrders(
    List<OrderHistoryEntity> orders,
    String? paymentMethodFilter,
  ) {
    return orders.where((e) {
      final matchSearch =
          (e.orderId.toLowerCase() + e.customer.name.toLowerCase()).contains(
            _searchQuery.toLowerCase(),
          );
      final matchMethod =
          paymentMethodFilter == null || e.paymentMethod == paymentMethodFilter;
      return matchSearch && matchMethod;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<HistoryCubit, HistoryState>(
        listener: (context, state) {
          if (state is HistoryActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
            // Re-fetch after error
            context.read<HistoryCubit>().fetchAllHistory();
          }
        },
        builder: (context, state) {
          if (state is HistorySyncing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text(
                    'Sinkronisasi pembayaran...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          } else if (state is HistoryLoading || state is HistoryActionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (state is HistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HistoryCubit>().fetchAllHistory(),
                    child: const Text('Coba Ulang'),
                  ),
                ],
              ),
            );
          } else if (state is HistoryLoaded) {
            final allOrders = state.historyList;

            return Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
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
                const SizedBox(height: 24),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(text: 'Semua Transaksi'),
                    Tab(text: 'PayPal (Perlu Konfirmasi)'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: All transactions
                      _buildOrderList(
                        _filterOrders(allOrders, null),
                        showActions: false,
                      ),
                      // Tab 2: PayPal manual only
                      _buildOrderList(
                        _filterOrders(allOrders, 'paypal_manual'),
                        showActions: true,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }

  Widget _buildOrderList(
    List<OrderHistoryEntity> orders, {
    required bool showActions,
  }) {
    if (orders.isEmpty) {
      return const Center(child: Text('Tidak ada transaksi ditemukan.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderHistoryCard(
          order: orders[index],
          showActions: showActions,
        );
      },
    );
  }
}

class _OrderHistoryCard extends StatefulWidget {
  final OrderHistoryEntity order;
  final bool showActions;

  const _OrderHistoryCard({required this.order, required this.showActions});

  @override
  State<_OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends State<_OrderHistoryCard> {
  bool _isExpanded = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'settlement':
        return Colors.green;
      case 'cancel':
      case 'deny':
      case 'expire':
        return Colors.red.shade400;
      default:
        return Colors.amber.shade400;
    }
  }

  void _showConfirmDialog(String orderId, bool isConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isConfirm ? 'Konfirmasi Pembayaran' : 'Tolak Pembayaran'),
        content: Text(
          isConfirm
              ? 'Yakin ingin mengkonfirmasi pembayaran PayPal untuk order $orderId?'
              : 'Yakin ingin menolak pembayaran PayPal untuk order $orderId? Stok akan dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isConfirm ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (isConfirm) {
                context.read<HistoryCubit>().confirmPaypalOrder(orderId);
              } else {
                context.read<HistoryCubit>().rejectPaypalOrder(orderId);
              }
            },
            child: Text(isConfirm ? 'Konfirmasi' : 'Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final createdAt = order.createdAt ?? DateTime.now();
    final isPending = order.status.toLowerCase() == 'pending';
    final isPaypal = order.paymentMethod == 'paypal_manual';

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
                    Expanded(
                      child: Text(
                        'Id Transaksi  : ${order.orderId}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nama Pembeli  : ${order.customer.name}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tanggal Transaksi : ${DateFormat('dd/MM/yyyy').format(createdAt)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Waktu Transaksi : ${DateFormat('HH.mm').format(createdAt)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPaypal
                            ? Colors.blue.shade50
                            : Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPaypal ? 'PayPal Manual' : 'Xendit',
                        style: TextStyle(
                          color: isPaypal
                              ? Colors.blue.shade700
                              : Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
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
                  Text(
                    'Email Pembeli  : ${order.customer.email}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Hp : ${order.customer.phone}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Metode Pembayaran : ${order.paymentMethod}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  // PayPal proof image
                  if (isPaypal && order.proofUrl.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Bukti Pembayaran PayPal:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: order.proofUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text('List Item :', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ...order.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama : ${item.productName}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<CurrencyCubit, CurrencyState>(
                            builder: (context, currencyState) {
                              return Text(
                                'Harga : ${context.read<CurrencyCubit>().format(item.finalPriceUsd)}',
                                style: const TextStyle(fontSize: 16),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Brand : ${item.brandName}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ukuran : ${item.size}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Qty : ${item.quantity}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'Shipping : ${order.shippingArea}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kota : ${order.customer.city}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kode Pos : ${order.customer.postalCode}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Alamat : ${order.customer.address}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<CurrencyCubit, CurrencyState>(
                    builder: (context, currencyState) {
                      return Text(
                        'Total Harga : ${context.read<CurrencyCubit>().format(order.totalUsd)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  // Action buttons for pending PayPal orders
                  if (widget.showActions && isPaypal && isPending) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showConfirmDialog(order.orderId, false),
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              'Tolak',
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showConfirmDialog(order.orderId, true),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Konfirmasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
