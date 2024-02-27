// // ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, prefer_final_fields

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';

// class EditEmployee extends StatefulWidget {
//   final String documentId;

//   const EditEmployee({Key? key, required this.documentId}) : super(key: key);

//   @override
//   State<EditEmployee> createState() => _EditEmployeeState();
// }

// class _EditEmployeeState extends State<EditEmployee> {
//   final ImagePicker _picker = ImagePicker();
//   XFile? _image;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _designationController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _numberController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   String? _existingImageUrl;
//   String? _selectedGender;
//   List<String> _genders = ['Male', 'Female', 'Other'];

//   @override
//   void initState() {
//     super.initState();
//     fetchEmployeeDetails();
//   }

//   Future<void> fetchEmployeeDetails() async {
//     try {
//       DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
//           .instance
//           .collection("employees")
//           .doc(widget.documentId)
//           .get();

//       setState(() {
//         _nameController.text = snapshot.data()?["name"] ?? "";
//         _designationController.text = snapshot.data()?["designation"] ?? "";
//         _emailController.text = snapshot.data()?["email"] ?? "";
//         _numberController.text = snapshot.data()?["phone_number"] ?? "";
//         _addressController.text = snapshot.data()?["address"] ?? "";
//         _selectedGender = snapshot.data()?["gender"] ?? "";
//         _existingImageUrl = snapshot.data()?["image_url"];
//       });
//     } catch (e) {
//       print("Error fetching employee details: $e");
//     }
//   }

//   Future<void> _selectImage() async {
//     try {
//       final XFile? pickedImage =
//           await _picker.pickImage(source: ImageSource.gallery);

//       if (pickedImage != null) {
//         setState(() {
//           _image = pickedImage;
//         });
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//     }
//   }

//   Future<void> updateEmployeeDetails() async {
//     final String name = _nameController.text.trim();
//     final String designation = _designationController.text.trim();
//     final String email = _emailController.text.trim();
//     final String phoneNumber = _numberController.text.trim();
//     final String address = _addressController.text.trim();

//     if (name.isEmpty ||
//         designation.isEmpty ||
//         email.isEmpty ||
//         phoneNumber.isEmpty ||
//         address.isEmpty ||
//         _selectedGender == null) {
//       return;
//     }

//     String? imageUrl = _existingImageUrl;

//     if (_image != null) {
//       // Upload image logic here
//     }

//     await FirebaseFirestore.instance
//         .collection("employees")
//         .doc(widget.documentId)
//         .update({
//       "name": name,
//       "designation": designation,
//       "email": email,
//       "phone_number": phoneNumber,
//       "address": address,
//       "image_url": imageUrl,
//       "gender": _selectedGender,
//     });

//     _nameController.clear();
//     _designationController.clear();
//     _emailController.clear();
//     _numberController.clear();
//     _addressController.clear();

//     Navigator.of(context).pop();
//     Fluttertoast.showToast(msg: 'Update employee successful');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.amber,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Stack(
//                     children: [
//                       Center(
//                         child: GestureDetector(
//                           onTap: _selectImage,
//                           child: _image != null
//                               ? CircleAvatar(
//                                   radius: 50,
//                                   backgroundImage: FileImage(
//                                     File(_image!.path),
//                                   ),
//                                 )
//                               : _existingImageUrl != null
//                                   ? CircleAvatar(
//                                       radius: 50,
//                                       backgroundImage:
//                                           NetworkImage(_existingImageUrl!),
//                                     )
//                                   : const CircleAvatar(
//                                       radius: 50,
//                                       child: Icon(Icons.person),
//                                     ),
//                         ),
//                       ),
//                       if (_image != null || _existingImageUrl != null)
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _image = null;
//                                 _existingImageUrl = null;
//                               });
//                             },
//                             child: CircleAvatar(
//                               backgroundColor: Colors.red,
//                               radius: 14,
//                               child: Icon(
//                                 Icons.close,
//                                 size: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Employee Name',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Gender',
//                   ),
//                   value: _selectedGender,
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedGender = newValue;
//                     });
//                   },
//                   items: _genders.map((String gender) {
//                     return DropdownMenuItem<String>(
//                       value: gender,
//                       child: Text(gender),
//                     );
//                   }).toList(),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select gender';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               // Other fields go here...
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       updateEmployeeDetails();
//                     }
//                   },
//                   style: ButtonStyle(
//                     minimumSize: MaterialStateProperty.all(
//                       const Size(double.infinity, 50),
//                     ),
//                     backgroundColor: MaterialStateProperty.all(Colors.amber),
//                   ),
//                   child: const Text(
//                     "Update Employee",
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
