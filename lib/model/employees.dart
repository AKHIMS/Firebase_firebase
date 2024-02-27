// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/edit_employe.dart';
import 'package:flutter_application_1/model/employees_detailsEadit.dart';
import 'package:flutter_application_1/view/colour.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Employees extends StatefulWidget {
  final String documentId;

  const Employees({Key? key, required this.documentId}) : super(key: key);

  @override
  State<Employees> createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  String? _existingImageUrl;
  String? _selectedGender;
  Map<String, dynamic> _employeeData = {};

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetails();
    fetchExistingImage();
  }

  Future<void> fetchEmployeeDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection("employees")
          .doc(widget.documentId)
          .get();

      setState(() {
        _employeeData = snapshot.data() ?? {};
        _selectedGender = _employeeData["gender"] ?? "";
      });
    } catch (e) {
      print("Error fetching employee details: $e");
    }
  }

  Future<void> fetchExistingImage() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection("employees")
          .doc(widget.documentId)
          .get();

      setState(() {
        _existingImageUrl = snapshot.data()?["image_url"];
      });
    } catch (e) {
      print("Error fetching existing image: $e");
    }
  }

  // Function to update employee details
  Future<void> updateEmployeeDetails() async {
    // Implement update logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexstringTocolor("CB2B93"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirm Edit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text('Do you want to edit this employee?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditEmployee(documentId: widget.documentId),
                            ),
                          );
                        },
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexstringTocolor("CB2B93"),
                hexstringTocolor("9546c4"),
                hexstringTocolor("5e61f4"),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
              child: GestureDetector(
                onTap: () {
                  if (_existingImageUrl != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(_existingImageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _existingImageUrl != null
                          ? NetworkImage(_existingImageUrl!)
                          : null,
                      child: _existingImageUrl == null
                          ? const Icon(Icons.person, size: 70)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 20),
              buildDetailItem("Employee Name", _employeeData["name"] ?? ""),
              buildDetailItem("Gender", _selectedGender ?? ""),
              buildDetailItem(
                  "Designation", _employeeData["designation"] ?? ""),
              buildDetailItem("Email", _employeeData["email"] ?? ""),
              buildDetailItem(
                  "Phone_Number", _employeeData["phone_number"] ?? ""),
              buildDetailItem("Address", _employeeData["address"] ?? ""),
             
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Go to Home Screen',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('employees')
                            .doc(widget.documentId)
                            .delete();

                        Navigator.pop(context); // Close the current screen
                        Navigator.popUntil(
                            context, ModalRoute.withName('/')); // Navigate back to the home screen

                        Fluttertoast.showToast(
                          msg: 'Employee deleted successfully',
                        );
                      } catch (e) {
                        print("Error deleting employee: $e");
                      }
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 3,
        child: ListTile(
          title: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(value),
        ),
      ),
    );
  }
}
