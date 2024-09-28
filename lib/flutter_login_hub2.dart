/// A widget that provides a form-based UI for login and registration processes.
///
/// The `FlutterLoginHub` widget is a customizable form that handles input fields,
/// form validation, and user interactions for login and registration. It supports
/// different types of fields such as text, email, password, and mobile numbers,
/// and dynamically creates input fields based on the provided configuration.
///
/// The widget supports both login and registration modes, which can be set via
/// the `flutterLoginHubType` parameter. It also allows for custom field validation
/// through the `validator` function in the `WidgetModel`.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controller/login_controller.dart';

/// The main stateful widget for the login/registration form.
class FlutterLoginHub2 extends StatefulWidget {
  // Map to hold input field configurations.
  final Map<String, WidgetModel> inputFields;
  // Optional image to display at the top of the form (e.g., logo).
  final ImageModel? image;
  // Callback when the form is successfully validated.
  Function(Map<String, dynamic> processData, {bool isRemember})? onProcess;
  // Optional parameters for action button name and screen heading.
  String? actionButtonName, screenHeading;
  // boolean flag for whether to display remember me check box
  bool addRememberMe;
  // button style Elevated button
  ButtonStyle? actionButtonStyle;
  // text style for heading text
  TextStyle? headingStyle;
  //
  bool showLoadingOnProcess;

  FlutterLoginHub2({Key? key,
    required this.inputFields,
    this.image,
    this.actionButtonName = "", this.screenHeading = "",
    this.addRememberMe = false,
    this.actionButtonStyle,
    this.headingStyle,
    this.showLoadingOnProcess = false,
    this.onProcess}) : super(key: key);

  @override
  State<FlutterLoginHub2> createState() => _FlutterLoginHub2State();
}

class _FlutterLoginHub2State extends State<FlutterLoginHub2> {
  late FlutterLoginHubController loginController;

  @override
  void initState() {
    super.initState();
    loginController = Get.put(FlutterLoginHubController());
    // loginController.initFields(widget.inputFields);
  }

  @override
  void dispose() {
    loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Form(
              // key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Display the appropriate title based on the form type (login or register).
                  if (widget.screenHeading!.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          widget.screenHeading!,
                          style: widget.headingStyle ?? Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),

                  // Display logo image if provided.
                  if(widget.image != null)
                    _buildImageFields(widget.image!),

                  // Obx(() => _buildInputFields(loginController),),
                  _buildInputFields(loginController),
                  // Add a "Remember Me" checkbox if enabled.
                  _buildRememberMe(loginController),

                  // const SizedBox(height: 16),
                  // Submit button to trigger form validation and processing.
                  _buildSubmitButton(loginController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builds an optional logo image section based on the provided ImageModel.
  Widget _buildImageFields(ImageModel model) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Image.asset(
        model.imgPath.isEmpty ? "assets/login.png" : model.imgPath,
        height: model.height,
        width: model.width,
        fit: BoxFit.fill,
      ),
    );
  }

  // Builds input fields dynamically based on the provided input field configuration.
  Widget _buildInputFields(FlutterLoginHubController controller) {
    return Column(
      children: widget.inputFields.entries.map((entry) {
        String key = entry.key;
        WidgetModel model = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller.controllers[key],
            focusNode: controller.focusNodes[key],
            // Set text input action (next or done) based on whether this is the last field.
            textInputAction: TextInputAction.next,
            // If the field type is mobile, restrict input to digits only.
            inputFormatters: model.isNumberField
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            // Set the appropriate keyboard type for the field.
            keyboardType: model.isNumberField ? TextInputType.number : null,
            // Set max length for mobile number fields.
            maxLength: model.maxLength,
            // Show/hide password for password fields.
            obscureText: model.isObscureText && !controller.isVisiblePassword.value,
            cursorColor: model.cursorColor,
            decoration: InputDecoration(
              isDense: true,
              border: model.border,
              focusedBorder: model.focusBorder,
              enabledBorder: model.enabledBorder,
              disabledBorder: model.disabledBorder,
              hintText: model.hintText,
              labelText: model.label,
              counterText: "",
              floatingLabelStyle: model.floatingLabelStyle,
              // Toggle visibility for password fields.
              suffixIcon: model.showHidePassToggle ? Obx(() => _buildPasswordToggle(model, controller))  : null,
            ),
            style: model.textStyle,
            onChanged: model.onChanged,
            onTap: model.onTap,
            onFieldSubmitted: model.onFieldSubmitted,
            onEditingComplete: model.onEditingComplete,
          ),
        );
      }).toList(),
    );

  }

  // Toggles password visibility for password fields.
  _buildPasswordToggle(WidgetModel model, FlutterLoginHubController controller) {
    return GestureDetector(
      child: Icon(controller.isVisiblePassword.value ? Icons.visibility : Icons.visibility_off),
      onTap: () {
        controller.isVisiblePassword.value = !controller.isVisiblePassword.value;
      },
    );
  }

  // Builds the "Remember Me" checkbox if enabled.
  Widget _buildRememberMe(FlutterLoginHubController controller) {
    return Visibility(
      visible: widget.addRememberMe,
      child: Obx(() => Row(
        children: [
          Checkbox(
            value: controller.isRemember.value,
            onChanged: (value) {
              controller.isRemember.value = value!;
            },
          ),
          const Text("Remember Me"),
        ],
      )),
    );
  }

  // Builds the form's submit button.
  Widget _buildSubmitButton(FlutterLoginHubController controller) {
    return Obx(() {
      print("Loading state: ${controller.showLoading.value}");
      return widget.showLoadingOnProcess && controller.showLoading.value
          ? const SizedBox(
        width: 35,
        height: 35,
        child: CircularProgressIndicator(),
      )
          : ElevatedButton(
        onPressed: () {
          // controller.validateFields(context, widget.inputFields, widget.onProcess);
        },
        style: widget.actionButtonStyle,
        child: Text(widget.actionButtonName?.isNotEmpty ?? false ? widget.actionButtonName! : "OK"),
      );
    })
    ;
  }

}

