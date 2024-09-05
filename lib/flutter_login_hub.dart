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
  final Map<String, BaseModel> inputFields;
  // Optional image to display at the top of the form (e.g., logo).
  final ImageModel? image;
  // Callback when the form is successfully validated.
  Function(Map<String, dynamic> processData, {bool? isRemember})? onProcess;
  // Optional parameters for action button name and screen heading.
  String? actionButtonName, screenHeading;
  // boolean flag for whether to display remember me check box
  bool addRememberMe;
  // button style Elevated button
  ButtonStyle? actionButtonStyle;
  // text style for heading text
  TextStyle? headingStyle;

  FlutterLoginHub({Key? key,
    required this.inputFields,
    this.image,
    this.actionButtonName = "", this.screenHeading = "",
    this.addRememberMe = false,
    this.actionButtonStyle,
    this.headingStyle,
    this.onProcess}) : super(key: key);

  @override
  State<FlutterLoginHub> createState() => _FlutterLoginHubState();
}

class _FlutterLoginHubState extends State<FlutterLoginHub> {
  // Create a global key for the form state
  final _formKey = GlobalKey<FormState>();

  // Map to store controllers and focus nodes dynamically for each input field.
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  // State variables to handle "Remember Me" and password visibility.
  bool isRemember = false, isVisiblePassword = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes for each input field based on the inputFields map.
    widget.inputFields.forEach((key, model) {
      _controllers[key] = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Display the appropriate title based on the form type (login or register).
                  if (widget.screenHeading!.isNotEmpty)
                    Text(
                      widget.screenHeading!,
                      style: widget.headingStyle ?? Theme.of(context).textTheme.displaySmall,
                    ),

                  const SizedBox(height: 40),
                  // Display logo image if provided.
                  if( widget.image != null)
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
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Image.asset(
        model.imgPath.isEmpty ? "assets/login.png" : model.imgPath,
        height: model.height,
        width: model.width,
        package: model.imgPath.isEmpty ? "flutter_login_hub" : null,
      ),
    );
  }

