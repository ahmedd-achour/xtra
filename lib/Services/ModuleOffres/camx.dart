import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mouvi_map_application/Services/ModuleOffres/capposition.dart';
import 'package:mouvi_map_application/Services/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final List<String> _tags = ["# Actualitée", "# DUO"];
  Set<String> _selectedTags = {"# Actualitée"};
  String address = "";
  String addressDuo = "";
  bool _isLocationExpanded = false;

  @override
  void initState() {
    super.initState();
    getAddress();
    getAddressDuo();
  }

  Future<void> getAddress() async {
    if (pointsPicked.isNotEmpty) {
      String result = await getAddressFromLatLng(pointsPicked);

      setState(() {
        address = result;
      });
    } else {
      setState(() {
        address = "";
      });
    }
  }

  Future<void> getAddressDuo() async {
    if (duoPics.isNotEmpty) {
      String result = addressDuo = await getAddressFromLatLng(duoPics);
      setState(() {
        addressDuo = result;
      });
    } else {
      setState(() {
        address = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagePlaceholder(),
                        const SizedBox(height: 20),
                        _buildTitleInput(),
                        const SizedBox(height: 10),
                        _buildDescriptionHint(),
                        const SizedBox(height: 20),
                        _buildDiscriptionInput(),
                        const SizedBox(height: 20),
                        _buildTags(),
                        const SizedBox(height: 20),
                        _buildOption(Icons.link, "Add link"),
                        _buildLocationSelector(),
                        if (pointsPicked.isNotEmpty && address.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildLocationDetails(false),
                        ],
                        if (_selectedTags.contains(_tags[1]))
                          _buildDuoLocation(),
                        if (pointsPicked.isNotEmpty &&
                            address.isNotEmpty &&
                            _selectedTags.contains(_tags[1])) ...[
                          const SizedBox(height: 10),
                          _buildLocationDetails(true),
                        ],
                        _buildOption(Icons.more_horiz, "more options"),
                        const SizedBox(height: 20),
                        const Text("share to",
                            style: TextStyle(
                                color: Color.fromARGB(255, 212, 203, 203))),
                        const SizedBox(height: 10),
                        const Spacer(),
                        _buildBottomButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  Future<void> _pickImagesFromGallery() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);

      if (pickedFiles.isNotEmpty) {
        if (pickedFiles.length + selectedImages.length > 10) {
          final allowed = 10 - selectedImages.length;
          selectedImages.addAll(pickedFiles.take(allowed));
        } else {
          selectedImages.addAll(pickedFiles);
        }

        setState(() {});
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<void> _takePhotoWithCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      try {
        final pickedFile = await _picker.pickImage(
            source: ImageSource.camera, imageQuality: 80);

        if (pickedFile != null) {
          if (selectedImages.length < 10) {
            selectedImages.add(pickedFile);
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Max 10 photos allowed.")),
            );
          }
        }
      } catch (e) {
        print("Camera error: $e");
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Camera permission denied")));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _takePhotoWithCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length < 10
            ? selectedImages.length + 1 // extra slot for add button
            : selectedImages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == selectedImages.length && selectedImages.length < 10) {
            return GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_a_photo, color: Colors.black54),
              ),
            );
          }

          final file = selectedImages[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(file.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImages.removeAt(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child:
                        const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _pickImageFromGallery() {
    // TODO: Implement using ImagePicker or similar
    print("Picked from gallery");
  }

  void _takePhoto() {
    // TODO: Implement using ImagePicker or similar
    print("Taken with camera");
  }

  List<XFile> _selectedImages = [];

  Widget _buildTitleInput() {
    return TextField(
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        hintText: "Add a catchy title",
        hintStyle: TextStyle(color: Colors.black),
        border: UnderlineInputBorder(),
      ),
    );
  }

  Widget _buildDiscriptionInput() {
    return TextField(
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        hintText: "Add a Discription",
        hintStyle: TextStyle(color: Colors.black),
        border: UnderlineInputBorder(),
      ),
    );
  }

  Widget _buildDescriptionHint() {
    return const Text(
      "Writing a long description can help 3x more\nviews on average",
      style: TextStyle(color: Colors.black45),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tags.map((tag) => _buildTag(tag)).toList(),
    );
  }

  Widget _buildTag(String text) {
    final bool isSelected = _selectedTags.contains(text);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(text);
          } else {
            _selectedTags = {};
            _selectedTags.add(text);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, {bool isExpanded = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.arrow_forward_ios,
            size: 16,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CapPosition(
            isDuo: false,
          ),
        ));
        // After coming back, refresh addresses
        getAddress();
      },
      child: _buildOption(Icons.location_on_outlined, "Add your location",
          isExpanded: _isLocationExpanded),
    );
  }

  Widget _buildDuoLocation() {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CapPosition(
            isDuo: true,
          ),
        ));
        // After coming back, refresh addresses
        getAddressDuo();
      },
      child: _buildOption(Icons.location_on_outlined, "Add the second Location",
          isExpanded: _isLocationExpanded),
    );
  }

  Widget _buildLocationDetails(bool isDuo) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 100,
              width: 100,
              child: Image.asset("assets/image.png", fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDuo
                      ? (addressDuo.isNotEmpty
                          ? addressDuo
                          : "No address found")
                      : (address.isNotEmpty ? address : "No address found"),
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("draft", style: TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Deposer", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
