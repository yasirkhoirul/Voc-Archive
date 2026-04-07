import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:module_admin/domain/entities/create_slider_input.dart';
import 'package:module_admin/presentations/bloc/slider_mutation_bloc.dart';

class AdminSliderPage extends StatefulWidget {
  const AdminSliderPage({super.key});

  @override
  State<AdminSliderPage> createState() => _AdminSliderPageState();
}

class _AdminSliderPageState extends State<AdminSliderPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _deleteIdController = TextEditingController();
  String? _base64Image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SliderMutationBloc, SliderMutationState>(
      listener: (context, state) {
        if (state is SliderMutationSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Success!')));
          _judulController.clear();
          _deskripsiController.clear();
          _deleteIdController.clear();
          setState(() {
            _base64Image = null;
          });
        } else if (state is SliderMutationError) {
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
              Text('Tambah Slider', style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),
              if (_base64Image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.memory(
                    base64Decode(_base64Image!),
                    height: 150,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _base64Image != null) {
                    context.read<SliderMutationBloc>().add(
                          CreateSliderSubmitted(
                            CreateSliderInput(
                              judul: _judulController.text,
                              deskripsi: _deskripsiController.text,
                              gambarBase64: _base64Image!,
                            ),
                          ),
                        );
                  } else if (_base64Image == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih gambar!')));
                  }
                },
                child: const Text('Simpan Slider'),
              ),
              const Divider(height: 48),
              Text('Daftar Slider Saat Ini', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('sliders').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Text('Belum ada slider yang ditambahkan.');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final uid = data['uid'] ?? docs[index].id;
                      return Card(
                        child: ListTile(
                          leading: data['gambar'] != null
                              ? Image.network(
                                  data['gambar'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.image),
                          title: Text(data['judul'] ?? 'Tanpa Judul'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['deskripsi'] ?? ''),
                              SelectableText('UID: $uid',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy, color: Colors.blue),
                            tooltip: 'Gunakan UID ini untuk dihapus',
                            onPressed: () {
                              _deleteIdController.text = uid;
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const Divider(height: 48),
              Text('Hapus Slider', style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                controller: _deleteIdController,
                decoration: const InputDecoration(labelText: 'UID Slider'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  if (_deleteIdController.text.isNotEmpty) {
                    context
                        .read<SliderMutationBloc>()
                        .add(DeleteSliderSubmitted(_deleteIdController.text));
                  }
                },
                child: const Text('Hapus Slider', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
