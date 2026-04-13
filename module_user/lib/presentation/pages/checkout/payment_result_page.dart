import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/checkout_bloc.dart';
import '../../bloc/cart_bloc.dart';

class PaymentResultPage extends StatelessWidget {
  const PaymentResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Payment Status',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatusIcon(state.paymentStatus),
                        const SizedBox(height: 24),
                        Text(
                          _getStatusTitle(state.paymentStatus),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getStatusMessage(state.paymentStatus),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (state.orderId != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                _infoRow('Order ID', state.orderId!),
                                const Divider(),
                                _infoRow(
                                  'Total (IDR)',
                                  'Rp ${state.totalIdr?.toStringAsFixed(0) ?? '-'}',
                                ),
                                const Divider(),
                                _infoRow(
                                  'Total (USD)',
                                  '\$ ${state.totalUsd?.toStringAsFixed(2) ?? '-'}',
                                ),
                                const Divider(),
                                _infoRow(
                                  'Status',
                                  (state.paymentStatus ?? 'pending').toUpperCase(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (state.paymentStatus == 'pending')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                if (state.orderId != null) {
                                  context.read<CheckoutBloc>().add(
                                        CheckPaymentStatusEvent(state.orderId!),
                                      );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.black),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cek Status Pembayaran'),
                            ),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Clear cart and reset checkout
                              context.read<CartBloc>().add(ClearCart());
                              context.read<CheckoutBloc>().add(ResetCheckoutEvent());
                              context.goNamed('home');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Kembali ke Home'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(String? status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'settlement':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'pending':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case 'expire':
      case 'cancel':
      case 'deny':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Icon(icon, size: 80, color: color);
  }

  String _getStatusTitle(String? status) {
    switch (status) {
      case 'settlement':
        return 'Pembayaran Berhasil!';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'expire':
        return 'Pembayaran Expired';
      case 'cancel':
        return 'Pembayaran Dibatalkan';
      case 'deny':
        return 'Pembayaran Ditolak';
      default:
        return 'Status Pembayaran';
    }
  }

  String _getStatusMessage(String? status) {
    switch (status) {
      case 'settlement':
        return 'Terima kasih! Pesanan Anda sedang diproses.';
      case 'pending':
        return 'Silakan selesaikan pembayaran sesuai instruksi yang diberikan.';
      case 'expire':
        return 'Waktu pembayaran telah habis. Silakan buat pesanan baru.';
      case 'cancel':
        return 'Pembayaran telah dibatalkan.';
      case 'deny':
        return 'Pembayaran ditolak. Silakan coba metode lain.';
      default:
        return '';
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
