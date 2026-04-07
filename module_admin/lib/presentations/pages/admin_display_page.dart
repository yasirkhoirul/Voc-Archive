import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_admin/domain/entities/create_display_input.dart';
import 'package:module_admin/presentations/bloc/display_mutation_bloc.dart';

class AdminDisplayPage extends StatefulWidget {
  const AdminDisplayPage({super.key});

  @override
  State<AdminDisplayPage> createState() => _AdminDisplayPageState();
}

class _AdminDisplayPageState extends State<AdminDisplayPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _productIdsController = TextEditingController();
  final _deleteIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<DisplayMutationBloc, DisplayMutationState>(
      listener: (context, state) {
        if (state is DisplayMutationSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Success!')));
          _judulController.clear();
          _productIdsController.clear();
          _deleteIdController.clear();
        } else if (state is DisplayMutationError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tambah Display', style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul Display'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _productIdsController,
                decoration: const InputDecoration(
                    labelText: 'Product IDs (pisahkan koma)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final pIds = _productIdsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList();
                    context.read<DisplayMutationBloc>().add(
                          CreateDisplaySubmitted(
                            CreateDisplayInput(
                              judul: _judulController.text,
                              productId: pIds,
                            ),
                          ),
                        );
                  }
                },
                child: const Text('Simpan Display'),
              ),
              const Divider(height: 48),
              Text('Hapus Display', style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                controller: _deleteIdController,
                decoration: const InputDecoration(labelText: 'UID Display'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  if (_deleteIdController.text.isNotEmpty) {
                    context
                        .read<DisplayMutationBloc>()
                        .add(DeleteDisplaySubmitted(_deleteIdController.text));
                  }
                },
                child: const Text('Hapus Display', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