/// Model class for form input fields.
///
/// This class holds the configuration for text input fields, including
/// hint text, label, border style, and custom validation logic.
class WidgetModel {
  // Placeholder text for the input field.
  String hintText;

  // Label text for the input field.
  String label;

  // used to set controller text
  String value;

  // show error msg in SnackBar
  String errorMsg;

  // Border style for the input field.
  InputBorder border, focusBorder, enabledBorder, disabledBorder;

  // Custom validator function for the input field.
  // return only true or false, message will be shown by package.
  bool Function(String)? validator;

  // to set field minimum and maximum width
  int? maxLength;

  //
  bool isObscureText;

  //
  bool showHidePassToggle;

  bool isNumberField;

  // to set whether field is enable or readOnly mode
  bool isEnable, readOnly;

  // to set style of hint text, text of textField, or floating lable text
  TextStyle? hintStyle, textStyle, floatingLabelStyle;

  // to set obscuring character for password or etc.
  String obscuringCharacter;

  // if required strong password then isStrongPasswordRequired: true to package provide strong validation
  bool isStrongPasswordRequired;

  // to set TextField cursor
  Color? cursorColor;

  // if validator is null and validationExp is define then check for this. else Package validation
  RegExp? validationExp;

  Function(String)? onChanged;
  Function(String)? onFieldSubmitted;
  Function()? onTap;
  Function()? onEditingComplete;


  WidgetModel({
    this.hintText = "",
    this.label = "",
    this.errorMsg = "",
    this.value = "",
    this.border = const OutlineInputBorder(),
    this.focusBorder = const OutlineInputBorder(),
    this.disabledBorder = const OutlineInputBorder(),
    this.enabledBorder = const OutlineInputBorder(),
    this.validator,
    this.maxLength,
    this.isNumberField = false,
    this.isObscureText = false,
    this.showHidePassToggle = false,
    this.isEnable = true,
    this.readOnly = false,
    this.cursorColor,
    this.hintStyle,
    this.textStyle,
    this.floatingLabelStyle,
    this.obscuringCharacter = '•',
    this.isStrongPasswordRequired = false,
    this.validationExp,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
  }): super();
}

/// Model class for image fields in the form.
///
/// This class holds the configuration for displaying an image, such as
/// the image path, height, and width.
class ImageModel {
  String imgPath;
  double height;
  double width;

  ImageModel({required this.imgPath, this.height = 100, this.width = 100});
}
