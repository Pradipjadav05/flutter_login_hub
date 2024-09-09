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

/// The main stateful widget for the login/registration form.
class FlutterLoginHub extends StatefulWidget {
  // Map to hold input field configurations.
  final Map<String, WidgetModel> inputFields;
  // Optional image to display at the top of the form (e.g., logo).
  final ImageModel? image;
  // Callback when the form is successfully validated.
  Future Function(Map<String, dynamic> processData, {bool isRemember})? onProcess;
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

  FlutterLoginHub({Key? key,
    required this.inputFields,
    this.image,
    this.actionButtonName = "", this.screenHeading = "",
    this.addRememberMe = false,
    this.actionButtonStyle,
    this.headingStyle,
    this.showLoadingOnProcess = false,
    this.onProcess,
  }) : super(key: key);

  @override
  State<FlutterLoginHub> createState() => _FlutterLoginHubState();
}

class _FlutterLoginHubState extends State<FlutterLoginHub> {
  // Map to hold controllers for each input field
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  // Password visibility and Remember Me state
  bool _isVisiblePassword = false;
  bool _isRemember = false;

  //
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    widget.inputFields.forEach((key, model) {
      _controllers[key] = TextEditingController(text: model.value);
      _focusNodes[key] = FocusNode();
    });
  }

  @override
  void dispose() {
    // Dispose of all controllers to free up resources.
    _controllers.values.forEach((controller) => controller.dispose());
    // Dispose of all focus nodes.
    _focusNodes.values.forEach((focusNode) => focusNode.dispose());
    super.dispose();
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
  void _validateFields() async {
    bool isValid = true;
    Map<String, dynamic> validatedData = {};

    showLoading(true);
    for (var entry in widget.inputFields.entries) {
      String key = entry.key;
      WidgetModel model = entry.value;
      final value = _controllers[key]?.text ?? '';

      // Validate empty fields and show a `SnackBar` with an error message.
      if (value.isEmpty) {
        isValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your $key')),
        );
        _focusNodes[key]?.requestFocus();
        showLoading(false);
        break;
      }

      // If a custom validator is provided, use it for validation.
      if (model.validator != null) {
        bool res = model.validator!(value);
        // If the field is invalid, set focus on it and break out of the loop.
        if (!res) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(model.errorMsg)),);
          _focusNodes[key]?.requestFocus();
          showLoading(false);
          break;
        }
      }

      // General validation for required fields and field type.

      // if validation Expression is given then check it.
      if(model.validationExp.toString().isNotEmpty && model.validationExp != null){
        if (!model.validationExp!.hasMatch(value)) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(model.errorMsg)),);
          _focusNodes[key]?.requestFocus();
          showLoading(false);
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
            _focusNodes[key]?.requestFocus();
            showLoading(false);
            break;
          }
          else if (!RegExp(r'[A-Z]').hasMatch(value)) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Password must contain at least one uppercase letter')),
            );
            _focusNodes[key]?.requestFocus();
            showLoading(false);
            break;
          }
          else if (!RegExp(r'[0-9]').hasMatch(value)) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Password must contain at least one number')),
            );
            _focusNodes[key]?.requestFocus();
            showLoading(false);
            break;
          }
          else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Password must contain at least one special character')),
            );
            _focusNodes[key]?.requestFocus();
            showLoading(false);
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
      await widget.onProcess?.call(validatedData, isRemember: _isRemember);
      showLoading(false);
    }
  }

  showLoading(bool value){
    setState(() {
      _showLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Form(
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

                  // Build input fields dynamically based on configuration.
                  _buildInputFields(),

                  // Add a "Remember Me" checkbox if enabled.
                  _buildRememberMe(),
                  const SizedBox(height: 20),
                  // Submit button to trigger form validation and processing.
                  _buildSubmitButton(),
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
  Widget _buildInputFields() {
    return Column(
      children: widget.inputFields.entries.map((entry) {
        String key = entry.key;
        WidgetModel model = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _controllers[key],
            focusNode: _focusNodes[key],
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
            obscureText: model.isObscureText && !_isVisiblePassword,
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
              suffixIcon: model.showHidePassToggle
                  ? IconButton(
                icon: Icon(_isVisiblePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isVisiblePassword = !_isVisiblePassword;
                  });
                },
              )
                  : null,
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
  Widget _buildRememberMe() {
    return Visibility(
      visible: widget.addRememberMe,
      child: Row(
        children: [
          Checkbox(
            value: _isRemember,
            onChanged: (value) {
              setState(() {
                _isRemember = value!;
              });
            },
          ),
          const Text("Remember Me"),
        ],
      ),
    );
  }

  // Builds the form's submit button.
  Widget _buildSubmitButton() {
    return _showLoading
        ? const SizedBox(
      width: 35,
      height: 35,
      child: CircularProgressIndicator(),
    )
        : ElevatedButton(
      onPressed: _validateFields,
      style: widget.actionButtonStyle,
      child: Text(widget.actionButtonName!.isNotEmpty ? widget.actionButtonName! : "OK"),
    );
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


