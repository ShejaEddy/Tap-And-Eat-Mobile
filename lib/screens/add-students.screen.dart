import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/constants.dart';
import 'package:mobile/widgets/shared/input_widget.dart';
import 'package:mobile/widgets/shared/primary_button.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../widgets/shared/app_drawer.dart';

class AddStudentsScreen extends StatefulWidget {
  const AddStudentsScreen({Key? key}) : super(key: key);

  static const routeName = '/add-students';

  @override
  State<AddStudentsScreen> createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  String text = "";
  String names = "";
  String phoneNumber = "";
  String pin = "";
  String confirmPin = "";
  bool scanned = false;
  bool scan_mode = false;
  bool _isLoading = false;
  final TextEditingController _namesController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _tagRead() {
    result.addListener(() {
      if (scanned) return;

      setState(() {
        scanned = true;
        text = Utils.generateMd5(result.value.toString());
        Utils.showSnackBar(
            title: "Card scanned successfully",
            context: context,
            color: Colors.blue);
      });
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      NfcManager.instance.stopSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Students'),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Asks a user to tap NFC card

              if (!scan_mode && !scanned)
                Container(
                  margin: const EdgeInsets.only(bottom: 20, top: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "Click button below to scan a meal card",
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (scan_mode && !scanned)
                Container(
                    margin: const EdgeInsets.only(bottom: 20, top: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Tap NFC card to validate student!",
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                    )),
              if (scan_mode && scanned)
                Container(
                    margin: const EdgeInsets.only(bottom: 20, top: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 137, 226, 172),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "NFC card scanned!",
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Tap button to scan a new card",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )),
              if ((scan_mode && scanned) || (!scan_mode && !scanned))
                TextButton(
                  onPressed: () {
                    setState(() {
                      scan_mode = true;
                      scanned = false;
                    });
                    _tagRead();
                  },
                  child: const Text(
                    "Scan A New Card",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                ),
              const SizedBox(height: 10),

              /* PrimaryButton(text: "Scan card", onPressed: (){
                _tagRead();
              }),*/
              const SizedBox(height: 10),
              InputWidget(
                  controller: _namesController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please enter names";
                    }
                    return null;
                  },
                  label: "Names",
                  onSaved: (val) {
                    names = val!;
                  }),
              const SizedBox(height: 10),
              InputWidget(
                  controller: _phoneNumberController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please enter phone number";
                    }
                    return null;
                  },
                  label: "Phone Number",
                  inputType: TextInputType.phone,
                  onSaved: (val) {
                    phoneNumber = val!;
                  }),
              const SizedBox(height: 10),
              // InputWidget(
              //     validator: (val) {
              //       if (val!.isEmpty) {
              //         return "Please enter pin";
              //       }
              //       return null;
              //     },
              //     inputType: TextInputType.number,
              //     label: "Pin",
              //     onSaved: (val) {
              //       pin = val!;
              //     }),
              // const SizedBox(height: 10),
              // InputWidget(
              //     validator: (val) {
              //       if (val!.isEmpty) {
              //         return "Please enter pin confirmation";
              //       }
              //       return null;
              //     },
              //     inputType: TextInputType.number,
              //     label: "Confirm Pin",
              //     onSaved: (val) {
              //       confirmPin = val!;
              //     }),
              // const SizedBox(height: 10),
              PrimaryButton(
                text: "Register",
                onPressed: () async {
                  if (_isLoading) return;

                  var ok = _formKey.currentState!.validate();

                  if (!ok) return;

                  Utils.showSnackBar(
                      title: "Loading...",
                      context: context,
                      color: Colors.orange);

                  _formKey.currentState!.save();

                  // if (pin != confirmPin) {
                  //   Utils.showSnackBar(
                  //       title: "Pin and confirm pin do not match",
                  //       context: context,
                  //       color: Colors.red);
                  //   return;
                  // }

                  // check if text is empty
                  if (text.isEmpty) {
                    Utils.showSnackBar(
                        title: "Please scan a student meal card",
                        context: context,
                        color: Colors.red);
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await Dio().post(
                      "${Constants.BASE_URL}/students",
                      data: {
                        "name": names,
                        "phoneNumber": phoneNumber,
                        "pin": "1234",
                        "card": text
                      },
                    );

                    Utils.showSnackBar(
                        title: "Student added successfully",
                        context: context,
                        color: Colors.green);
                    setState(() {
                      scan_mode = false;
                      scanned = false;
                      _isLoading = false;
                      // empty fields
                      names = "";
                      phoneNumber = "";
                      _namesController.clear();
                      _phoneNumberController.clear();
                    });
                  } on DioError catch (e) {
                    if (e.response != null) {
                      if (e.response!.statusCode == 401) {
                        Utils.showSnackBar(
                          title: "Phone number already exists",
                          context: context,
                        );
                      } else if (e.response!.statusCode == 403) {
                        Utils.showSnackBar(
                          title: "Card already belongs to another student",
                          context: context,
                        );
                      } else {
                        Utils.showSnackBar(
                          title: "Something went wrong",
                          context: context,
                        );
                      }
                    } else {
                      // Handle non-HTTP related errors (e.g., network issues)
                      Utils.showSnackBar(
                        title: "Network Error",
                        context: context,
                      );
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  } catch (e) {
                    Utils.showSnackBar(
                        title: "Something went wrong, try again later",
                        context: context,
                        color: Colors.red);
                  }
                },
                block: true,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
