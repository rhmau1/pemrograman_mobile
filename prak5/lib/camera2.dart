// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

const Color themeColor = Color(0xff00bc56);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeChat Camera Picker Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CameraPickerHomePage(),
    );
  }
}

class CameraPickerHomePage extends StatefulWidget {
  const CameraPickerHomePage({super.key});

  @override
  State<CameraPickerHomePage> createState() => _CameraPickerHomePageState();
}

class _CameraPickerHomePageState extends State<CameraPickerHomePage> {
  AssetEntity? _pickedAsset;

  Future<void> _openCamera() async {
    final AssetEntity? entity = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: const CameraPickerConfig(
        enableRecording: true,
        textDelegate: EnglishCameraPickerTextDelegate(),
      ),
    );
    if (entity != null) {
      setState(() {
        _pickedAsset = entity;
      });
    }
  }

  Future<void> _openAssetsPicker() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        maxAssets: 1,
        textDelegate: EnglishAssetPickerTextDelegate(),
      ),
    );
    if (assets != null && assets.isNotEmpty) {
      setState(() {
        _pickedAsset = assets.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera & Asset Picker'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_pickedAsset != null) ...[
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image(
                    image: AssetEntityImageProvider(
                      _pickedAsset!,
                      isOriginal: false,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Asset Type: ${_pickedAsset!.type}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Size: ${_pickedAsset!.width} x ${_pickedAsset!.height}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
              ] else ...[
                Icon(
                  Icons.camera_alt_outlined,
                  size: 100,
                  color: themeColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No media selected',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton.icon(
                onPressed: _openCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.camera),
                label: const Text('Take Photo / Video'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openAssetsPicker,
                style: OutlinedButton.styleFrom(
                  foregroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
