import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/ai_provider.dart';

class AiScanScreen extends ConsumerStatefulWidget {
  const AiScanScreen({super.key});

  @override
  ConsumerState<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends ConsumerState<AiScanScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin kamera diperlukan. Silakan aktifkan di Settings.')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _controller!.value.isTakingPicture) return;

    try {
      // CameraController's takePicture saves at the set resolution preset (high = 720p).
      // This is generally safe enough (< 1MB).
      final XFile image = await _controller!.takePicture();
      setState(() {
        _imageFile = File(image.path);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil gambar')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil gambar dari galeri')),
        );
      }
    }
  }

  void _submit(File image) {
    ref.read(aiParseProvider.notifier).parseImage(image);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AiParseState>(aiParseProvider, (previous, next) {
      next.whenOrNull(
        success: (data) {
          if ((data.confidence ?? 0) < 0.5) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hasil mungkin kurang akurat, periksa kembali')),
            );
          }
          Navigator.pop(context, {'data': data, 'image': _imageFile});
        },
        error: (message, isRetryable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              action: isRetryable && _imageFile != null ? SnackBarAction(label: 'Coba Lagi', onPressed: () => _submit(_imageFile!)) : null,
            ),
          );
        },
      );
    });

    final aiState = ref.watch(aiParseProvider);
    final isLoading = aiState.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Struk'),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_imageFile != null)
                    Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                  else if (_isCameraInitialized && _controller != null)
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CameraPreview(_controller!),
                    )
                  else
                    const Center(child: CircularProgressIndicator()),

                  if (_imageFile == null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withAlpha(128), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(40),
                    ),

                  if (isLoading)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('AI sedang menganalisis...', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.black,
              child: Column(
                children: [
                  if (_imageFile == null)
                    const Text('Pastikan seluruh struk terlihat dan pencahayaan cukup', style: TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  if (_imageFile == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                              onPressed: _pickFromGallery,
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (!isLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _imageFile = null),
                          child: const Text('Foto Ulang', style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () => _submit(_imageFile!),
                          child: const Text('Gunakan Foto'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
