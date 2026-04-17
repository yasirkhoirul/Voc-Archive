import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../utils/app_assets.dart';

class VocLogo extends StatefulWidget {
  final double imageWidth;
  final double imageHeight;
  final String title;
  final double? fontSize;
  final FontWeight fontWeight;

  const VocLogo({
    super.key,
    this.imageWidth = 40.0,
    this.imageHeight = 40.0,
    this.title = 'voc.archive',
    this.fontSize,
    this.fontWeight = FontWeight.bold,
  });

  @override
  State<VocLogo> createState() => _VocLogoState();
}

class _VocLogoState extends State<VocLogo> {
  late Future<String> _logoUrlFuture;

  @override
  void initState() {
    super.initState();
    _logoUrlFuture = getLogoUrl();
  }

  Future<String> getLogoUrl() async {
    // Referensi ke file di root storage
    Reference ref = FirebaseStorage.instance.ref().child('logovoc.png');
    
    // Dapatkan link URL-nya
    String url = await ref.getDownloadURL();
    return url;
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FutureBuilder<String>(
            future: _logoUrlFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  width: widget.imageWidth,
                  height: widget.imageHeight,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                // Fallback jika gagal load
                return Icon(
                  Icons.home_filled,
                  size: widget.imageWidth,
                );
              }
              
              return Image.network(
                snapshot.data!,
                width: widget.imageWidth,
                height: widget.imageHeight,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: widget.fontWeight,
                fontSize: widget.fontSize,
              ),
        ),
      ],
    );
  }
}
