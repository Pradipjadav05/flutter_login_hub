import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../flutter_login_hub.dart';

enum WidgetType { username, number, email, password }

class FlutterLoginHubController extends GetxController {
  // Map to hold controllers for each input field
  final Map<String, TextEditingController> controllers = {};
  final Map<String, FocusNode> focusNodes = {};

  // Password visibility and Remember Me state
  var isVisiblePassword = false.obs;
  var isRemember = false.obs;

  var showLoading = false.obs;

  // Initialize controllers and focus nodes dynamically based on input fields
  void initFields(Map<String, WidgetModel> inputFields) {
    inputFields.forEach((key, model) {
      controllers[key] = TextEditingController(text: model.value);
      focusNodes[key] = FocusNode();
    });
  }

  // Dispose controllers and focus nodes
  @override
  void onClose() {
    controllers.values.forEach((controller) => controller.dispose());
    focusNodes.values.forEach((focusNode) => focusNode.dispose());
    super.onClose();
  }

  /*
  * Validates the fields in the form.
  *
  * This method performs manual validation of the input fields based on the field
  * type and the provided validator function (if any). It shows error messages
  * using a `SnackBar` if validation fails, and sets focus on the first invalid field.
  * Returns `true` if all fields are valid, otherwise `false`.
  * */

  // Validate fields and trigger callback if valid
  void validateFields(BuildContext context,Map<String, WidgetModel> inputFields, Function(Map<String, dynamic> processData, {bool isRemember})? onProcess) {
    bool isValid = true;
    Map<String, dynamic> validatedData = {};

    showLoading.value = true;
    for (var entry in inputFields.entries) {
      String key = entry.key;
      WidgetModel model = entry.value;
      final value = controllers[key]?.text ?? '';

      // Validate empty fields and show a `SnackBar` with an error message.
      if (value.isEmpty) {
        isValid = false;
        _showSimpleDialog(context, 'Please enter your $key');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Please enter your $key')),
        // );
        focusNodes[key]?.requestFocus();
        showLoading.value = false;
        break;
      }

      // If a custom validator is provided, use it for validation.
      if (model.validator != null) {
        bool res = model.validator!(value);
        // If the field is invalid, set focus on it and break out of the loop.
        if (!res) {
          isValid = false;
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(model.errorMsg)),);
          _showSimpleDialog(context, model.errorMsg);
          focusNodes[key]?.requestFocus();
          showLoading.value = false;
          break;
        }
      }

      // General validation for required fields and field type.

      // if validation Expression is given then check it.
      if(model.validationExp.toString().isNotEmpty && model.validationExp != null){
        if (!model.validationExp!.hasMatch(value)) {
          isValid = false;
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(model.errorMsg)),);
          _showSimpleDialog(context, model.errorMsg);
          focusNodes[key]?.requestFocus();
          showLoading.value = false;
          break;
        }
      }
      else {
        // Validate mobile fields for correct format and length.
       /* if (model.isNumberField == WidgetType.number) {
          if (!RegExp(r'^[0-9]+$').hasMatch(value) || value.length != 10) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
            );
            focusNodes[key]?.requestFocus();
            break;
          }
        }*/

        // Validate email fields for correct format.
       /* if (model.fieldType == WidgetType.email) {
          final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value)) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email address')),);
            focusNodes[key]?.requestFocus();
            break;
          }
        }*/

        // Validate password fields for length and character requirements.
        // for this need to required isStrongPasswordRequired: true
        // if (model.fieldType == WidgetType.password) {
          if(model.isStrongPasswordRequired){
            if (value.length < 8) {
              isValid = false;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Password must be at least 8 characters long')),
              );
              focusNodes[key]?.requestFocus();
              break;
            }
            else if (!RegExp(r'[A-Z]').hasMatch(value)) {
              isValid = false;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Password must contain at least one uppercase letter')),
              );
              focusNodes[key]?.requestFocus();
              showLoading.value = false;
              break;
            }
            else if (!RegExp(r'[0-9]').hasMatch(value)) {
              isValid = false;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Password must contain at least one number')),
              );
              focusNodes[key]?.requestFocus();
              showLoading.value = false;
              break;
            }
            else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
              isValid = false;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Password must contain at least one special character')),
              );
              focusNodes[key]?.requestFocus();
              showLoading.value = false;
              break;
            }
          }
        // }
      }
      // If the field is valid, add it to the validatedData map.
      validatedData[key] = value;
    }

    // If all fields are valid, pass the validated data to the onProcess callback.
    if (isValid) {
      onProcess?.call(validatedData, isRemember: isRemember.value);
      showLoading.value = false;
    }
  }


  void _showSimpleDialog(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            message,
            style: const TextStyle(fontSize: 18.0),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
