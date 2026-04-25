import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cubit/aboutus_cubit.dart';

class AdminAboutUsPage extends StatefulWidget {
  const AdminAboutUsPage({super.key});

  @override
  State<AdminAboutUsPage> createState() => _AdminAboutUsPageState();
}

class _AdminAboutUsPageState extends State<AdminAboutUsPage> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _bodyTitleCtrl = TextEditingController();
  final _bodyTextCtrl = TextEditingController();

  String? _heroBase64;
  String? _existingHeroUrl;

  final List<String> _newGalleryBase64 = [];
  List<String> _keepGalleryUrls = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<AboutUsCubit>().loadAboutUs();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _locationCtrl.dispose();
    _bodyTitleCtrl.dispose();
    _bodyTextCtrl.dispose();
    super.dispose();
  }

  void _populateForm(AboutUsLoaded state) {
    _titleCtrl.text = state.title;
    _subtitleCtrl.text = state.subtitle;
    _locationCtrl.text = state.location;
    _bodyTitleCtrl.text = state.bodyTitle;
    _bodyTextCtrl.text = state.bodyText;
    _existingHeroUrl = state.heroImage;
    _keepGalleryUrls = List.from(state.galleryImages);
    _newGalleryBase64.clear();
  }

  Future<void> _pickHeroImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hero image max 5 MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      setState(() {
        _heroBase64 = base64Encode(bytes);
        _existingHeroUrl = null;
      });
    }
  }

  Future<void> _pickGalleryImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (var img in images) {
        final bytes = await img.readAsBytes();
        if (bytes.lengthInBytes > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${img.name} melebihi 5 MB, dilewati'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          continue;
        }
        setState(() {
          _newGalleryBase64.add(base64Encode(bytes));
        });
      }
    }
  }

  void _removeGalleryUrl(int index) {
    setState(() {
      _keepGalleryUrls.removeAt(index);
    });
  }

  void _removeNewGallery(int index) {
    setState(() {
      _newGalleryBase64.removeAt(index);
    });
  }

  void _save() {
    context.read<AboutUsCubit>().saveAboutUs(
          heroImageBase64: _heroBase64,
          title: _titleCtrl.text.trim(),
          subtitle: _subtitleCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          bodyTitle: _bodyTitleCtrl.text.trim(),
          bodyText: _bodyTextCtrl.text.trim(),
          galleryImagesBase64:
              _newGalleryBase64.isNotEmpty ? _newGalleryBase64 : null,
          keepGalleryImages: _keepGalleryUrls,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AboutUsCubit, AboutUsState>(
        listener: (context, state) {
          if (state is AboutUsLoaded) {
            _populateForm(state);
          }
          if (state is AboutUsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('About Us berhasil disimpan!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is AboutUsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AboutUsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (state is AboutUsSaving) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text(
                    'Menyimpan perubahan...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About Us Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ========== HERO IMAGE ==========
                    _sectionTitle('Hero Image'),
                    const SizedBox(height: 12),
                    _buildHeroImagePicker(),
                    const SizedBox(height: 32),

                    // ========== TEXT FIELDS ==========
                    _sectionTitle('Teks Header'),
                    const SizedBox(height: 12),
                    _buildTextField(_titleCtrl, 'Title (contoh: About Us)'),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _subtitleCtrl, 'Subtitle (contoh: voc.archive)'),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _locationCtrl, 'Location (contoh: BASED IN INDONESIA)'),
                    const SizedBox(height: 32),

                    _sectionTitle('Teks Body'),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _bodyTitleCtrl, 'Body Title (contoh: voc.archive)'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _bodyTextCtrl,
                      'Body Text (kebijakan toko, deskripsi, dll)',
                      maxLines: 8,
                    ),
                    const SizedBox(height: 32),

                    // ========== GALLERY IMAGES ==========
                    _sectionTitle('Gallery Images'),
                    const SizedBox(height: 12),
                    _buildGallerySection(),
                    const SizedBox(height: 40),

                    // ========== SAVE BUTTON ==========
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildHeroImagePicker() {
    return Column(
      children: [
        if (_heroBase64 != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(_heroBase64!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else if (_existingHeroUrl != null && _existingHeroUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: _existingHeroUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.broken_image, size: 48)),
              ),
            ),
          )
        else
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickHeroImage,
            icon: const Icon(Icons.upload, color: Colors.black),
            label: const Text(
              'Pilih Hero Image',
              style: TextStyle(color: Colors.black),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    final allItems = <Widget>[];

    // Existing gallery images (kept)
    for (int i = 0; i < _keepGalleryUrls.length; i++) {
      allItems.add(_buildGalleryTile(
        child: CachedNetworkImage(
          imageUrl: _keepGalleryUrls[i],
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
        ),
        onRemove: () => _removeGalleryUrl(i),
      ));
    }

    // New gallery images (base64)
    for (int i = 0; i < _newGalleryBase64.length; i++) {
      allItems.add(_buildGalleryTile(
        child: Image.memory(
          base64Decode(_newGalleryBase64[i]),
          fit: BoxFit.cover,
        ),
        onRemove: () => _removeNewGallery(i),
      ));
    }

    // Add button
    allItems.add(
      InkWell(
        onTap: _pickGalleryImages,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
                SizedBox(height: 4),
                Text('Tambah', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: allItems,
    );
  }

  Widget _buildGalleryTile({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