  // Builds input fields dynamically based on the provided input field configuration.
  Widget _buildInputFields() {
    final inputFields = widget.inputFields.entries
        .where((entry) => entry.value is WidgetModel)
        .toList();

    return Column(
      children: inputFields.asMap().entries.map((entry) {
        int index = entry.key;
        String key = entry.value.key;
        WidgetModel model = entry.value.value as WidgetModel;
        // Determine if this is the last TextFormField to set the appropriate input action.
        bool isLastField = index == inputFields.length - 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: _controllers[key],
            focusNode: _focusNodes[key],
            // Set text input action (next or done) based on whether this is the last field.
            textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
            // If the field type is mobile, restrict input to digits only.
            inputFormatters: model.fieldType == WidgetType.mobile
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            // Set the appropriate keyboard type for the field.
            keyboardType: model.fieldType == WidgetType.mobile ? TextInputType.number : null,
            // Set max length for mobile number fields.
            maxLength: model.fieldType == WidgetType.mobile ? 10 : model.maxLength,
            // Show/hide password for password fields.
            obscureText: model.fieldType == WidgetType.password && !isVisiblePassword,
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
              suffix: _buildPasswordToggle(model),
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
  Widget? _buildPasswordToggle(WidgetModel model) {
    if (model.fieldType == WidgetType.password) {
      return GestureDetector(
        child: Icon(isVisiblePassword ? Icons.visibility : Icons.visibility_off),
        onTap: () {
          setState(() {
            isVisiblePassword = !isVisiblePassword;
          });
        },
      );
    }
    return null;
  }

  // Builds the "Remember Me" checkbox if enabled.
  Widget _buildRememberMe() {
    return Visibility(
      visible: widget.addRememberMe,
      child: Row(
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              return Checkbox(
                value: isRemember,
                onChanged: (value) {
                  setState(() {
                    isRemember = value!;
                  });
                },
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              );
            },
          ),
          const Text("Remember Me"),
        ],
      ),
    );
  }

  // Builds the form's submit button.
  Widget _buildSubmitButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            // Validate fields and trigger the callback if valid.
            onPressed: _validateFields,
            style: widget.actionButtonStyle,
            child: Text(widget.actionButtonName!.isNotEmpty ? widget.actionButtonName! : "OK"),
          ),
        ),
      ],
    );
  }

  /*
  * Validates the fields in the form.
  *
  * This method performs manual validation of the input fields based on the field
  * type and the provided validator function (if any). It shows error messages
  * using a `SnackBar` if validation fails, and sets focus on the first invalid field.
  * Returns `true` if all fields are valid, otherwise `false`.
  * */
  bool _validateFields() {
    bool isValid = true;
    Map<String, dynamic> validatedData = {};

    // Validate input fields based on the field type and custom validator.
    for (var entry in widget.inputFields.entries.where((entry) => entry.value is WidgetModel)) {
      String key = entry.key;
      WidgetModel model = entry.value as WidgetModel;
      final value = _controllers[key]?.text ?? '';

      // If a custom validator is provided, use it for validation.
      if (model.validator != null) {
        bool res = model.validator!(value);

        // If the field is invalid, set focus on it and break out of the loop.
        if (!res) {
          isValid = false;
          _focusNodes[key]?.requestFocus();
          break;
        }

      } else {
        // General validation for required fields and field type.
        // Validate empty fields and show a `SnackBar` with an error message.
        if (value.isEmpty) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter your $key')),
          );
          _focusNodes[key]?.requestFocus();
          break;
        }

        // Validate mobile fields for correct format and length.
        if (model.fieldType == WidgetType.mobile) {
          if (!RegExp(r'^[0-9]+$').hasMatch(value) || value.length != 10) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please enter a valid 10-digit mobile number')),
            );
            _focusNodes[key]?.requestFocus();
            break;
          }
        }

        // Validate email fields for correct format.
        if (model.fieldType == WidgetType.email) {
          final RegExp emailRegex =
              RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value)) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please enter a valid email address')),
            );
            _focusNodes[key]?.requestFocus();
            break;
          }
        }

        // Validate password fields for length and character requirements.
        if (model.fieldType == WidgetType.password) {
          if (value.length < 8) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Password must be at least 8 characters long')),
            );
            _focusNodes[key]?.requestFocus();
            break;
          } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Password must contain at least one uppercase letter')),
            );
            _focusNodes[key]?.requestFocus();
            break;
          } else if (!RegExp(r'[0-9]').hasMatch(value)) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Password must contain at least one number')),
            );
            _focusNodes[key]?.requestFocus();
            break;
          } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
            isValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Password must contain at least one special character')),
            );
            _focusNodes[key]?.requestFocus();
            break;
          }
        }
      }
      // If the field is valid, add it to the validatedData map.
      validatedData[key] = value;
    }
    // If all fields are valid, pass the validated data to the onProcess callback.
    if (isValid) {
      widget.onProcess?.call(validatedData,isRemember: widget.addRememberMe ? isRemember : false);
    }

    return isValid;
  }
}

enum WidgetType { username, mobile, email, password }

/// Base model class for different types of input fields.
///
/// This class defines the type of the widget and is extended by specific
/// models like `WidgetModel` and `ImageModel`.
abstract class BaseModel {
  // Type of the widget (e.g., username, mobile).
  final WidgetType fieldType;

  BaseModel({this.fieldType = WidgetType.username});
}

/// Model class for form input fields.
///
/// This class holds the configuration for text input fields, including
/// hint text, label, border style, and custom validation logic.
class WidgetModel extends BaseModel {
  // Placeholder text for the input field.
  String hintText;

  // Label text for the input field.
  String label;

  // Border style for the input field.
  InputBorder border, focusBorder, enabledBorder, disabledBorder;

  // Custom validator function for the input field.
  bool Function(String)? validator;

  int? maxLength;

  bool isEnable, readOnly;

  TextStyle? hintStyle, textStyle, floatingLabelStyle;

  String obscuringCharacter;

  Color? cursorColor;

  Function(String)? onChanged;
  Function(String)? onFieldSubmitted;
  Function()? onTap;
  Function()? onEditingComplete;


  WidgetModel({
    this.hintText = "",
    this.label = "",
    this.border = const OutlineInputBorder(),
    this.focusBorder = const OutlineInputBorder(),
    this.disabledBorder = const OutlineInputBorder(),
    this.enabledBorder = const OutlineInputBorder(),
    this.validator,
    this.maxLength,
    this.isEnable = true,
    this.readOnly = false,
    this.cursorColor,
    this.hintStyle,
    this.textStyle,
    this.floatingLabelStyle,
    this.obscuringCharacter = '•',
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    required WidgetType fieldType,
  }): super(fieldType: fieldType);
}

/// Model class for image fields in the form.
///
/// This class holds the configuration for displaying an image, such as
/// the image path, height, and width.
class ImageModel extends BaseModel {
  String imgPath;
  double height;
  double width;

  ImageModel({required this.imgPath, this.height = 100, this.width = 100});
}
