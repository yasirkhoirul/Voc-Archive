import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/widget/snackbar.dart';
import '../bloc/brand_bloc.dart';

class AdminBrandPage extends StatefulWidget {
  const AdminBrandPage({super.key});

  @override
  State<AdminBrandPage> createState() => _AdminBrandPageState();
}

class _AdminBrandPageState extends State<AdminBrandPage> {
  @override
  void initState() {
    super.initState();
    context.read<BrandBloc>().add(LoadBrands());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Brand')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBrandDialog(),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<BrandBloc, BrandState>(
        listener: (context, state) {
          if (state.status == BrandStatus.mutationSuccess) {
            AppSnackbar.onSuccess(
              context,
              state.successMessage ?? 'Berhasil',
            );
          }
          if (state.status == BrandStatus.error) {
            AppSnackbar.onFailure(
              context,
              state.errorMessage ?? 'Terjadi kesalahan',
            );
          }
        },
        builder: (context, state) {
          if (state.status == BrandStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final brands = state.brands;

          if (brands.isEmpty) {
            return const Center(
              child: Text('Belum ada brand. Tambahkan dengan tombol +'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Brand (${brands.length})',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(4),
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      // Header
                      TableRow(
                        decoration:
                            BoxDecoration(color: Colors.grey.shade100),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Nama Brand',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Action',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      // Data rows
                      ...brands.asMap().entries.map((entry) {
                        final index = entry.key;
                        final brand = entry.value;
                        final uid = brand['uid'] as String? ?? '';
                        final nama = brand['nama'] as String? ?? '';

                        return TableRow(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('${index + 1}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(nama),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: state.status ==
                                            BrandStatus.mutating
                                        ? null
                                        : () =>
                                            _confirmDeleteBrand(uid, nama),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: state.status ==
                                            BrandStatus.mutating
                                        ? null
                                        : () => _showUpdateBrandDialog(
                                            uid, nama),
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // Dialogs
  // ==========================================

  void _showAddBrandDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Brand'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Brand',
            hintText: 'Contoh: Nike',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final nama = controller.text.trim();
              if (nama.isNotEmpty) {
                context.read<BrandBloc>().add(CreateBrandSubmitted(nama));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showUpdateBrandDialog(String uid, String currentNama) {
    final controller = TextEditingController(text: currentNama);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Brand'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Brand',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final nama = controller.text.trim();
              if (nama.isNotEmpty) {
                context
                    .read<BrandBloc>()
                    .add(UpdateBrandSubmitted(uid, nama));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBrand(String uid, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Brand'),
        content: Text('Yakin ingin menghapus brand "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BrandBloc>().add(DeleteBrandSubmitted(uid));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
