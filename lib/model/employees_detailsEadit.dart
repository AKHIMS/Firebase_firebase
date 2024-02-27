// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_final_fields, file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditEmployee extends StatefulWidget {
  final String documentId;

  const EditEmployee({Key? key, required this.documentId}) : super(key: key);

  @override
  State<EditEmployee> createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _existingImageUrl;
  String? _selectedGender;
  List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetails();
  }

  Future<void> fetchEmployeeDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection("employees")
          .doc(widget.documentId)
          .get();

      setState(() {
        _nameController.text = snapshot.data()?["name"] ?? "";
        _designationController.text = snapshot.data()?["designation"] ?? "";
        _emailController.text = snapshot.data()?["email"] ?? "";
        _numberController.text = snapshot.data()?["phone_number"] ?? "";
        _addressController.text = snapshot.data()?["address"] ?? "";
        _selectedGender = snapshot.data()?["gender"] ?? "";
        _existingImageUrl = snapshot.data()?["image_url"];
      });
    } catch (e) {
      print("Error fetching employee details: $e");
    }
  }

  Future<void> _selectImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> updateEmployeeDetails() async {
    final String name = _nameController.text.trim();
    final String designation = _designationController.text.trim();
    final String email = _emailController.text.trim();
    final String phoneNumber = _numberController.text.trim();
    final String address = _addressController.text.trim();

    if (name.isEmpty ||
        designation.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        address.isEmpty ||
        _selectedGender == null) {
      return;
    }

    String? imageUrl = _existingImageUrl;

    if (_image != null) {
      // Upload image logic here
    }

    await FirebaseFirestore.instance
        .collection("employees")
        .doc(widget.documentId)
        .update({
      "name": name,
      "designation": designation,
      "email": email,
      "phone_number": phoneNumber,
      "address": address,
      "image_url": imageUrl,
      "gender": _selectedGender,
    });

    _nameController.clear();
    _designationController.clear();
    _emailController.clear();
    _numberController.clear();
    _addressController.clear();

    Navigator.of(context).pop();
    Fluttertoast.showToast(msg: 'Update employee successful');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexstringToColor("CB2B93"),
                hexstringToColor("9546c4"),
                hexstringToColor("5e61f4"),
              ],
            ),
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _selectImage,
                        child: _image != null
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: FileImage(
                                  File(_image!.path),
                                ),
                              )
                            : _existingImageUrl != null
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        NetworkImage(_existingImageUrl!),
                                  )
                                : const CircleAvatar(
                                    radius: 50,
                                    child: Icon(Icons.person),
                                  ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Confirm Deletion',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                          'Are you sure you want to delete the image?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _image = null;
                              _existingImageUrl = null;
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'Delete Image',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Employee Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Gender',
                ),
                value: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Designation',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter designation';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  } else if (!value.toLowerCase().endsWith('.com')) {
                    return 'Email should end with .com';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: _numberController,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone_Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone_number';
                  } else if (value.length != 10) {
                    return 'Phone_number must be 10 digits';
                  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only numeric values are allowed';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _addressController,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Address',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateEmployeeDetails();
                  }
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(double.infinity, 50),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                child: const Text(
                  "Update Employee",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Color hexstringToColor(String hexString) {
    return Color(int.parse(hexString.substring(0, 6), radix: 16) + 0xFF000000);
  }
}
