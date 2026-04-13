import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:module_core/widget/animation/slider_animation.dart';
import 'package:module_core/widget/textfield/textfield_normal.dart';
import 'package:module_core/widget/textfield/textfield_long.dart';
import 'package:module_core/widget/textfield/textfield_dropdown.dart';
import 'package:module_user/presentation/bloc/cart_bloc.dart';
import 'package:module_user/presentation/bloc/checkout_bloc.dart';
import 'package:module_user/presentation/widget/progress_checkout.dart';
import 'package:module_user/domain/constants/payment_constants.dart';
import 'package:module_user/presentation/pages/checkout/midtrans_snap_page.dart';
import 'package:module_user/presentation/pages/checkout/payment_result_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CheckoutView();
  }
}

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  PaymentMethod _selectedPayment = PaymentMethod.paypal;

  @override
  void initState() {
    super.initState();
    // Gunakan post frame callback untuk menghindari masalah context bloc saat init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CheckoutBloc>().add(ResetCheckoutEvent());
        _emailCtrl.clear();
        _nameCtrl.clear();
        _phoneCtrl.clear();
        _cityCtrl.clear();
        _postalCtrl.clear();
        _addressCtrl.clear();
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.change_history, size: 24, color: Colors.black),
            const SizedBox(width: 8),
            const Text(
              'voc.archive',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                color: Colors.white,
                child: ProgressCheckout(currentStep: state.step),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _buildCurrentStepView(context, state),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStepView(BuildContext context, CheckoutState state) {
    Widget child;
    switch (state.step) {
      case 0:
        child = _buildPersonalData(context);
        break;
      case 1:
        child = _buildShippingData(context, state);
        break;
      case 2:
        child = _buildPayment(context);
        break;
      default:
        child = const SizedBox.shrink();
    }

    return SliderAnimation(
      key: ValueKey(state.step),
      direction: SlideDirection.up,
      offset: 0.1,
      duration: const Duration(milliseconds: 400),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: Padding(padding: const EdgeInsets.all(24.0), child: child),
      ),
    );
  }

  Widget _buildPersonalData(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Data',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextfieldNormal(
          controller: _emailCtrl,
          hintText: 'Email',
          suffixIcon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextfieldNormal(
          controller: _nameCtrl,
          hintText: 'Full Name',
          suffixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        TextfieldNormal(
          controller: _phoneCtrl,
          hintText: 'Phone',
          suffixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_emailCtrl.text.trim().isEmpty || 
                      _nameCtrl.text.trim().isEmpty || 
                      _phoneCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap lengkapi semua Personal Data.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  context.read<CheckoutBloc>().add(NextStepEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShippingData(BuildContext context, CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Data',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        if (state.isLoadingRates)
          const Center(child: CircularProgressIndicator(color: Colors.black))
        else if (state.ratesError != null)
          Text(
            'Error: ${state.ratesError}',
            style: const TextStyle(color: Colors.red),
          )
        else
          TextfieldDropdown<Map<String, dynamic>>(
            hintText: 'Choose where you want it delivered',
            value: state.selectedShippingRate,
            onTap: () {
              if (state.shippingRates.isEmpty) {
                context.read<CheckoutBloc>().add(LoadShippingRatesEvent());
              }
            },
            items: state.shippingRates.map((rate) {
              Logger().d(state.shippingRates.first);
              return DropdownMenuItem<Map<String, dynamic>>(
                value: rate,
                child: Text(
                  '${rate['nama_area'] ?? ''} - \$ ${rate['harga'] ?? 0} ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (val) {
              context.read<CheckoutBloc>().add(UpdateShippingRateEvent(val));
            },
          ),
        const SizedBox(height: 16),
        TextfieldNormal(controller: _cityCtrl, hintText: 'City'),
        const SizedBox(height: 16),
        TextfieldNormal(
          controller: _postalCtrl,
          hintText: 'Postal Code',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextfieldLong(
          controller: _addressCtrl,
          hintText: 'Address',
          maxLines: 5,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<CheckoutBloc>().add(PreviousStepEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_cityCtrl.text.trim().isEmpty ||
                      _postalCtrl.text.trim().isEmpty ||
                      _addressCtrl.text.trim().isEmpty ||
                      context.read<CheckoutBloc>().state.selectedShippingRate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select shipping and fill in all data.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  context.read<CheckoutBloc>().add(NextStepEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Text('Detail Item', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            return Column(
              children: [
                ...cartState.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} (${item.selectedSize}) x${item.quantity}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
        const Divider(color: Colors.black),
        const SizedBox(height: 16),
        const Text('Shipping', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            final rate = state.selectedShippingRate;
            final cost = rate != null ? rate['harga'] ?? 0 : 0;
            final area = rate != null
                ? rate['nama_area'] ?? 'Unknown Area'
                : 'No Shipping Selected';
            if (rate == null) {
              return const Text(
                'No shipping method selected',
                style: TextStyle(fontSize: 14, color: Colors.red),
              );
            }
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _addressCtrl.text.isNotEmpty
                            ? '$area, ${_cityCtrl.text}, ${_postalCtrl.text}, ${_addressCtrl.text}'
                            : 'Address not provided',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$ ${cost.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.black),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const Text('Total', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            final rate = state.selectedShippingRate;
            final shippingCost = (rate != null ? rate['harga'] ?? 0 : 0) as num;
            final cartTotal = context.read<CartBloc>().state.totalPrice;
            final total = cartTotal + shippingCost;
            return Column(
              children: [
                Center(
                  child: Text(
                    '\$ ${total.toStringAsFixed(2)} USD',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.black),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        StatefulBuilder(
          builder: (context, setState) {
            return TextfieldDropdown<PaymentMethod>(
              hintText: 'Method',
              value: _selectedPayment,
              items: PaymentMethod.values.map((method) {
                return DropdownMenuItem<PaymentMethod>(
                  value: method,
                  child: Text(method.label),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPayment = val;
                  });
                }
              },
            );
          },
        ),
        const SizedBox(height: 32),
        BlocConsumer<CheckoutBloc, CheckoutState>(
          listener: (context, state) async {
            if (state.redirectUrl != null &&
                state.orderId != null &&
                !state.isProcessingPayment) {
              // Open Snap WebView
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CheckoutBloc>(),
                    child: MidtransSnapPage(
                      redirectUrl: state.redirectUrl!,
                      orderId: state.orderId!,
                    ),
                  ),
                ),
              );
              Logger().d('Snap WebView result: $result');
              // Navigate to result page
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: context.read<CheckoutBloc>()),
                        BlocProvider.value(value: context.read<CartBloc>()),
                      ],
                      child: const PaymentResultPage(),
                    ),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            final isProcessing = state.isProcessingPayment;
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () {
                            context.read<CheckoutBloc>().add(PreviousStepEvent());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () => _handlePay(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Pay', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            );
          },
        ),
        BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            if (state.paymentError != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.paymentError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _handlePay(BuildContext context) {
    final checkoutState = context.read<CheckoutBloc>().state;

    if (_selectedPayment == PaymentMethod.other) {
      // Midtrans payment
      if (checkoutState.selectedShippingRate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih shipping area terlebih dahulu')),
        );
        return;
      }

      final cartItems = context.read<CartBloc>().state.items;
      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart kosong')),
        );
        return;
      }

      final shippingArea =
          checkoutState.selectedShippingRate!['nama_area'] as String? ?? '';

      final items = cartItems
          .map((item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
                'size': item.selectedSize,
              })
          .toList();

      context.read<CheckoutBloc>().add(
            ProcessMidtransPaymentEvent(
              items: items,
              shippingArea: shippingArea,
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              city: _cityCtrl.text.trim(),
              postalCode: _postalCtrl.text.trim(),
              address: _addressCtrl.text.trim(),
            ),
          );
    } else {
      // PayPal — placeholder for future
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PayPal payment coming soon')),
      );
    }
  }
}
